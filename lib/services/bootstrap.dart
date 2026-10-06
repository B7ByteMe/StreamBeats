import 'dart:async';
import 'dart:developer';

import 'package:streambeats/core/constants/setting_keys.dart';
import 'package:streambeats/core/di/service_locator.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/services/local_music_service.dart';
import 'package:streambeats/services/plugin_bootstrap_service.dart';
import 'package:streambeats/services/onboarding_service.dart';
import 'package:streambeats/src/rust/frb_generated.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:path_provider/path_provider.dart';

Future<void> bootstrapApp() async {
  await RustLib.init();

  final String appDocPath = (await getApplicationDocumentsDirectory()).path;
  final String appSuppPath = (await getApplicationSupportDirectory()).path;

  await DBProvider.init(
      appSupportPath: appSuppPath, appDocumentsPath: appDocPath);
  DBProvider.scheduleMaintenance();

  await ServiceLocator.setup();

  try {
    await PluginBootstrapService.ensureHostedRepositoriesPresent(
      repositoryService: ServiceLocator.pluginRepositoryService,
    );
  } catch (e) {
    log('Hosted repository reconciliation skipped',
        error: e, name: 'Bootstrap');
  }

  try {
    await ServiceLocator.initializePluginSystem();
    log('Plugin system initialized successfully', name: 'Bootstrap');
  } catch (e, stack) {
    log('Plugin system initialization failed (non-fatal)',
        error: e, stackTrace: stack, name: 'Bootstrap');
  }

  try {
    final settingsDao = SettingsDAO(DBProvider.db);
    final autoScan =
        await settingsDao.getSettingBool(SettingKeys.localMusicAutoScan) ??
            true;
    if (autoScan) {
      unawaited(LocalMusicService.create().scanAndPersist());
    }
  } catch (e) {
    log('Local music auto-scan skipped', error: e, name: 'Bootstrap');
  }

  try {
    final settingsDao = SettingsDAO(DBProvider.db);
    await OnboardingService.checkAndCacheDone(settingsDao);
    await PluginBootstrapService.checkAndCacheDone(settingsDao);
  } catch (e) {
    log('Could not load bootstrap flag (will re-run bootstrap)',
        error: e, name: 'Bootstrap');
  }
}