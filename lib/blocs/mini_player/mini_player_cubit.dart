import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:streambeats/blocs/media_player/streambeats_player_cubit.dart';
import 'package:streambeats/core/models/exported.dart' hide MediaItem;
import 'package:streambeats/core/adapters/track_adapter.dart';
import 'package:streambeats/services/player/player_engine.dart';
import 'package:rxdart/rxdart.dart';

class MiniPlayerState extends Equatable {
  final Track? track;

  final bool isPlaying;

  final bool isLoading;

  final bool isResolving;

  final bool isCompleted;

  final bool hasError;

  const MiniPlayerState({
    this.track,
    this.isPlaying = false,
    this.isLoading = false,
    this.isResolving = false,
    this.isCompleted = false,
    this.hasError = false,
  });

  bool get isVisible => track != null && track!.id != 'Null';

  const MiniPlayerState.hidden()
      : track = null,
        isPlaying = false,
        isLoading = false,
        isResolving = false,
        isCompleted = false,
        hasError = false;

  MiniPlayerState copyWith({
    Track? track,
    bool? isPlaying,
    bool? isLoading,
    bool? isResolving,
    bool? isCompleted,
    bool? hasError,
  }) {
    return MiniPlayerState(
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isResolving: isResolving ?? this.isResolving,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props =>
      [track, isPlaying, isLoading, isResolving, isCompleted, hasError];
}

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final StreamBeatsPlayerCubit _playerCubit;
  StreamSubscription? _sub;

  MiniPlayerCubit({required StreamBeatsPlayerCubit playerCubit})
      : _playerCubit = playerCubit,
        super(const MiniPlayerState.hidden()) {
    _listen();
  }

  void _listen() {
    _sub = Rx.combineLatest4<MediaItem?, EngineState, bool, bool,
        (MediaItem?, EngineState, bool, bool)>(
      _playerCubit.streambeatsPlayer.mediaItem,
      Rx.defer(() => _playerCubit.streambeatsPlayer.engine.stateStream,
          reusable: true),
      Rx.defer(() => _playerCubit.streambeatsPlayer.engine.playingStream,
          reusable: true),
      _playerCubit.streambeatsPlayer.isResolving,
      (media, engineState, playing, resolving) =>
          (media, engineState, playing, resolving),
    ).listen((record) {
      final (media, engineState, playing, resolving) = record;

      if (media == null || media.id == 'Null') {
        if (state.isVisible) emit(const MiniPlayerState.hidden());
        return;
      }

      final track = mediaItemToTrack(media);

      emit(MiniPlayerState(
        track: track,
        isPlaying: playing,
        isLoading: engineState == EngineState.loading ||
            engineState == EngineState.buffering,
        isResolving: resolving,
        isCompleted: engineState == EngineState.completed,
        hasError: engineState == EngineState.error,
      ));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}