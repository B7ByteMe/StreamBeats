import 'dart:async';
import 'dart:developer';
import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/core/constants/setting_keys.dart';
import 'package:streambeats/core/models/media_playlist_model.dart';
import 'package:streambeats/services/db/dao/library_dao.dart';
import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/mappers/media_item_mapper.dart';
import 'package:streambeats/services/db/mappers/playlist_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:streambeats/services/db/dao/playlist_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  StreamSubscription? _playlistWatcher;
  final PlaylistDAO _playlistDao;
  final LibraryDAO _libraryDao;

  LibraryItemsCubit({
    required PlaylistDAO playlistDao,
    required LibraryDAO libraryDao,
  })  : _playlistDao = playlistDao,
        _libraryDao = libraryDao,
        super(LibraryItemsLoading()) {
    _initialize();
  }

  @override
  Future<void> close() {
    _playlistWatcher?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    await _playlistDao.purgeBrokenPlaylistEntries();
    await _fetchPlaylists();
    _setupWatchers();
  }

  Future<void> _setupWatchers() async {
    _playlistWatcher = (await _playlistDao.watchAllPlaylists()).listen((_) {
      _fetchPlaylists();
    });
  }

  static const _systemPlaylists = {
    SettingKeys.recentlyPlayedPlaylist,
    SettingKeys.downloadPlaylist,
    SettingKeys.localMusicPlaylist,
  };

  Future<void> _fetchPlaylists() async {
    try {
      final allPlaylists = await _playlistDao.getAllPlaylists();
      allPlaylists.removeWhere((p) => _systemPlaylists.contains(p.name));
      allPlaylists.removeWhere((p) => p.name.trim().isEmpty);
      final items = await _toItemProperties(allPlaylists);
      emit(state.copyWith(playlists: items));
    } catch (e) {
      log('Error fetching playlists: $e', name: 'LibraryItemsCubit');
      emit(const LibraryItemsError('Failed to load your playlists.'));
    }
  }

  Future<List<PlaylistItemProperties>> _toItemProperties(
      List<PlaylistDB> dbs) async {
    final items = <PlaylistItemProperties>[];

    for (final p in dbs) {
      final domainPlaylist = playlistDBToPlaylist(p);

      String? subtitle;
      if (domainPlaylist.subtitle != null &&
          domainPlaylist.subtitle!.trim().isNotEmpty) {
        subtitle = domainPlaylist.subtitle!.trim();
      } else if (domainPlaylist.type == PlaylistType.userPlaylist) {
        final trackCount = (await _playlistDao.getPlaylistTracks(p.id)).length;
        subtitle = '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}';
      }

      final coverUrl = await _resolveCoverUrl(p);

      items.add(
        PlaylistItemProperties(
          playlistName: domainPlaylist.title,
          storageKey: p.name,
          subTitle: subtitle,
          coverImgUrl: coverUrl,
          type: domainPlaylist.type,
          isPinned: p.isPinned,
          sortOrder: p.sortOrder,
          playlistId: p.id,
        ),
      );
    }

    return items;
  }

  Future<String?> _resolveCoverUrl(PlaylistDB playlist) async {
    final thumb = playlist.thumbnail;
    if (thumb != null && thumb.url.isNotEmpty) {
      return thumb.url;
    }

    if (playlist.type == PlaylistTypeDB.artist &&
        playlist.artists != null &&
        playlist.artists!.isNotEmpty) {
      final artistThumb = playlist.artists!.first.thumbnail;
      if (artistThumb != null && artistThumb.url.isNotEmpty) {
        return artistThumb.url;
      }
    }

    if (playlist.type == PlaylistTypeDB.userPlaylist) {
      final tracks = await _playlistDao.getPlaylistTracks(playlist.id);
      if (tracks.isNotEmpty) {
        final trackUrl = tracks.first.thumbnail?.url;
        if (trackUrl != null && trackUrl.isNotEmpty) return trackUrl;
      }
    }

    return null;
  }

  Future<void> createPlaylist(String name) async {
    await _playlistDao.createPlaylist(name);
    SnackbarService.showMessage("Playlist '$name' created!");
  }

  void removePlaylistById(int playlistId) {
    _playlistDao.deletePlaylist(playlistId);
    SnackbarService.showMessage('Playlist removed');
  }

  void removePlaylistByName(String name) {
    if (name.isNotEmpty && name != 'Null') {
      _playlistDao.deletePlaylistByName(name);
      SnackbarService.showMessage('Playlist "$name" removed');
    }
  }

  Future<void> addToPlaylist(Track track, String playlistName,
      {bool showSnackbar = true}) async {
    if (playlistName == 'Null' || playlistName.isEmpty) return;
    try {
      await _playlistDao.addTrackToPlaylistByName(playlistName, track);
      if (showSnackbar) {
        SnackbarService.showMessage('${track.title} added to $playlistName');
      }
    } catch (e) {
      log('Failed to add "${track.title}" to "$playlistName": $e',
          name: 'LibraryItemsCubit');
      if (showSnackbar) {
        SnackbarService.showMessage(
            'Failed to add to playlist: ${e.toString().split('\n').first}');
      }
    }
  }

  Future<void> removeFromPlaylist(Track track, String playlistName,
      {bool showSnackbar = true}) async {
    if (playlistName == 'Null' || playlistName.isEmpty) return;
    final playlist = await _playlistDao.getPlaylistByName(playlistName);
    if (playlist == null) return;
    await _playlistDao.removeTrackFromPlaylist(playlist.id, track.id);
    if (showSnackbar) {
      SnackbarService.showMessage('${track.title} removed from $playlistName');
    }
  }

  Future<List<Track>?> getPlaylistTracks(String playlistName) async {
    try {
      final playlist = await _playlistDao.getPlaylistByName(playlistName);
      if (playlist == null) return null;
      final trackDBs = await _playlistDao.getPlaylistTracks(playlist.id);
      return trackDBs.map(trackDBToTrack).toList();
    } catch (e) {
      log('Error getting playlist: $e', name: 'LibraryItemsCubit');
      return null;
    }
  }

  Future<bool> isTrackLiked(Track track) async {
    return _playlistDao.isTrackLiked(track.id);
  }

  Future<void> setTrackLiked(Track track, bool liked) async {
    await _playlistDao.setTrackLiked(track, liked);
  }

  Future<Set<String>> getPlaylistsContainingTrack(String mediaId) async {
    final names = await _playlistDao.getPlaylistsContainingTrack(mediaId);
    return names.toSet();
  }

  Future<Playlist?> getPlaylistByName(String name) async {
    final playlistDB = await _playlistDao.getPlaylistByName(name);
    if (playlistDB == null) return null;
    return _playlistDao.loadPlaylist(name);
  }

  Future<void> saveRemoteArtist(
      {required ArtistSummary artist,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveArtist(artist, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage('Artist "${artist.name}" saved to library');
    }
  }

  Future<void> saveRemoteAlbum(
      {required AlbumSummary album,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveAlbum(album, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage('Album "${album.title}" saved to library');
    }
  }

  Future<void> saveRemotePlaylist(
      {required PlaylistSummary playlist,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveRemotePlaylist(playlist, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage(
          'Playlist "${playlist.title}" saved to library');
    }
  }

  Future<bool> isRemoteSaved(String mediaId, PlaylistType type) {
    return _libraryDao.isSaved(mediaId, type);
  }

  Future<void> removeRemoteSaved(String mediaId, PlaylistType type) async {
    final dbType = playlistTypeToPlaylistTypeDB(type);
    await _libraryDao.removeByMediaId(mediaId, dbType);
    SnackbarService.showMessage('Removed from library');
  }

  Future<Playlist?> resolveLibraryItem(String storageKey) {
    return _libraryDao.resolveByStorageKey(storageKey);
  }

  Future<List<Track>> searchTracks(String query) async {
    final results = await _playlistDao.searchLibrary(query);
    return results.map((r) => trackDBToTrack(r.$1)).toList();
  }

  Future<void> togglePin(int playlistId) async {
    final item =
        state.playlists.where((p) => p.playlistId == playlistId).firstOrNull;
    if (item == null) return;
    await _playlistDao.setPinned(playlistId, !item.isPinned);
  }

  Future<void> reorderLibrary(int oldIndex, int newIndex) async {
    final current = List<PlaylistItemProperties>.from(state.playlists);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    emit(state.copyWith(playlists: current));
    await _playlistDao.reorderPlaylists(
      current.map((p) => p.playlistId).toList(),
    );
  }
}