import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streambeats/services/player/player_engine.dart';

enum ShortcutIndicatorType {
  volume,
  mute,
  shuffle,
  loop,
  like,
}

class ShortcutIndicatorState {
  final bool isVisible;
  final ShortcutIndicatorType? type;
  final double? volumeLevel;
  final bool? isMuted;
  final bool? isShuffleOn;
  final LoopMode? loopMode;
  final bool? isLiked;

  const ShortcutIndicatorState({
    this.isVisible = false,
    this.type,
    this.volumeLevel,
    this.isMuted,
    this.isShuffleOn,
    this.loopMode,
    this.isLiked,
  });

  ShortcutIndicatorState copyWith({
    bool? isVisible,
    ShortcutIndicatorType? type,
    double? volumeLevel,
    bool? isMuted,
    bool? isShuffleOn,
    LoopMode? loopMode,
    bool? isLiked,
  }) {
    return ShortcutIndicatorState(
      isVisible: isVisible ?? this.isVisible,
      type: type ?? this.type,
      volumeLevel: volumeLevel ?? this.volumeLevel,
      isMuted: isMuted ?? this.isMuted,
      isShuffleOn: isShuffleOn ?? this.isShuffleOn,
      loopMode: loopMode ?? this.loopMode,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  static const hidden = ShortcutIndicatorState(isVisible: false);
}

class ShortcutIndicatorCubit extends Cubit<ShortcutIndicatorState> {
  Timer? _hideTimer;
  static const _displayDuration = Duration(milliseconds: 1200);

  ShortcutIndicatorCubit() : super(ShortcutIndicatorState.hidden);

  void _cancelTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _startHideTimer() {
    _cancelTimer();
    _hideTimer = Timer(_displayDuration, () {
      emit(ShortcutIndicatorState.hidden);
    });
  }

  void showVolume(double level) {
    emit(ShortcutIndicatorState(
      isVisible: true,
      type: ShortcutIndicatorType.volume,
      volumeLevel: level,
      isMuted: level == 0,
    ));
    _startHideTimer();
  }

  void showMute(bool isMuted, double volumeLevel) {
    emit(ShortcutIndicatorState(
      isVisible: true,
      type: ShortcutIndicatorType.mute,
      isMuted: isMuted,
      volumeLevel: isMuted ? 0 : volumeLevel,
    ));
    _startHideTimer();
  }

  void showShuffle(bool isShuffleOn) {
    emit(ShortcutIndicatorState(
      isVisible: true,
      type: ShortcutIndicatorType.shuffle,
      isShuffleOn: isShuffleOn,
    ));
    _startHideTimer();
  }

  void showLoopMode(LoopMode mode) {
    emit(ShortcutIndicatorState(
      isVisible: true,
      type: ShortcutIndicatorType.loop,
      loopMode: mode,
    ));
    _startHideTimer();
  }

  void showLike(bool isLiked) {
    emit(ShortcutIndicatorState(
      isVisible: true,
      type: ShortcutIndicatorType.like,
      isLiked: isLiked,
    ));
    _startHideTimer();
  }

  void hide() {
    _cancelTimer();
    emit(ShortcutIndicatorState.hidden);
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}