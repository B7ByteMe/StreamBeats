import 'package:streambeats/services/streambeats_player.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';

Future<void> setupAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowAirPlay,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    avAudioSessionRouteSharingPolicy:
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    androidWillPauseWhenDucked: false,
  ));
}

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() => _instance;
  PlayerInitializer._internal();

  StreamBeatsMusicPlayer? _player;
  Future<StreamBeatsMusicPlayer>? _initFuture;

  Future<StreamBeatsMusicPlayer> getStreamBeatsMusicPlayer() async {
    final p = _player;
    if (p != null) {
      if (!p.isPlayerHealthy) await p.revive();
      return p;
    }

    final running = _initFuture;
    if (running != null) return running;

    _initFuture = _initializeInternal();
    try {
      return await _initFuture!;
    } finally {
      _initFuture = null;
    }
  }

  Future<StreamBeatsMusicPlayer> _initializeInternal() async {
    final player = await AudioService.init(
      builder: () => StreamBeatsMusicPlayer(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.StreamBeatsPlayer.notification.status',
        androidNotificationChannelName: 'BloomeTunes',
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidResumeOnClick: true,
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: false,
        notificationColor: Default_Theme.accentColor2,
      ),
    );
    _player = player;
    return player;
  }
}