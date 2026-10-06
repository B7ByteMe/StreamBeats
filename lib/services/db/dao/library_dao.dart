import 'dart:developer';

import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/core/models/media_playlist_model.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/collection_mapper.dart';
import 'package:streambeats/services/db/mappers/media_item_mapper.dart';
import 'package:streambeats/services/db/mappers/playlist_mapper.dart';
import 'package:isar_community/isar.dart';

class LibraryDAO {
  final Future<Isar> _db;

  const LibraryDAO(this._db);

  String _mediaIdOf(PlaylistDB p) {
    switch (p.type) {
      case PlaylistTypeDB.artist:
        return (p.artists != null && p.artists!.isNotEmpty)
            ? (p.artists!.first.mediaId ?? '')
            : '';
      case PlaylistTypeDB.album:
        return p.album?.mediaId ?? '';
      case PlaylistTypeDB.remotePlaylist:
        return p.remotePlaylist?.mediaId ?? '';
      case PlaylistTypeDB.userPlaylist:
        return '';
    }
  }

  Future<PlaylistDB?> _findByMediaId(
      PlaylistTypeDB type, String mediaId) async {
    if (mediaId.isEmpty) return null;
    final isar = await _db;
    final candidates =
        await isar.playlistDBs.filter().typeIndexEqualTo(type.index).findAll();
    for (final c in candidates) {
      if (_mediaIdOf(c) == mediaId) return c;
    }
    return null;
  }

  Future<int> saveArtist(ArtistSummary artist,
      {required String sourceName}) async {
    final existing = await _findByMediaId(PlaylistTypeDB.artist, artist.id);

    final artistDb = artistSummaryToArtistSummaryDB(artist);
    final row =
        existing ?? PlaylistDB(name: artist.id, type: PlaylistTypeDB.artist);

    row.type = PlaylistTypeDB.artist;
    row.name = artist.id;
    row.subtitle = 'Artist � $sourceName';
    row.thumbnail = artistDb.thumbnail;
    row.description = artist.subtitle;
    row.artists = [artistDb];
    row.album = null;
    row.remotePlaylist = null;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote artist "${artist.name}" (id: $id)', name: 'LibraryDAO');
    return id;
  }

  Future<int> saveAlbum(AlbumSummary album,
      {required String sourceName}) async {
    final existing = await _findByMediaId(PlaylistTypeDB.album, album.id);

    final albumDb = albumSummaryToAlbumSummaryDB(album);
    final row =
        existing ?? PlaylistDB(name: album.id, type: PlaylistTypeDB.album);

    row.type = PlaylistTypeDB.album;
    row.name = album.id;
    row.subtitle = 'Album � $sourceName';
    row.thumbnail = albumDb.thumbnail;
    row.description = album.subtitle;
    row.artists = albumDb.artists;
    row.album = albumDb;
    row.remotePlaylist = null;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote album "${album.title}" (id: $id)', name: 'LibraryDAO');
    return id;
  }

  Future<int> saveRemotePlaylist(PlaylistSummary playlist,
      {required String sourceName}) async {
    final existing =
        await _findByMediaId(PlaylistTypeDB.remotePlaylist, playlist.id);

    final row = existing ??
        PlaylistDB(name: playlist.id, type: PlaylistTypeDB.remotePlaylist);

    final owner = playlist.owner;
    final ownerArtists = (owner != null && owner.trim().isNotEmpty)
        ? [ArtistSummaryDB()..name = owner.trim()]
        : null;

    final remoteSummary = RemotePlaylistSummaryDB(
      title: playlist.title,
      mediaId: playlist.id,
      url: playlist.url,
      thumbnail: playlist.thumbnail.url.isNotEmpty
          ? artworkToArtworkDB(playlist.thumbnail)
          : null,
      artists: ownerArtists,
      subtitle: playlist.owner,
    );

    row.type = PlaylistTypeDB.remotePlaylist;
    row.name = playlist.id;
    row.subtitle = 'Playlist � $sourceName';
    row.thumbnail = remoteSummary.thumbnail;
    row.description = playlist.owner;
    row.artists = ownerArtists;
    row.album = null;
    row.remotePlaylist = remoteSummary;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote playlist "${playlist.title}" (id: $id)',
        name: 'LibraryDAO');
    return id;
  }

  Future<List<PlaylistDB>> _getSavedByType(PlaylistTypeDB type) async {
    final isar = await _db;
    return isar.playlistDBs
        .filter()
        .typeIndexEqualTo(type.index)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<List<ArtistSummary>> getSavedArtists() async {
    final rows = await _getSavedByType(PlaylistTypeDB.artist);
    return rows.map(playlistDBToArtistSummary).toList();
  }

  Future<List<AlbumSummary>> getSavedAlbums() async {
    final rows = await _getSavedByType(PlaylistTypeDB.album);
    return rows.map(playlistDBToAlbumSummary).toList();
  }

  Future<List<PlaylistSummary>> getSavedRemotePlaylists() async {
    final rows = await _getSavedByType(PlaylistTypeDB.remotePlaylist);
    return rows.map(playlistDBToPlaylistSummary).toList();
  }

  Future<bool> removeByMediaId(String mediaId, PlaylistTypeDB type) async {
    final existing = await _findByMediaId(type, mediaId);
    if (existing == null) return false;
    final isar = await _db;
    await isar.writeTxn(() => isar.playlistDBs.delete(existing.id));
    log('Removed saved ${type.name}: $mediaId', name: 'LibraryDAO');
    return true;
  }

  Future<void> removeSavedById(int id) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playlistDBs.delete(id));
  }

  Future<bool> isSavedByMediaId(String mediaId, PlaylistTypeDB type) async {
    final existing = await _findByMediaId(type, mediaId);
    return existing != null;
  }

  Future<bool> isSaved(String mediaId, PlaylistType type) async {
    final dbType = playlistTypeToPlaylistTypeDB(type);
    return isSavedByMediaId(mediaId, dbType);
  }

  Future<Playlist?> resolveByStorageKey(String storageKey) async {
    final isar = await _db;
    final db =
        await isar.playlistDBs.filter().nameEqualTo(storageKey).findFirst();
    if (db == null) return null;
    return playlistDBToPlaylist(db);
  }

  Future<Stream<void>> watchSavedCollections() async {
    final isar = await _db;
    return isar.playlistDBs
        .filter()
        .not()
        .typeIndexEqualTo(PlaylistTypeDB.userPlaylist.index)
        .watchLazy(fireImmediately: true);
  }
}