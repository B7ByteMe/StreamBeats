import 'package:streambeats/repository/LastFM/lastfmapi.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/core/constants/cache_keys.dart';

class ScrobbleRepository {
  final SettingsDAO _settingsDao;

  const ScrobbleRepository(this._settingsDao);

  Future<void> initializeFromStorage() async {
    final apiKey = await _settingsDao.getSettingStr(
      CacheKeys.lFMApiKey,
    );
    final apiSecret = await _settingsDao.getSettingStr(
      CacheKeys.lFMSecret,
    );
    final sessionKey = await _settingsDao.getSettingStr(
      CacheKeys.lFMSession,
    );
    final username = await _settingsDao.getSettingStr(
      CacheKeys.lFMUsername,
    );

    LastFmAPI.initialize(
      apiKey: apiKey,
      apiSecret: apiSecret,
      sessionKey: sessionKey,
    );
    if (username != null) {
      LastFmAPI.setUsername(username);
    }
  }

  Future<void> saveSession({
    required String apiKey,
    required String apiSecret,
    required String sessionKey,
    required String username,
  }) async {
    await _settingsDao.putSettingStr(CacheKeys.lFMApiKey, apiKey);
    await _settingsDao.putSettingStr(CacheKeys.lFMSecret, apiSecret);
    await _settingsDao.putSettingStr(CacheKeys.lFMSession, sessionKey);
    await _settingsDao.putSettingStr(CacheKeys.lFMUsername, username);
  }

  Future<bool> isScrobblingEnabled() async {
    final enabled = await _settingsDao.getSettingBool(
      CacheKeys.lFMScrobbleSetting,
      defaultValue: false,
    );
    return enabled ?? false;
  }

  Future<void> clearSession() async {
    await _settingsDao.putSettingStr(CacheKeys.lFMSession, '');
    await _settingsDao.putSettingStr(CacheKeys.lFMUsername, '');
    LastFmAPI.initialize(apiKey: null, apiSecret: null, sessionKey: null);
  }

  Future<bool> scrobble(List<ScrobbleTrack> tracks) =>
      LastFmAPI.scrobble(tracks);

  Future<String> fetchRequestToken() => LastFmAPI.fetchRequestToken();

  String getAuthUrl(String token) => LastFmAPI.getAuthUrl(token);

  Future<Map<String, String>> fetchSessionKey(String token) =>
      LastFmAPI.fetchSessionKey(token);

  Future<Map<String, dynamic>> getUserRecommendedList() =>
      LastFmAPI.getUserRecommendedList();

  Future<Map<String, dynamic>> getUserMixList() => LastFmAPI.getUserMixList();

  Future<Map<String, dynamic>> getUserLibraryList() =>
      LastFmAPI.getUserLibraryList();
}