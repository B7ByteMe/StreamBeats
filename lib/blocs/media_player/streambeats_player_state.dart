part of 'streambeats_player_cubit.dart';

class StreamBeatsPlayerState {
  bool isReady;
  bool showLyrics;
  StreamBeatsPlayerState({required this.isReady, this.showLyrics = false});
}

final class StreamBeatsPlayerInitial extends StreamBeatsPlayerState {
  StreamBeatsPlayerInitial() : super(isReady: false);
}

class ProgressBarStreams {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool isPlaying;
  ProgressBarStreams({
    required this.position,
    required this.duration,
    required this.buffered,
    required this.isPlaying,
  });
}