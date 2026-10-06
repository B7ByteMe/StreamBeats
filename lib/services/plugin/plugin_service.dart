import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:streambeats/plugins/errors/plugin_exceptions.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/src/rust/api/bridge.dart' as bridge;
import 'package:streambeats/src/rust/api/plugin/commands.dart';
import 'package:streambeats/src/rust/api/plugin/manifest.dart';
import 'package:streambeats/src/rust/api/plugin/plugin.dart';
import 'package:streambeats/src/rust/api/plugin/plugin_info.dart';
import 'package:streambeats/src/rust/api/plugin/types.dart';
import 'package:streambeats/utils/country_info.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PluginService {
  PluginManager? _manager;
  Future<void>? _initializing;

  bool get isInitialized => _manager != null;

  PluginManager get manager {
    final m = _manager;
    if (m == null) {
      throw StateError(
          'PluginService not initialized. Call initialize() first.');
    }
    return m;
  }

  Future<void> initialize({String? pluginsDir}) async {
    if (_manager != null) {
      log('PluginService already initialized', name: 'PluginService');
      return;
    }

    final inFlight = _initializing;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _initializeInternal(pluginsDir: pluginsDir);
    _initializing = future;

    try {
      await future;
    } finally {
      if (identical(_initializing, future)) {
        _initializing = null;
      }
    }
  }

  Future<void> _initializeInternal({String? pluginsDir}) async {
    if (_manager != null) {
      return;
    }

    final dir = pluginsDir ?? await _defaultPluginsDir();

    final pluginDir = Directory(dir);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
      log('Created plugins directory: $dir', name: 'PluginService');
    }

    _manager = await bridge.createPluginManager(pluginsDir: dir);
    log('PluginService initialized (pluginsDir: $dir)', name: 'PluginService');
  }

  Future<String> _defaultPluginsDir() async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  Future<PluginResponse> execute({
    required String pluginId,
    required PluginRequest request,
  }) async {
    try {
      final response = await bridge.handlePluginRequest(
        manager: manager,
        pluginId: pluginId,
        request: request,
      );
      return response;
    } catch (e) {
      throw _mapError(pluginId, e);
    }
  }

  Future<void> loadPlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    try {
      await bridge.loadPlugin(
        manager: manager,
        pluginId: pluginId,
        pluginType: pluginType,
      );
      log('Loaded plugin: $pluginId ($pluginType)', name: 'PluginService');
    } catch (e) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Failed to load plugin: $e',
        cause: e,
      );
    }
  }

  Future<void> unloadPlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    try {
      await bridge.unloadPlugin(
        manager: manager,
        pluginId: pluginId,
        pluginType: pluginType,
      );
      log('Unloaded plugin: $pluginId ($pluginType)', name: 'PluginService');
    } catch (e) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Failed to unload plugin: $e',
        cause: e,
      );
    }
  }

  Future<PluginInstallResult> installPlugin({
    required String packedFilePath,
    bool shouldLoad = true,
    String? policyCountryCode,
  }) async {
    try {
      final packedManifest = await _readPackedManifest(packedFilePath);
      var countryCode =
          CountryInfoService.normalizeCountryCode(policyCountryCode);
      if (countryCode.isEmpty) {
        countryCode = await CountryInfoService.resolveCountryCodeForPolicyCheck(
          settingsDao: SettingsDAO(DBProvider.db),
        );
      }

      if (packedManifest.countryAllowlist.isNotEmpty &&
          (countryCode.isEmpty ||
              !packedManifest.countryAllowlist.contains(countryCode))) {
        throw PluginCountryRestrictedException(
          pluginId: packedManifest.pluginId,
          countryCode: countryCode,
          allowlist: packedManifest.countryAllowlist,
        );
      }

      final tempDir = (await getTemporaryDirectory()).path;
      final pluginsDir = await bridge.getPluginsDir(manager: manager);

      final result = await bridge.installPackedPlugin(
        packedFilePath: packedFilePath,
        pluginsDir: pluginsDir,
        tempDir: tempDir,
        shouldLoad: shouldLoad,
        policyCountryCode: countryCode,
        manager: manager,
      );

      if (result.status == PluginInstallStatus.failed &&
          (result.error?.contains('country') ?? false)) {
        throw PluginCountryRestrictedException(
          pluginId: result.pluginId,
          countryCode: countryCode,
          allowlist: packedManifest.countryAllowlist,
        );
      }

      log('Installed plugin: ${result.pluginId} (status: ${result.status})',
          name: 'PluginService');
      return result;
    } on PluginInstallException {
      rethrow;
    } catch (e) {
      throw PluginInstallException(
        message: 'Failed to install plugin from $packedFilePath: $e',
        cause: e,
      );
    }
  }

  Future<Manifest> inspectPlugin({required String packedFilePath}) async {
    final tempDir = (await getTemporaryDirectory()).path;
    return bridge.inspectPackedPlugin(
      packedFilePath: packedFilePath,
      tempDir: tempDir,
    );
  }

  Future<List<PluginInfo>> getAvailablePlugins() async {
    return bridge.getAvailablePlugins(manager: manager);
  }

  List<String> getLoadedPlugins() {
    return bridge.getLoadedPlugins(manager: manager);
  }

  Future<bool> isPluginLoaded({
    required String pluginId,
    required PluginType pluginType,
  }) {
    return bridge.isPluginLoaded(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
  }

  Future<void> refreshPlugins() async {
    await bridge.refreshAvailablePlugins(manager: manager);
  }

  Future<void> deletePlugin({
    required String pluginId,
    required PluginType pluginType,
  }) async {
    final loaded = await bridge.isPluginLoaded(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
    if (loaded) {
      await unloadPlugin(pluginId: pluginId, pluginType: pluginType);
    }

    final info =
        await getPluginInfo(pluginId: pluginId, pluginType: pluginType);
    if (info == null) {
      throw PluginExecutionException(
        pluginId: pluginId,
        message: 'Cannot delete: plugin not found in available list',
      );
    }

    final pluginDir = Directory(info.pluginPath);
    if (await pluginDir.exists()) {
      await pluginDir.delete(recursive: true);
      log('Deleted plugin directory: ${info.pluginPath}',
          name: 'PluginService');
    }

    await refreshPlugins();
    log('Plugin deleted: $pluginId', name: 'PluginService');
  }

  Future<List<String>> scanBexFiles(String directory) async {
    return bridge.scanBexFiles(directory: directory);
  }

  Future<PluginInfo?> getPluginInfo({
    required String pluginId,
    required PluginType pluginType,
  }) {
    return bridge.getPluginInfo(
      manager: manager,
      pluginId: pluginId,
      pluginType: pluginType,
    );
  }

  Future<void> dispose() async {
    final m = _manager;
    if (m != null) {
      await bridge.shutdownPluginManager(manager: m);
      _manager = null;
    }
    _initializing = null;
    log('PluginService disposed', name: 'PluginService');
  }

  PluginException _mapError(String pluginId, Object error) {
    final message = error.toString();

    final parsed = _parseBridgePluginError(message);
    if (parsed != null) {
      final variant = parsed.variant;
      final detail = parsed.message;

      if (variant == 'PluginNotLoaded') {
        return PluginNotLoadedException(pluginId: pluginId, message: detail);
      }
      if (variant == 'PluginNotFound') {
        return PluginNotFoundException(pluginId: pluginId, message: detail);
      }

      return PluginExecutionException(
        pluginId: pluginId,
        message: detail,
        errorCode: 'PLUGIN_ERROR::$variant',
        cause: error,
      );
    }

    return PluginExecutionException(
      pluginId: pluginId,
      message: 'Command execution failed: $message',
      errorCode: message,
      cause: error,
    );
  }

  _ParsedBridgePluginError? _parseBridgePluginError(String raw) {
    const prefix = 'PLUGIN_ERROR::';
    if (!raw.startsWith(prefix)) return null;

    final withoutPrefix = raw.substring(prefix.length);
    final separatorIndex = withoutPrefix.indexOf('::');
    if (separatorIndex <= 0) return null;

    final variantRaw = withoutPrefix.substring(0, separatorIndex).trim();
    final detail = withoutPrefix.substring(separatorIndex + 2).trim();
    if (variantRaw.isEmpty || detail.isEmpty) return null;

    final canonicalVariant = variantRaw.split('(').first.trim();
    if (canonicalVariant.isEmpty) return null;

    return _ParsedBridgePluginError(
      variant: canonicalVariant,
      message: detail,
    );
  }
}

class _ParsedBridgePluginError {
  final String variant;
  final String message;

  _ParsedBridgePluginError({
    required this.variant,
    required this.message,
  });
}

class _PackedPluginManifest {
  final String pluginId;
  final List<String> countryAllowlist;

  const _PackedPluginManifest({
    required this.pluginId,
    required this.countryAllowlist,
  });
}

Future<_PackedPluginManifest> _readPackedManifest(String packedFilePath) async {
  final bytes = await File(packedFilePath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes, verify: false);
  final manifestFile = archive.files.cast<ArchiveFile?>().firstWhere(
        (file) =>
            file != null &&
            file.isFile &&
            p.basename(file.name).toLowerCase() == 'manifest.json',
        orElse: () => null,
      );

  if (manifestFile == null) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final manifestBytes = manifestFile.content as List<int>;
  if (manifestBytes.isEmpty) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final decoded = jsonDecode(utf8.decode(manifestBytes));
  if (decoded is! Map) {
    return const _PackedPluginManifest(
        pluginId: 'unknown', countryAllowlist: []);
  }

  final json = Map<String, dynamic>.from(decoded);
  final pluginId = json['id']?.toString() ?? 'unknown';
  final countryAllowlist = (json['country_allowlist'] as List<dynamic>? ??
          const [])
      .map(
          (value) => CountryInfoService.normalizeCountryCode(value?.toString()))
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return _PackedPluginManifest(
    pluginId: pluginId,
    countryAllowlist: countryAllowlist,
  );
}