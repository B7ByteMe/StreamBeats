import '../../frb_generated.dart';
import 'events.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'plugin_info.dart';
import 'types.dart';

abstract class PluginManager implements RustOpaqueInterface {
  String get pluginsDir;

  set pluginsDir(String pluginsDir);

  Future<List<PluginInfo>> getAvailablePlugins();

  Future<List<String>> getLoadedPlugins();

  Stream<PluginManagerEvent> initEventStream();

  Future<bool> isPluginLoaded(
      {required String pluginId, required PluginType pluginType});

  Future<bool> isPluginLoadedById(
      {required String pluginId, required PluginType pluginType});

  Future<void> loadPlugin({required PluginInfo pluginInfo});

  Future<void> loadPluginById(
      {required String pluginId, required PluginType pluginType});

  Future<void> loadPluginFromPath(
      {required String pluginId,
      required PluginType pluginType,
      required String pluginPath});

  static Future<PluginManager> newInstance({required String pluginsDir}) =>
      RustLib.instance.api
          .crateApiPluginPluginPluginManagerNew(pluginsDir: pluginsDir);

  Future<void> refreshAvailablePlugins();

  Future<void> shutdown();

  Future<void> storageClear({required String pluginId});

  Future<bool> storageDelete({required String pluginId, required String key});

  Future<String?> storageGet({required String pluginId, required String key});

  Future<void> storagePreload(
      {required String pluginId, required String key, required String value});

  Future<bool> storageSet(
      {required String pluginId, required String key, required String value});

  Future<void> unloadPlugin(
      {required String pluginId, required PluginType pluginType});

  Future<void> unloadPluginById(
      {required String pluginId, required PluginType pluginType});
}