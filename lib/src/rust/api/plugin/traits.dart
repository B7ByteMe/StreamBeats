import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'types.dart';

abstract class Plugin {
  Future<void> getName();

  Future<PluginType> getPluginType();
}