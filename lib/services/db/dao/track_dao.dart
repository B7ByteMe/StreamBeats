import 'dart:developer';

import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/media_item_mapper.dart';
import 'package:streambeats/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

class TrackDAO {
  final Future<Isar> _db;

  const TrackDAO(this._db);

  Future<int> upsertTrack(Track track) async {
    final isar = await _db;
    final trackDB = trackToTrackDB(track);
    final existing =
        await isar.trackDBs.filter().mediaIdEqualTo(track.id).findFirst();
    if (existing != null) {
      trackDB.id = existing.id;
    }
    return isar.writeTxn(() => isar.trackDBs.put(trackDB));
  }

  Future<List<int>> upsertTracks(List<Track> tracks) async {
    if (tracks.isEmpty) return [];
    final isar = await _db;
    final trackDBs = <TrackDB>[];
    for (final track in tracks) {
      final trackDB = trackToTrackDB(track);
      final existing =
          await isar.trackDBs.filter().mediaIdEqualTo(track.id).findFirst();
      if (existing != null) {
        trackDB.id = existing.id;
      }
      trackDBs.add(trackDB);
    }
    return isar.writeTxn(() => isar.trackDBs.putAll(trackDBs));
  }

  Future<int> upsertTrackDB(TrackDB track) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.trackDBs.put(track));
  }

  Future<Track?> getTrackByMediaId(String mediaId) async {
    final isar = await _db;
    final trackDB =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    return trackDB != null ? trackDBToTrack(trackDB) : null;
  }

  Future<Track?> getTrackById(int id) async {
    final isar = await _db;
    final trackDB = await isar.trackDBs.get(id);
    return trackDB != null ? trackDBToTrack(trackDB) : null;
  }

  Future<TrackDB?> getTrackDBByMediaId(String mediaId) async {
    final isar = await _db;
    return isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
  }

  Future<List<TrackDB>> getTracksByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final isar = await _db;
    final results = await isar.trackDBs.getAll(ids);
    return results.whereType<TrackDB>().toList();
  }

  Future<List<TrackDB>> searchTracks(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final isar = await _db;
    final q = isar.trackDBs.filter().titleContains(query, caseSensitive: false);
    return limit == 0 ? q.findAll() : q.limit(limit).findAll();
  }

  Future<void> purgeOrphanTrack(String mediaId) async {
    final isar = await _db;
    final track =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (track == null) return;

    final hasEntry = await isar.playlistEntryDBs
        .filter()
        .playlistIdIsNotNull()
        .and()
        .track((q) => q.mediaIdEqualTo(mediaId))
        .findFirst();
    if (hasEntry != null) return; // still in a playlist

    final hasDownload =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (hasDownload != null) return; // still downloaded

    await isar.writeTxn(() => isar.trackDBs.delete(track.id));
    log('Purged orphan track: $mediaId', name: 'TrackDAO');
  }

  Future<int> purgeOrphanTracks() async {
    final isar = await _db;
    final allTracks = await isar.trackDBs.where().findAll();
    int purged = 0;

    for (final track in allTracks) {
      final hasEntry = await isar.playlistEntryDBs
          .filter()
          .track((q) => q.idEqualTo(track.id))
          .findFirst();
      if (hasEntry != null) continue;

      final hasDownload = await isar.downloadDBs
          .filter()
          .mediaIdEqualTo(track.mediaId)
          .findFirst();
      if (hasDownload != null) continue;

      final hasHistory = await isar.playbackHistoryDBs
          .filter()
          .track((q) => q.idEqualTo(track.id))
          .findFirst();
      if (hasHistory != null) continue;

      await isar.writeTxn(() => isar.trackDBs.delete(track.id));
      purged++;
    }

    log('Purged $purged orphan track(s)', name: 'TrackDAO');
    return purged;
  }

  Future<Stream<void>> watchTracks() async {
    final isar = await _db;
    return isar.trackDBs.watchLazy(fireImmediately: false);
  }
}