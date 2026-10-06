import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

abstract class PluginAdapter {}

class PluginInstallResult {
  final PluginInstallStatus status;
  final String pluginId;
  final String? error;

  const PluginInstallResult({
    required this.status,
    required this.pluginId,
    this.error,
  });

  @override
  int get hashCode => status.hashCode ^ pluginId.hashCode ^ error.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginInstallResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          pluginId == other.pluginId &&
          error == other.error;
}

enum PluginInstallStatus {
  installed,
  updated,

  downgraded,
  alreadyInstalled,
  pluginLoaded,
  failed,
  ;
}

enum PluginType {
  contentResolver,
  chartProvider,
  lyricsProvider,
  searchSuggestionProvider,
  contentImporter,
  ;

  Future<void> description() =>
      RustLib.instance.api.crateApiPluginTypesPluginTypeDescription(
        that: this,
      );

  static Future<PluginType?> fromString({required String s}) =>
      RustLib.instance.api.crateApiPluginTypesPluginTypeFromString(s: s);

  Future<void> typeString() =>
      RustLib.instance.api.crateApiPluginTypesPluginTypeTypeString(
        that: this,
      );
}