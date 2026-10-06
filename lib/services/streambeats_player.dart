import 'dart:developer';
import 'dart:async';
import 'dart:convert';

import 'package:streambeats/core/adapters/track_adapter.dart';
import 'package:streambeats/core/models/exported.dart' hide MediaItem;
import 'package:streambeats/core/models/media_playlist_model.dart';
import 'package:streambeats/core/constants/sentinel_values.dart';
import 'package:streambeats/core/constants/setting_keys.dart';
import 'package:streambeats/core/di/service_locator.dart';
import 'package:streambeats/plugins/utils/media_id.dart';
import 'package:streambeats/plugins/errors/plugin_exceptions.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/services/player/media_resolver_service.dart';
import 'package:streambeats/services/player/player_engine.dart';
import 'package:streambeats/services/player/player_error_handler.dart';
import 'package:streambeats/services/player/queue_manager.dart';
import 'package:streambeats/services/player/related_songs_manager.dart';
import 'package:streambeats/services/player/recently_played_tracker.dart';
import 'package:streambeats/services/plugin/plugin_service.dart';
import 'package:streambeats/services/meta_resolver/smart_track_replacement_service.dart';
import 'package:streambeats/services/discord_service.dart';
import 'package:streambeats/services/supabase_party_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:streambeats/routes/app_router.dart';
import 'package:audio_session/audio_session.dart';
import 'package:async/async.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

class StreamBeatsMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late PlayerEngine engine;

  late PlayerErrorHandler _errorHandler;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late RecentlyPlayedTracker _recentlyPlayedTracker;
  late MediaResolverService _resolver;
  late SmartTrackReplacementService _smartTrackReplacementService;

  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);
  BehaviorSubject<bool> isResolving = BehaviorSubject<bool>.seeded(false);

  bool _isDisposed = false;

  CancelableCompleter<void>? _playCompleter;
  CancelableOperation<ResolvedMediaSource>? _preResolveOp;
  CancelableOperation<(Track, ResolvedMediaSource)>? _currentResolveOp;
  bool _isAdvancing = false;

  String? _preloadedTrackId;
  bool _preloadedTrackOffline = false;

  StreamSubscription? _engineStateSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _queueSyncSub;
  StreamSubscription? _positionSuccessSub;
  StreamSubscription<AudioInterruptionEvent>? _audioInterruptionSub;
  StreamSubscription<void>? _audioNoisySub;
  Timer? _relatedSongTimer;

  AudioSession? _audioSession;
  double? _volumeBeforeDuck;
  bool _shouldResumeAfterInterruption = false;

  Duration _savedPositionForRevive = Duration.zero;

  Future<bool> _checkGuestPartyLeave() async {
    if (SupabasePartyService.currentRole != PartyRole.guest) {
      return true;
    }
    final context = AppRouter.globalRouterKey.currentContext;
    if (context == null) return false;

    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Room?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Anda sedang berada di dalam room bersama. Apakah Anda ingin keluar dari room untuk mengontrol musik sendiri?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purpleAccent,
            ),
            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      await SupabasePartyService.leaveParty();
      SnackbarService.showMessage('Meninggalkan party.');
      return true;
    }
    return false;
  }

  BehaviorSubject<bool> get shuffleMode => _queueManager.shuffleMode;
  BehaviorSubject<PlayerError?> get lastError => _errorHandler.lastError;
  BehaviorSubject<List<Track>> get relatedSongs =>
      _relatedSongsManager.relatedSongs;

  @override
  BehaviorSubject<String> get queueTitle => _queueManager.queueTitle;

  Track _currentTrack = trackNull;
  Track get currentTrackInfo => _currentTrack;
  List<Track> get queueTracks => List<Track>.unmodifiable(_queueManager.tracks);
  int get currentQueueIndex => _queueManager.currentIndex;
  PluginService get pluginService => ServiceLocator.pluginService;

  StreamBeatsMusicPlayer() {
    _initEngine();
    _initModules();
    _initSubscriptions();
    _setupInterruptionListeners();
    _restoreEngineSettings();
    _restoreLastSession();
  }

  Future<void> _restoreLastSession() async {
    if (_isDisposed) return;
    try {
      final restored = await _queueManager.restoreQueueState();
      if (_isDisposed) return; // re-check after await
      if (restored) {
        final track = _queueManager.currentTrack;
        if (track != null) {
          _updateCurrentTrack(track);
        }
      }
    } catch (e) {
      log('Session restore failed: $e', name: 'StreamBeatsMusicPlayer');
    }
  }

  void _initEngine() {
    _isDisposed = false;
    engine = PlayerEngine();
  }

  void _setupInterruptionListeners() {
    AudioSession.instance.then((session) {
      if (_isDisposed) return;
      _audioSession = session;

      _audioInterruptionSub?.cancel();
      _audioNoisySub?.cancel();

      _audioInterruptionSub =
          session.interruptionEventStream.listen(_handleInterruptionSync);

      _audioNoisySub = session.becomingNoisyEventStream
          .listen((_) => _onHeadphonesUnplugged());
    });
  }

  void _handleInterruptionSync(AudioInterruptionEvent event) {
    if (_isDisposed) return;

    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _volumeBeforeDuck ??= engine.volume;
          engine.setVolume((engine.volume * 0.35).clamp(0.0, 1.0));

        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          _shouldResumeAfterInterruption = engine.playing;
          engine.pause(); // fire-and-forget — engine queues the command
      }
      return;
    }

    switch (event.type) {
      case AudioInterruptionType.duck:
        final prev = _volumeBeforeDuck;
        _volumeBeforeDuck = null;
        if (prev != null) engine.setVolume(prev.clamp(0.0, 1.0));

      case AudioInterruptionType.pause:
        if (_shouldResumeAfterInterruption) {
          _shouldResumeAfterInterruption = false;
          _resumePlaybackAfterInterruption();
        }

      case AudioInterruptionType.unknown:
        _shouldResumeAfterInterruption = false;
    }
  }

  void _resumePlaybackAfterInterruption() {
    _activateAudioSession().then((granted) {
      if (granted && !_isDisposed) engine.play();
    }).catchError((Object e) {
      log('Resume after interruption failed: $e', name: 'StreamBeatsMusicPlayer');
    });
  }

  void _onHeadphonesUnplugged() {
    if (!_isDisposed) engine.pause();
  }

  Future<bool> _activateAudioSession() async {
    try {
      final session = _audioSession ?? await AudioSession.instance;
      _audioSession = session;
      return await session.setActive(true);
    } catch (e) {
      log('setActive(true) failed: $e', name: 'StreamBeatsMusicPlayer');
      return false;
    }
  }

  Future<void> _deactivateAudioSession() async {
    try {
      await _audioSession?.setActive(false);
    } catch (_) {}
  }

  Future<void> _restoreEngineSettings() async {
    try {
      final dao = SettingsDAO(DBProvider.db);

      final cfStr = await dao.getSettingStr(SettingKeys.crossfadeDuration);
      engine.crossfadeDuration =
          Duration(seconds: int.tryParse(cfStr ?? '0') ?? 0);

      final eqSource = await dao.getSettingStr(SettingKeys.eqSource);
      if (eqSource == EqSourceValues.device) {
        await engine.setEqualizerEnabled(false);
        return;
      }

      final gainsJson = await dao.getSettingStr(SettingKeys.eqBandGains);
      if (gainsJson != null) {
        try {
          final gains = (jsonDecode(gainsJson) as List)
              .map((e) => (e as num).toDouble())
              .toList();
          if (gains.length == 10) {
            await engine.setEqualizerBandGains(gains, immediate: true);
          }
        } catch (_) {}
      }

      final eqOn = await dao.getSettingBool(SettingKeys.eqEnabled) ?? false;
      await engine.setEqualizerEnabled(eqOn);
    } catch (e) {
      log('restoreEngineSettings failed: $e', name: 'StreamBeatsMusicPlayer');
    }
  }

  void _initModules() {
    _errorHandler = PlayerErrorHandler();
    _queueManager = QueueManager();
    _relatedSongsManager = RelatedSongsManager(ServiceLocator.pluginService);
    _resolver = MediaResolverService.create(ServiceLocator.pluginService);
    _smartTrackReplacementService =
        SmartTrackReplacementService.create(ServiceLocator.pluginService);

    _errorHandler.onSkipToNext = _internalSkipToNext;
    _errorHandler.onRetryCurrentTrack = _retryCurrentTrack;
    _errorHandler.onStopPlayback = () async {
      _playCompleter?.operation.cancel();
      _playCompleter = null;
      _currentResolveOp?.cancel();
      _preResolveOp?.cancel();
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        playing: false,
      ));
      await engine.stop();
      DiscordService.clearPresence();
    };

    _relatedSongsManager.onAddQueueItems =
        (items, {bool atLast = false}) => addQueueTracks(items, atLast: atLast);

    _recentlyPlayedTracker = RecentlyPlayedTracker(
      engine,
      () => _queueManager.currentTrack,
    );

    SupabasePartyService.onTrackPlay = (track) {
      if (SupabasePartyService.currentRole == PartyRole.guest) {
        _enqueuePlayTrack(track, doPlay: true);
      }
    };
    SupabasePartyService.onPause = () {
      if (SupabasePartyService.currentRole == PartyRole.guest) {
        engine.pause();
      }
    };
    SupabasePartyService.onResume = () {
      if (SupabasePartyService.currentRole == PartyRole.guest) {
        engine.play();
      }
    };
    SupabasePartyService.onSeek = (pos) {
      if (SupabasePartyService.currentRole == PartyRole.guest) {
        engine.seek(pos);
      }
    };
  }

  void _initSubscriptions() {
    _engineStateSub = Rx.combineLatest4(
      engine.stateStream,
      engine.playingStream,
      engine.bufferedStream,
      engine.speedStream,
      (s, pl, buf, spd) => (s, pl, buf, spd),
    ).distinct().listen((r) {
      final (s, pl, buf, spd) = r;
      _broadcastPlaybackState(s, pl, engine.position, buf, spd);
    });

    _positionSuccessSub = engine.positionStream.listen((pos) {
      if (pos > Duration.zero &&
          engine.state == EngineState.ready &&
          engine.playing) {
        final track = _queueManager.currentTrack;
        if (track != null) _errorHandler.markTrackSuccess(track.id);
      }
    });

    _completionSub = engine.completionStream.listen((_) => _onTrackCompleted());

    _errorSub = engine.errorStream.listen((error) {
      log('Engine error: $error', name: 'StreamBeatsMusicPlayer');
      final track = _queueManager.currentTrack;
      if (track != null) {
        _errorHandler.handleError(PlayerErrorType.playbackError, error, track);
      }
    });

    _queueSyncSub = _queueManager.tracksStream.listen((tracks) {
      queue.add(tracks.map(trackToMediaItem).toList());
      if (_queueManager.isRestoring) return;
      EasyThrottle.throttle(
        'persist_queue',
        const Duration(seconds: 2),
        () => unawaited(_queueManager.persistQueueState()),
      );
    });

    _relatedSongTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isDisposed && engine.playing) _checkRelatedSongs();
    });
  }

  void _broadcastPlaybackState(EngineState state, bool playing,
      Duration position, Duration buffered, double speed) {
    final processingState = switch (state) {
      EngineState.idle => AudioProcessingState.idle,
      EngineState.loading => AudioProcessingState.loading,
      EngineState.buffering => AudioProcessingState.buffering,
      EngineState.ready => AudioProcessingState.ready,
      EngineState.completed => AudioProcessingState.completed,
      EngineState.error => AudioProcessingState.error,
    };

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      processingState: processingState,
      systemActions: const {
        MediaAction.skipToPrevious,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: position,
      updateTime: DateTime.now(),
      playing: playing,
      bufferedPosition: buffered,
      speed: speed,
    ));

    EasyThrottle.throttle('discord_rpc', const Duration(seconds: 1), () {
      DiscordService.updatePresence(
          track: currentTrackInfo, isPlaying: playing);
    });
  }

  Track get currentMedia => _queueManager.currentTrack ?? trackNull;

  void _updateCurrentTrack(Track track) {
    _currentTrack = track;
    mediaItem.add(trackToMediaItem(track));
  }

  @override
  Future<void> play() async {
    if (!await _checkGuestPartyLeave()) return;
    SupabasePartyService.broadcastResume();
    if (_isDisposed) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    final granted = await _activateAudioSession();
    if (!granted) {
      SnackbarService.showMessage('Audio focus denied. Cannot start playback.');
      return;
    }
    if (engine.state == EngineState.idle) {
      final track = _queueManager.currentTrack;
      if (track != null) {
        await _enqueuePlayTrack(track, doPlay: true);
        return;
      }
    }
    await engine.play();
  }

  @override
  Future<void> pause() async {
    if (!await _checkGuestPartyLeave()) return;
    SupabasePartyService.broadcastPause();
    if (_isDisposed) return;
    _shouldResumeAfterInterruption = false;
    await engine.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    if (!await _checkGuestPartyLeave()) return;
    SupabasePartyService.broadcastSeek(position);
    if (_isDisposed) return;
    await engine.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    if (_isDisposed) return;
    final dur = engine.duration;
    await engine.seek(engine.position + n > dur ? dur : engine.position + n);
  }

  Future<void> seekNSecBackward(Duration n) async {
    if (_isDisposed) return;
    final back = engine.position - n;
    await engine.seek(back < Duration.zero ? Duration.zero : back);
  }

  @override
  Future<void> stop() async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    _playCompleter?.operation.cancel();
    _playCompleter = null;
    _preResolveOp?.cancel();
    _currentResolveOp?.cancel();
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.idle));
    await engine.stop();
    await _deactivateAudioSession();
    DiscordService.clearPresence();
    await super.stop();
  }

  @override
  Future<void> rewind() async {
    if (_isDisposed) return;
    if (engine.state == EngineState.ready ||
        engine.state == EngineState.buffering) {
      await engine.seek(Duration.zero);
    } else if (engine.state == EngineState.completed) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  void setLoopMode(LoopMode mode) {
    loopMode.add(mode);
    engine.setLoopMode(mode);
  }

  void setCrossfadeDuration(Duration duration) {
    engine.crossfadeDuration = duration;
  }

  Future<void> shuffle(bool enabled) async {
    _queueManager.shuffle(enabled);
  }

  void _clearPreloadedMarker() {
    _preloadedTrackId = null;
    _preloadedTrackOffline = false;
  }

  Future<void> _enqueuePlayTrack(
    Track track, {
    bool doPlay = true,
    Duration? initialPosition,
  }) {
    if (_isDisposed) return Future.value();

    final prev = _playCompleter;
    final completer = CancelableCompleter<void>(
      onCancel: () => log('Track load cancelled: ${track.title}',
          name: 'StreamBeatsMusicPlayer'),
    );
    _playCompleter = completer;
    prev?.operation.cancel();

    _doPlay(track, completer, doPlay: doPlay, initialPosition: initialPosition);
    return completer.operation.valueOrCancellation().then((_) {});
  }

  Future<void> _doPlay(
    Track track,
    CancelableCompleter<void> token, {
    bool doPlay = true,
    Duration? initialPosition,
  }) async {
    bool alive() => !token.isCanceled && !_isDisposed;
    void complete() {
      if (!token.isCompleted && !token.isCanceled) token.complete();
    }

    if (!alive()) return;

    var resolvedTrack = track;
    final canUsePreloaded = engine.isPreloaded &&
        _preloadedTrackId != null &&
        _preloadedTrackId == track.id;

    try {
      _updateCurrentTrack(track);
      SupabasePartyService.broadcastPlayTrack(track);

      if (doPlay) {
        final granted = await _activateAudioSession();
        if (!alive()) return;
        if (!granted) {
          SnackbarService.showMessage(
              'Audio focus denied. Cannot start playback.');
          return complete();
        }
      }

      _currentResolveOp?.cancel();
      engine.setLoadingState();
      isResolving.add(true);

      EngineResult result;

      if (canUsePreloaded) {
        isOffline.add(_preloadedTrackOffline);
        result = engine.crossfadeDuration > Duration.zero
            ? await engine.crossfadeToPreloaded(engine.crossfadeDuration)
            : await engine.activatePreloaded(autoPlay: doPlay);
        _clearPreloadedMarker();
      } else {
        await engine.stop(keepLoadingState: true);
        if (!alive()) return;

        _currentResolveOp = CancelableOperation.fromFuture(
          _resolveWithFallback(track).timeout(const Duration(seconds: 15)),
        );
        final resolved = await _currentResolveOp!.valueOrCancellation();
        if (resolved == null || !alive()) return;

        resolvedTrack = resolved.$1;
        if (resolvedTrack.id != track.id) _updateCurrentTrack(resolvedTrack);
        isOffline.add(resolved.$2.isOffline);

        result = await engine.openDirect(
          resolved.$2.uri,
          httpHeaders: resolved.$2.headers,
          autoPlay: doPlay,
        );
      }

      if (!alive()) return;

      if (result is EngineFailure) {
        isResolving.add(false);
        _errorHandler.handleError(
          _errorHandler.categorizeError(result.error),
          result.error.toString(),
          resolvedTrack,
          result.error,
        );
        return complete();
      }

      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      isResolving.add(false);
      _errorHandler.clearError();
      _preResolveNextTrack();
      _checkRelatedSongs();
      complete();
    } on TimeoutException catch (e) {
      isResolving.add(false);
      if (!alive()) return;
      _errorHandler.handleError(
          PlayerErrorType.networkDropped, 'Network timeout', track, e);
      complete();
    } catch (e, stack) {
      isResolving.add(false);
      if (!alive()) return;
      log('Play failed: ${track.title}: $e',
          name: 'StreamBeatsMusicPlayer', stackTrace: stack);
      _errorHandler.handleError(
          _errorHandler.categorizeError(e), e.toString(), resolvedTrack, e);
      complete();
    }
  }

  Future<(Track, ResolvedMediaSource)> _resolveWithFallback(Track track) async {
    try {
      return (track, await _resolver.resolve(track));
    } catch (e) {
      final replacement = await _tryAutoReplace(track, e);
      if (replacement == null) rethrow;
      return (replacement, await _resolver.resolve(replacement));
    }
  }

  Future<Track?> _tryAutoReplace(Track track, Object error) async {
    if (!_isAutoResolvableError(error) || isLocalMediaId(track.id)) return null;
    final enabled = await SettingsDAO(DBProvider.db)
        .getSettingBool(SettingKeys.autoResolveUnavailableTracks);
    if (enabled == false) return null;
    final candidate =
        await _smartTrackReplacementService.findBestReplacement(track);
    if (candidate == null) return null;
    SnackbarService.showMessage(
      'Playing fallback source for ${track.title} from ${candidate.pluginName}.',
      duration: const Duration(seconds: 3),
    );
    return candidate.track;
  }

  bool _isAutoResolvableError(Object error) {
    if (error is PluginNotLoadedException || error is PluginNotFoundException) {
      return true;
    }
    final msg = error.toString().toLowerCase();
    return msg.contains('no streams returned') ||
        msg.contains('plugin is not loaded') ||
        msg.contains('plugin not found');
  }

  void _preResolveNextTrack() {
    final next = _queueManager.peekNext(loopMode: loopMode.value);
    if (next == null) {
      _clearPreloadedMarker();
      engine.clearPreload(); // ignore: discarded_futures
      return;
    }

    final expectedId = next.id;
    _preResolveOp?.cancel();
    _preResolveOp = CancelableOperation.fromFuture(_resolver.resolve(next));
    _preResolveOp!.value.then((resolved) async {
      if (_isDisposed) return;
      if (_queueManager.peekNext(loopMode: loopMode.value)?.id != expectedId) {
        _clearPreloadedMarker();
        engine.clearPreload(); // ignore: discarded_futures
        return;
      }
      final ok =
          await engine.preloadNext(resolved.uri, httpHeaders: resolved.headers);
      if (!_isDisposed && ok) {
        _preloadedTrackId = expectedId;
        _preloadedTrackOffline = resolved.isOffline;
      }
    }).catchError((Object _) {
      _clearPreloadedMarker();
      engine.clearPreload(); // ignore: discarded_futures
    });
  }

  void _onTrackCompleted() {
    if (loopMode.value == LoopMode.one || _isAdvancing) return;
    if (SupabasePartyService.currentRole == PartyRole.guest) return; // Wait for Host's broadcast
    _isAdvancing = true;
    Future.microtask(() async {
      try {
        final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
        if (advanced) {
          final next = _queueManager.currentTrack;
          if (next != null) await _enqueuePlayTrack(next, doPlay: true);
        } else {
          await engine.stop();
        }
      } finally {
        _isAdvancing = false;
      }
    });
  }

  Future<void> _retryCurrentTrack() async {
    final track = _queueManager.currentTrack;
    if (track == null) return;
    _errorHandler.clearError();
    await _enqueuePlayTrack(track,
        doPlay: true, initialPosition: engine.position);
  }

  bool _checkingRelated = false;

  Future<void> _checkRelatedSongs() async {
    if (_checkingRelated) return;
    _checkingRelated = true;
    try {
      final track = _queueManager.currentTrack;
      if (track == null) return;
      await _relatedSongsManager.checkForRelatedSongs(
        currentMedia: track,
        queue: _queueManager.tracks,
        currentPlayingIdx: _queueManager.currentIndex,
        loopMode: loopMode.value,
      );
    } finally {
      _checkingRelated = false;
    }
  }

  Future<void> check4RelatedSongs() => _checkRelatedSongs();

  bool get isPlayerHealthy {
    if (_isDisposed) return false;
    if (fromPlaylist.isClosed ||
        isOffline.isClosed ||
        loopMode.isClosed ||
        isResolving.isClosed) return false;
    try {
      final _ = engine.state;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> revive() async {
    if (!_isDisposed && isPlayerHealthy) return;
    log('Reviving StreamBeatsMusicPlayer...', name: 'StreamBeatsMusicPlayer');

    try {
      _savedPositionForRevive = engine.position;
    } catch (_) {}

    if (fromPlaylist.isClosed)
      fromPlaylist = BehaviorSubject<bool>.seeded(false);
    if (isOffline.isClosed) isOffline = BehaviorSubject<bool>.seeded(false);
    if (loopMode.isClosed)
      loopMode = BehaviorSubject<LoopMode>.seeded(LoopMode.off);
    if (isResolving.isClosed) isResolving = BehaviorSubject<bool>.seeded(false);

    _shouldResumeAfterInterruption = false;

    _initEngine();
    _initModules();
    _initSubscriptions();
    _setupInterruptionListeners();
    _restoreEngineSettings();
    _isDisposed = false;

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    final track = _queueManager.currentTrack;
    if (track != null) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (!_isDisposed) {
          await _enqueuePlayTrack(track,
              doPlay: false, initialPosition: _savedPositionForRevive);
        }
      });
    }
  }

  void syncPublicState() {
    if (_isDisposed) return;
    queue.add(_queueManager.tracks.map(trackToMediaItem).toList());
    final current = _queueManager.currentTrack;
    if (current != null) _updateCurrentTrack(current);
    _broadcastPlaybackState(
      engine.state,
      engine.playing,
      engine.position,
      engine.buffered,
      engine.speed,
    );
  }

  Future<void> replaceTrackInQueue(Track replacement) async {
    if (_isDisposed) return;
    final changed = _queueManager.replaceTrackById(replacement.id, replacement);
    if (!changed) return;
    if (_currentTrack.id == replacement.id) _updateCurrentTrack(replacement);
  }

  @override
  Future<void> playMediaItem(MediaItem mi,
      {bool doPlay = true, Duration? initialPosition}) async {
    if (!await _checkGuestPartyLeave()) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    await _enqueuePlayTrack(mediaItemToTrack(mi),
        doPlay: doPlay, initialPosition: initialPosition);
  }

  @override
  Future<void> skipToNext() async {
    if (!await _checkGuestPartyLeave()) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    await _internalSkipToNext();
  }

  Future<void> _internalSkipToNext() async {
    _isAdvancing = true;
    try {
      final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
      if (advanced) {
        final next = _queueManager.currentTrack;
        if (next != null) await _enqueuePlayTrack(next, doPlay: true);
      } else {
        _playCompleter?.operation.cancel();
        _playCompleter = null;
        _currentResolveOp?.cancel();
        await engine.stop();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (!await _checkGuestPartyLeave()) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    await _internalSkipToPrevious();
  }

  Future<void> _internalSkipToPrevious() async {
    _isAdvancing = true;
    try {
      final advanced =
          _queueManager.advanceToPrevious(loopMode: loopMode.value);
      if (advanced) {
        final prev = _queueManager.currentTrack;
        if (prev != null) await _enqueuePlayTrack(prev, doPlay: true);
      } else {
        _playCompleter?.operation.cancel();
        _playCompleter = null;
        await engine.stop();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (!await _checkGuestPartyLeave()) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    _isAdvancing = true;
    try {
      _queueManager.jumpTo(index);
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    } finally {
      _isAdvancing = false;
    }
  }

  Future<void> loadPlaylist(
    Playlist playlist, {
    int idx = 0,
    bool doPlay = false,
    bool shuffling = false,
  }) async {
    if ((doPlay || shuffling) && !await _checkGuestPartyLeave()) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    _isAdvancing = true;
    try {
      fromPlaylist.add(true);
      _relatedSongsManager.clearRelatedSongs();
      _clearPreloadedMarker();

      final trackToPlay = (idx >= 0 && idx < playlist.tracks.length)
          ? playlist.tracks[idx]
          : null;

      final sanitized = playlist.tracks
          .where((t) => t.id.trim().isNotEmpty && t.title.trim().isNotEmpty)
          .toList();

      if (sanitized.isEmpty) {
        SnackbarService.showMessage('This section has no playable tracks.',
            duration: const Duration(seconds: 2));
        return;
      }

      int newIdx = 0;
      if (trackToPlay != null) {
        final pos = sanitized.indexWhere((t) => t.id == trackToPlay.id);
        newIdx = pos != -1 ? pos : 0;
      }

      _queueManager.loadTracks(sanitized,
          playlistName: playlist.title, idx: newIdx, shuffling: shuffling);
      queueTitle.add(playlist.title);

      if (doPlay || shuffling) {
        final track = _queueManager.currentTrack;
        if (track != null) await _enqueuePlayTrack(track, doPlay: true);
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mi) async =>
      _queueManager.addTrack(mediaItemToTrack(mi));

  Future<void> addQueueTrack(Track track) async =>
      _queueManager.addTrack(track);

  @override
  Future<void> addQueueItems(List<MediaItem> items,
          {String queueName = 'Queue', bool atLast = false}) async =>
      _queueManager.addTracks(items.map(mediaItemToTrack).toList(),
          atLast: atLast);

  Future<void> addQueueTracks(List<Track> tracks,
          {bool atLast = false}) async =>
      _queueManager.addTracks(tracks, atLast: atLast);

  Future<void> updateQueueTracks(List<Track> tracks,
      {bool doPlay = false, int startIndex = 0}) async {
    if (doPlay && !await _checkGuestPartyLeave()) return;
    _queueManager.updateQueue(tracks, startIndex: startIndex);
    if (doPlay) {
      final t = _queueManager.currentTrack;
      if (t != null) await _enqueuePlayTrack(t, doPlay: true);
    }
  }

  Future<void> addPlayNextItem(MediaItem item) async =>
      _queueManager.addPlayNext(mediaItemToTrack(item));

  Future<void> addPlayNextTrack(Track track) async =>
      _queueManager.addPlayNext(track);

  @override
  Future<void> insertQueueItem(int index, MediaItem mi) async =>
      _queueManager.insertTrack(index, mediaItemToTrack(mi));

  @override
  Future<void> removeQueueItemAt(int index) async =>
      _queueManager.removeTrackAt(index);

  Future<void> moveQueueItem(int oldIndex, int newIndex) async =>
      _queueManager.moveTrack(oldIndex, newIndex);

  void clearQueue() {
    _clearPreloadedMarker();
    _queueManager.clearQueue();
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue,
      {bool doPlay = false}) async {
    if (doPlay && !await _checkGuestPartyLeave()) return;
    _queueManager.updateQueue(newQueue.map(mediaItemToTrack).toList());
    if (doPlay) {
      final t = _queueManager.currentTrack;
      if (t != null) await _enqueuePlayTrack(t, doPlay: true);
    }
  }

  void setRecentlyPlayedThresholdSeconds(int s) =>
      _recentlyPlayedTracker.setThresholdSeconds(s);

  void setRecentlyPlayedPercentThreshold(double p) =>
      _recentlyPlayedTracker.setPercentThreshold(p);

  @override
  Future<void> onTaskRemoved() async {
    await _queueManager.persistQueueState();
    if (!engine.playing) {
      await stop();
      await _cleanup();
    }
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
    return super.onNotificationDeleted();
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _playCompleter?.operation.cancel();
    _playCompleter = null;
    _preResolveOp?.cancel();
    _currentResolveOp?.cancel();

    _relatedSongTimer?.cancel();
    _relatedSongTimer = null;

    await Future.wait([
      _engineStateSub?.cancel() ?? Future.value(),
      _completionSub?.cancel() ?? Future.value(),
      _errorSub?.cancel() ?? Future.value(),
      _queueSyncSub?.cancel() ?? Future.value(),
      _positionSuccessSub?.cancel() ?? Future.value(),
      _audioInterruptionSub?.cancel() ?? Future.value(),
      _audioNoisySub?.cancel() ?? Future.value(),
    ]);

    _errorHandler.dispose();
    _queueManager.dispose();
    _relatedSongsManager.dispose();
    await _recentlyPlayedTracker.dispose();

    DiscordService.clearPresence();
    try {
      await engine.dispose();
    } catch (_) {}
    await _deactivateAudioSession();

    fromPlaylist.add(false);
    isOffline.add(false);
    loopMode.add(LoopMode.off);

    await super.stop();
  }
}