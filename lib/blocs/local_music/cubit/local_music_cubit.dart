import 'dart:developer';
import 'dart:io';

import 'package:streambeats/services/local_music_service.dart';
import 'package:streambeats/src/rust/api/plugin/models.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

part 'local_music_state.dart';

class LocalMusicCubit extends Cubit<LocalMusicState> {
  final LocalMusicService _service;

  LocalMusicCubit({LocalMusicService? service})
      : _service = service ?? LocalMusicService.create(),
        super(const LocalMusicInitial());

  Future<void> load() async {
    if (state is LocalMusicScanning) return;
    emit(const LocalMusicLoading());
    try {
      if (LocalMusicService.isMobile) {
        final granted = await _service.requestPermission();
        if (!granted) {
          emit(const LocalMusicNoPermission());
          return;
        }
      }
      final tracks = await _service.getLocalTracks();
      final folders = await _service.getFolders();
      emit(LocalMusicLoaded(tracks: tracks, folders: folders));
      if (tracks.isEmpty) scan();
    } catch (e, stack) {
      log('load failed: $e\n$stack', name: 'LocalMusicCubit');
      emit(LocalMusicError(e.toString()));
    }
  }

  Future<void> scan() async {
    if (LocalMusicService.isMobile) {
      final granted = await _service.ensureScanPermission();
      if (!granted) {
        emit(const LocalMusicNoPermission());
        return;
      }
    }

    if (state is LocalMusicScanning) return;
    final folders = await _service.getFolders();
    emit(LocalMusicScanning(folders: folders));
    try {
      final tracks = await _service.scanAndPersist();
      emit(LocalMusicLoaded(
        tracks: tracks,
        folders: await _service.getFolders(),
      ));
    } catch (e, stack) {
      log('scan failed: $e\n$stack', name: 'LocalMusicCubit');
      emit(LocalMusicError(e.toString()));
    }
  }

  Future<void> addFolderViaPicker() async {
    if (LocalMusicService.isMobile || Platform.isIOS) return;
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    await _service.addFolder(result);
    await scan();
  }

  Future<void> removeFolder(String path) async {
    await _service.removeFolder(path);
    await scan();
  }

  Future<void> addFolder(String path) async {
    await _service.addFolder(path);
  }

  Future<List<String>> getFolders() => _service.getFolders();

  Future<void> resolvePermissionAction() async {
    if (!LocalMusicService.isMobile) {
      await load();
      return;
    }

    final granted =
        await _service.requestPermission(openSettingsIfDenied: true);
    if (granted) {
      await load();
      return;
    }

    emit(const LocalMusicNoPermission());
  }

  Future<void> deleteTrack(Track track) async {
    await _service.deleteTrack(track);
    await _refreshLoadedTracks();
  }

  Future<List<String>> getUserPlaylistsContainingTrack(String mediaId) {
    return _service.getUserPlaylistsContainingTrack(mediaId);
  }

  Future<void> _refreshLoadedTracks() async {
    final tracks = await _service.getLocalTracks();
    final folders = await _service.getFolders();
    emit(LocalMusicLoaded(tracks: tracks, folders: folders));
  }

  Future<bool> shouldConfirmDelete() => _service.shouldConfirmDelete();

  Future<void> setConfirmDelete(bool value) => _service.setConfirmDelete(value);

  Future<bool> getAutoScan() => _service.getAutoScan();

  Future<void> setAutoScan(bool value) => _service.setAutoScan(value);

  Future<String> getLastScan() => _service.getLastScan();

  Future<void> cleanOrphanedArtwork() => _service.cleanOrphanedArtwork();
}