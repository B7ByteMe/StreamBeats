import 'package:streambeats/services/streambeats_player.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
part 'streambeats_player_state.dart';

class StreamBeatsPlayerCubit extends Cubit<StreamBeatsPlayerState> {
  final StreamBeatsMusicPlayer streambeatsPlayer;
  late ValueStream<ProgressBarStreams> progressStreams;

  StreamBeatsPlayerCubit(this.streambeatsPlayer)
      : super(StreamBeatsPlayerState(isReady: true)) {
    streambeatsPlayer.syncPublicState();
    _setupProgressStreams();
  }

  void switchShowLyrics({bool? value}) {
    emit(StreamBeatsPlayerState(
        isReady: true, showLyrics: value ?? !state.showLyrics));
  }

  void _setupProgressStreams() {
    progressStreams = Rx.combineLatest4(
      Rx.defer(() => streambeatsPlayer.engine.positionStream, reusable: true),
      Rx.defer(() => streambeatsPlayer.engine.durationStream, reusable: true),
      Rx.defer(() => streambeatsPlayer.engine.bufferedStream, reusable: true),
      Rx.defer(() => streambeatsPlayer.engine.playingStream, reusable: true),
      (Duration position, Duration duration, Duration buffered, bool playing) =>
          ProgressBarStreams(
        position: position,
        duration: duration,
        buffered: buffered,
        isPlaying: playing,
      ),
    ).shareValueSeeded(
      ProgressBarStreams(
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> close() {
    return super.close();
  }
}