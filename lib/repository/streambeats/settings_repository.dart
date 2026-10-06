import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';

class SettingsRepository {
  final SettingsDAO _settingsDao;

  const SettingsRepository(this._settingsDao);

  Future<void> putSettingStr(String key, String value) =>
      _settingsDao.putSettingStr(key, value);

  Future<String?> getSettingStr(String key, {String? defaultValue}) =>
      _settingsDao.getSettingStr(key, defaultValue: defaultValue);

  Future<Stream<AppSettingsStrDB?>?> watchSettingStr(String key) =>
      _settingsDao.getWatcher4SettingStr(key);

  Future<void> putSettingBool(String key, bool value) =>
      _settingsDao.putSettingBool(key, value);

  Future<bool?> getSettingBool(String key, {bool? defaultValue}) =>
      _settingsDao.getSettingBool(key, defaultValue: defaultValue);

  Future<Stream<AppSettingsBoolDB?>?> watchSettingBool(String key) =>
      _settingsDao.getWatcher4SettingBool(key);
}