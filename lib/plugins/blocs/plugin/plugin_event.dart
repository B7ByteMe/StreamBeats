import 'package:streambeats/src/rust/api/plugin/plugin_info.dart';
import 'package:streambeats/src/rust/api/plugin/types.dart';

sealed class PluginEvent {
  const PluginEvent();
}

class LoadPlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;
  const LoadPlugin({required this.pluginId, required this.pluginType});
}

class UnloadPlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;
  const UnloadPlugin({required this.pluginId, required this.pluginType});
}

class InstallPlugin extends PluginEvent {
  final String packedFilePath;
  final bool shouldLoad;
  const InstallPlugin({required this.packedFilePath, this.shouldLoad = true});
}

class RefreshPlugins extends PluginEvent {
  const RefreshPlugins();
}

class PluginSystemEvent extends PluginEvent {
  final dynamic event;
  const PluginSystemEvent(this.event);
}

class InitializePluginSystem extends PluginEvent {
  const InitializePluginSystem();
}

class AutoLoadPlugins extends PluginEvent {
  final List<({String pluginId, PluginType pluginType})> plugins;
  const AutoLoadPlugins({required this.plugins});
}

class LoadPluginFromInfo extends PluginEvent {
  final PluginInfo pluginInfo;
  const LoadPluginFromInfo({required this.pluginInfo});
}

class DeletePlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;

  final bool cleanStorage;
  const DeletePlugin({
    required this.pluginId,
    required this.pluginType,
    this.cleanStorage = true,
  });
}