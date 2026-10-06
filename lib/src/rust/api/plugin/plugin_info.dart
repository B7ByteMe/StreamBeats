import '../../frb_generated.dart';
import 'manifest.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'types.dart';

abstract class PluginInfo implements RustOpaqueInterface {
  Manifest get manifest;

  String get name;

  String get pluginPath;

  PluginType get pluginType;

  set manifest(Manifest manifest);

  set name(String name);

  set pluginPath(String pluginPath);

  set pluginType(PluginType pluginType);
}