library service_locator;

import 'package:streambeats/services/cache/plugin_cache_repository.dart';
import 'package:streambeats/services/cache/plugin_cache_store.dart';
import 'package:streambeats/services/cache/plugin_cache_writer.dart';
import 'package:streambeats/services/db/dao/cache_dao.dart';
import 'package:streambeats/services/db/dao/plugin_storage_dao.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/services/plugin/plugin_event_bus.dart';
import 'package:streambeats/services/plugin/plugin_service.dart';
import 'package:streambeats/services/plugin/plugin_storage_service.dart';
import 'package:streambeats/plugins/services/plugin_repository_service.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';

class ServiceLocator {
  ServiceLocator._();

  static bool _initialized = false;

  static late final PluginService pluginService;
  static late final PluginEventBus pluginEventBus;
  static late final PluginStorageService pluginStorageService;
  static late final PluginStorageDao pluginStorageDao;
  static late final CacheDAO cacheDAO;
  static late final PluginCacheRepository pluginCache;
  static late final PluginRepositoryService pluginRepositoryService;

  static Future<void> setup() async {
    if (_initialized) return;
    _initialized = true;

    pluginStorageDao = PluginStorageDao(DBProvider.db);

    cacheDAO = CacheDAO(DBProvider.db);

    pluginCache = PluginCacheRepository(
      store: PluginCacheStore(),
      cacheDao: cacheDAO,
      writer: PluginCacheWriter(cacheDAO),
    );

    pluginRepositoryService =
        PluginRepositoryService(settingsDao: SettingsDAO(DBProvider.db));

    pluginEventBus = PluginEventBus.instance;

    pluginStorageService = PluginStorageService(
      dao: pluginStorageDao,
      eventBus: pluginEventBus,
    );

    pluginService = PluginService();
  }

  static Future<void> initializePluginSystem() async {
    await pluginService.initialize();

    pluginEventBus.connect(pluginService.manager);

    await pluginStorageService.preloadAll(pluginService.manager);

    pluginStorageService.startListening();
  }

  static Future<void> disposePluginSystem() async {
    pluginStorageService.dispose();
    pluginEventBus.dispose();
    await pluginService.dispose();
  }
}