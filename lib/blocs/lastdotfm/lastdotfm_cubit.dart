import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:streambeats/blocs/media_player/streambeats_player_cubit.dart';
import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/core/constants/sentinel_values.dart';
import 'package:streambeats/repository/LastFM/lastfmapi.dart';
import 'package:streambeats/core/constants/cache_keys.dart';
import 'package:streambeats/services/db/dao/cache_dao.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/services/meta_resolver/chart_item_resolver.dart';
import 'package:streambeats/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:streambeats/services/plugin/plugin_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

part 'lastdotfm_state.dart';

class LastdotfmCubit extends Cubit<LastdotfmState> {
  LastFmAPI lastFmAPI = LastFmAPI();
  StreamSubscription? _progressSub;
  StreamBeatsPlayerCubit playerCubit;
  final CacheDAO _cacheDao;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;

  Track _timedTrack = trackNull;

  final Stopwatch _playWatch = Stopwatch();

  bool _scrobbled = false;

  LastdotfmCubit({
    required this.playerCubit,
    required CacheDAO cacheDao,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _cacheDao = cacheDao,
        _settingsDao = settingsDao,
        _pluginService = pluginService,
        super(LastdotfmInitial()) {
    initializeFromDB();
    _startTrackingLoop();
  }

  @override
  Future<void> close() async {
    _progressSub?.cancel();
    super.close();
  }

  void _startTrackingLoop() {
    _progressSub = playerCubit.progressStreams.listen((_) {
      _onProgressTick();
    });
  }

  void _onProgressTick() {
    final player = playerCubit.streambeatsPlayer;
    final current = player.currentMedia;
    final isPlaying = player.engine.playing;

    if (current != _timedTrack) {
      if (!_scrobbled &&
          !isTrackNull(_timedTrack) &&
          _isScrobbleEligible(_timedTrack)) {
        log('Scrobbling (on skip): ${_timedTrack.title}', name: 'Last.FM');
        _scrobbleTrack(_timedTrack);
      }
      _resetTiming(current);
      if (isPlaying) _playWatch.start();
      _sendNowPlaying(current);
      return;
    }

    if (isPlaying) {
      if (!_playWatch.isRunning) _playWatch.start();
      if (!_scrobbled && _isScrobbleEligible(current)) {
        _scrobbled = true;
        log('Scrobbling: ${current.title}', name: 'Last.FM');
        _scrobbleTrack(current);
      }
    } else {
      _playWatch.stop();
    }
  }

  void _resetTiming(Track newTrack) {
    _playWatch
      ..stop()
      ..reset();
    _timedTrack = newTrack;
    _scrobbled = false;
  }

  void _sendNowPlaying(Track track) {
    if (!LastFmAPI.initialized || isTrackNull(track)) return;
    final durationSec = _trackDurationSec(track);
    final entry = ScrobbleTrack(
      artist: track.artists.map((a) => a.name).join(', ').ifEmpty('Unknown'),
      trackName: track.title,
      album: track.album?.title,
      duration: durationSec > 0 ? durationSec : null,
    );
    LastFmAPI.updateNowPlaying(entry).catchError(
      (e) => log('nowPlaying error: $e', name: 'Last.FM'),
    );
  }

  bool _isScrobbleEligible(Track track) {
    if (isTrackNull(track)) return false;
    final durationSec = _trackDurationSec(track);
    if (durationSec > 0 && durationSec <= 30) return false;

    final elapsed = _playWatch.elapsed.inSeconds;
    if (durationSec > 0) {
      final pctThreshold = (durationSec * 0.3).ceil();
      final threshold = pctThreshold.clamp(30, 240);
      return elapsed >= threshold;
    }
    return elapsed >= 30;
  }

  Future<void> _scrobbleTrack(Track track) async {
    final shouldScrobble = await _settingsDao.getSettingBool(
      CacheKeys.lFMScrobbleSetting,
      defaultValue: false,
    );
    if (shouldScrobble != true) return;

    final durationSec = _trackDurationSec(track);
    final entry = ScrobbleTrack(
      artist: track.artists.map((a) => a.name).join(', ').ifEmpty('Unknown'),
      trackName: track.title,
      album: track.album?.title ?? 'Unknown',
      duration: durationSec > 0 ? durationSec : null,
      chosenByUser: false,
    );

    await _appendToCache(entry);

    await _flushCache();
  }

  Future<void> _flushCache() async {
    if (!LastFmAPI.initialized) return;
    final cached = await _readCache();
    if (cached.isEmpty) return;

    try {
      for (var i = 0; i < cached.length; i += 50) {
        final batch = cached.sublist(i, (i + 50).clamp(0, cached.length));
        final ok = await LastFmAPI.scrobble(batch);
        if (!ok) {
          log('Scrobble batch failed (offset $i)', name: 'Last.FM');
          return;
        }
      }
      await _clearCache();
      log('Scrobble cache flushed (${cached.length} tracks)', name: 'Last.FM');
    } catch (e) {
      log('Scrobble failed: $e', name: 'Last.FM');
    }
  }

  Future<void> _appendToCache(ScrobbleTrack entry) async {
    final cached = await _readCache();
    cached.add(entry);
    await _writeCache(cached);
  }

  Future<List<ScrobbleTrack>> _readCache() async {
    final raw = await _cacheDao.getCacheValue(CacheKeys.lFMTrackedCache);
    if (raw == null || raw.isEmpty || raw == 'null') return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ScrobbleTrack.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Corrupt scrobble cache, clearing: $e', name: 'Last.FM');
      await _clearCache();
      return [];
    }
  }

  Future<void> _writeCache(List<ScrobbleTrack> tracks) async {
    final encoded = jsonEncode(tracks.map((t) => t.toMap()).toList());
    await _cacheDao.putCache(CacheKeys.lFMTrackedCache, encoded);
  }

  Future<void> _clearCache() async {
    await _cacheDao.putCache(CacheKeys.lFMTrackedCache, 'null');
  }

  Future<void> initializeFromDB() async {
    log('Getting Last.FM Keys from DB', name: 'Last.FM');
    final username = await _cacheDao.getApiToken(CacheKeys.lFMUsername);
    final apiKey = await _cacheDao.getApiToken(CacheKeys.lFMApiKey);
    final apiSecret = await _cacheDao.getApiToken(CacheKeys.lFMSecret);
    final session = await _cacheDao.getApiToken(CacheKeys.lFMSession);

    if (apiKey != null &&
        apiSecret != null &&
        username != null &&
        apiKey.isNotEmpty &&
        username.isNotEmpty &&
        apiSecret.isNotEmpty) {
      LastFmAPI.setAPIKey(apiKey);
      LastFmAPI.setAPISecret(apiSecret);
      if (session != null && session.isNotEmpty) {
        LastFmAPI.sessionKey = session;
        LastFmAPI.username = username;
        LastFmAPI.initialized = true;
        emit(LastdotfmIntialized(
            apiKey: apiKey,
            apiSecret: apiSecret,
            sessionKey: session,
            username: username));
      }
    }
    await _flushCache();
  }

  Future<void> fetchSessionkey(
      {required String token,
      required String secret,
      required String apiKey}) async {
    try {
      final sessionMap = await LastFmAPI.fetchSessionKey(token);
      final session = sessionMap['key']!;
      final name = sessionMap['name']!;
      _cacheDao.putApiToken(CacheKeys.lFMUsername, name);
      _cacheDao.putApiToken(CacheKeys.lFMSecret, secret);
      _cacheDao.putApiToken(CacheKeys.lFMApiKey, apiKey);
      _cacheDao.putApiToken(CacheKeys.lFMSession, session);

      if (session.isNotEmpty && apiKey.isNotEmpty && secret.isNotEmpty) {
        LastFmAPI.sessionKey = session;
        LastFmAPI.username = name;
        LastFmAPI.initialized = true;
        emit(LastdotfmIntialized(
          apiKey: apiKey,
          apiSecret: secret,
          sessionKey: session,
          username: name,
        ));
      }
    } catch (e) {
      log('Error: $e', name: 'Last.FM');
      emit(LastdotfmFailed(message: e.toString()));
    }
  }

  Future<String> startAuth(
      {required String apiKey, required String secret}) async {
    LastFmAPI.setAPIKey(apiKey);
    LastFmAPI.setAPISecret(secret);
    final token = await LastFmAPI.fetchRequestToken();
    final url = LastFmAPI.getAuthUrl(token);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return token;
  }

  Future<void> remove() async {
    LastFmAPI.initialized = false;
    LastFmAPI.sessionKey = null;
    LastFmAPI.apiKey = null;
    LastFmAPI.apiSecret = null;
    LastFmAPI.username = null;
    emit(LastdotfmInitial());
    _cacheDao.putApiToken(CacheKeys.lFMSecret, '');
    _cacheDao.putApiToken(CacheKeys.lFMApiKey, '');
    _cacheDao.putApiToken(CacheKeys.lFMSession, '');
    _cacheDao.putApiToken(CacheKeys.lFMUsername, '');
  }

  int _trackDurationSec(Track t) {
    final ms = t.durationMs?.toInt();
    return ms != null ? ms ~/ 1000 : 0;
  }

  Future<List<Track>> getRecommendedTracks({
    List<String> resolverPluginIds = const [],
  }) async {
    if (!LastFmAPI.initialized) return [];
    if (resolverPluginIds.isEmpty) return [];

    final Map<String, dynamic> response;
    try {
      response = await LastFmAPI.getUserRecommendedList();
    } catch (e) {
      log('Failed to fetch Last.fm recommended list: $e', name: 'Last.FM');
      return [];
    }

    final playlist = response['playlist'] as List? ?? [];
    if (playlist.isEmpty) return [];

    final resolver = ChartItemResolver(
      resolver: CrossPluginResolver(pluginService: _pluginService),
    );
    final tracks = <Track>[];

    for (final raw in playlist.take(10)) {
      final item = raw as Map<String, dynamic>? ?? {};
      final title = (item['name'] as String? ?? '').trim();
      if (title.isEmpty) continue;

      final artists = (item['artists'] as List? ?? [])
          .map((a) => (a as Map<String, dynamic>?)?['name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      final syntheticTrack = Track(
        id: '',
        title: title,
        artists:
            artists.map((name) => ArtistSummary(id: '', name: name)).toList(),
        thumbnail: const Artwork(
          url: '',
          layout: ImageLayout.square,
        ),
        isExplicit: false,
      );
      final chartItem = ChartItem(
        item: MediaItem_Track(syntheticTrack),
        rank: 0,
        trend: Trend.unknown,
      );

      try {
        final result = await resolver.resolve(
          chartItem: chartItem,
          resolverPluginIds: resolverPluginIds,
        );
        if (result != null) tracks.add(result.resolvedTrack);
      } catch (e) {
        log('Failed to resolve Last.fm track "$title": $e', name: 'Last.FM');
      }
    }

    return tracks;
  }

  Future<String?> getApiToken(String key) async {
    return _cacheDao.getApiToken(key);
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}