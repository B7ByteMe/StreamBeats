import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:streambeats/plugins/utils/media_id.dart';
import 'package:streambeats/services/db/dao/playlist_dao.dart';
import 'package:streambeats/services/db/dao/track_dao.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/src/rust/api/local_music.dart';
import 'package:streambeats/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;
  final PlaylistDAO _playlistDAO;

  static const downloadsPlaylistName = '_DOWNLOADS';

  const DownloadDAO(this._db, this._trackDAO, this._playlistDAO);

  Future<void> putDownload({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    lastDownloaded ??= DateTime.now();

    await _trackDAO.upsertTrack(track);
    final downloadsId =
        await _playlistDAO.ensurePlaylist(downloadsPlaylistName);
    await _playlistDAO.addTrackToPlaylist(downloadsId, track);

    final existing =
        await isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing
          ..fileName = fileName
          ..filePath = filePath
          ..lastDownloaded = lastDownloaded;
        await isar.downloadDBs.put(existing);
        log('Updated download record for ${track.id}', name: 'DownloadDAO');
      } else {
        final record = DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded,
          mediaId: track.id,
        );
        await isar.downloadDBs.put(record);
        log('Created download record for ${track.id}', name: 'DownloadDAO');
      }
    });
  }

  Future<void> removeDownload(String mediaId, {bool deleteFile = true}) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();

    if (record == null) return;

    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));

    final downloadsPlaylist =
        await _playlistDAO.getPlaylistByName(downloadsPlaylistName);
    if (downloadsPlaylist != null) {
      await _playlistDAO.removeTrackFromPlaylist(downloadsPlaylist.id, mediaId);
    }

    if (deleteFile) {
      try {
        final file = File('${record.filePath}/${record.fileName}');
        if (await file.exists()) {
          await file.delete();
          log('Deleted file: ${record.fileName}', name: 'DownloadDAO');
        }
      } catch (e) {
        log('Failed to delete file: ${record.fileName}',
            error: e, name: 'DownloadDAO');
      }
    }
  }

  Future<void> putDownloadRecord({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    lastDownloaded ??= DateTime.now();

    await _trackDAO.upsertTrack(track);

    final existing =
        await isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing
          ..fileName = fileName
          ..filePath = filePath
          ..lastDownloaded = lastDownloaded;
        await isar.downloadDBs.put(existing);
      } else {
        await isar.downloadDBs.put(DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded,
          mediaId: track.id,
        ));
      }
    });
  }

  Future<void> removeDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return;
    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));
  }

  Future<void> removeDownloadsBatch(List<String> mediaIds) async {
    if (mediaIds.isEmpty) return;
    final isar = await _db;

    final records = <DownloadDB>[];
    for (final mediaId in mediaIds) {
      final record =
          await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
      if (record != null) {
        records.add(record);
      }
    }

    if (records.isEmpty) return;

    await isar.writeTxn(() async {
      await isar.downloadDBs.deleteAll(records.map((r) => r.id).toList());
    });

    final downloadsPlaylist =
        await _playlistDAO.getPlaylistByName(downloadsPlaylistName);
    if (downloadsPlaylist != null) {
      for (final mediaId in mediaIds) {
        await _playlistDAO.removeTrackFromPlaylist(downloadsPlaylist.id, mediaId);
      }
    }
  }

  Future<DownloadDB?> getDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return null;
    final file = File('${record.filePath}/${record.fileName}');
    if (!(await file.exists())) return null;
    return record;
  }

  Future<List<DownloadDB>> getValidDownloads() async {
    final isar = await _db;
    final all = await isar.downloadDBs.where().findAll();
    all.sort((a, b) {
      final aDate = a.lastDownloaded;
      final bDate = b.lastDownloaded;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    final valid = <DownloadDB>[];
    final stale = <DownloadDB>[];

    final existences = await Future.wait(
      all.map((record) => File('${record.filePath}/${record.fileName}').exists()),
    );

    for (var i = 0; i < all.length; i++) {
      final record = all[i];
      final exists = existences[i];
      if (exists) {
        valid.add(record);
      } else {
        stale.add(record);
      }
    }

    if (stale.isNotEmpty) {
      unawaited(removeDownloadsBatch(stale.map((s) => s.mediaId).toList()));
    }

    return valid;
  }

  Future<List<Track>> getValidDownloadedTracks() async {
    final downloads = await getValidDownloads();
    final result = <Track>[];
    final runtimeArtworkCacheDir = await _runtimeArtworkCacheDir();

    for (final record in downloads) {
      if (isLocalMediaId(record.mediaId)) continue;

      final track = await _trackDAO.getTrackByMediaId(record.mediaId);
      if (track != null) {
        final trackWithArtwork = await _resolveEmbeddedArtworkAtRuntime(
          record,
          track,
          runtimeArtworkCacheDir: runtimeArtworkCacheDir,
        );
        result.add(trackWithArtwork);
        continue;
      }

      result.add(
        Track(
          id: record.mediaId,
          title: record.fileName,
          artists: const [],
          thumbnail: const Artwork(url: '', layout: ImageLayout.square),
          isExplicit: false,
        ),
      );
    }

    return result;
  }

  Future<String> _runtimeArtworkCacheDir() async {
    final tempDir = await getTemporaryDirectory();
    return p.join(tempDir.path, 'streambeats_runtime_embedded_art');
  }

  Future<Track> _resolveEmbeddedArtworkAtRuntime(
    DownloadDB record,
    Track track, {
    required String runtimeArtworkCacheDir,
  }) async {
    final currentArtworkUrl = track.thumbnail.url;
    if (await _isExistingLocalImagePath(currentArtworkUrl)) {
      return track;
    }

    try {
      final filePath = p.join(record.filePath, record.fileName);
      final metadata = await readAudioMetadata(
        filePath: filePath,
        coverCacheDir: runtimeArtworkCacheDir,
      );

      final embeddedArtworkPath = metadata.coverArtPath;
      if (embeddedArtworkPath == null || embeddedArtworkPath.isEmpty) {
        return track;
      }

      final artworkFile = File(embeddedArtworkPath);
      if (!(await artworkFile.exists())) {
        return track;
      }

      return Track(
        id: track.id,
        title: track.title,
        artists: track.artists,
        album: track.album,
        durationMs: track.durationMs,
        thumbnail: Artwork(
          url: embeddedArtworkPath,
          urlLow: track.thumbnail.urlLow,
          urlHigh: track.thumbnail.urlHigh,
          layout: track.thumbnail.layout,
        ),
        url: track.url,
        isExplicit: track.isExplicit,
        lyrics: track.lyrics,
      );
    } catch (error) {
      log(
        'Runtime embedded artwork lookup failed for ${track.id}',
        name: 'DownloadDAO',
        error: error,
      );
      return track;
    }
  }

  Future<bool> _isExistingLocalImagePath(String? value) async {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.scheme == 'file') {
        final file = File(uri.toFilePath(windows: Platform.isWindows));
        return await file.exists();
      }
    } catch (_) {}

    return await File(trimmed).exists();
  }

  Future<bool> isDownloaded(String mediaId) async {
    final record = await getDownloadRecord(mediaId);
    return record != null;
  }

  Future<void> updateDownloadRecord(DownloadDB record) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.downloadDBs.put(record));
  }

  Future<Stream<void>> watchDownloads() async {
    final isar = await _db;
    return isar.downloadDBs.watchLazy(fireImmediately: true);
  }
}