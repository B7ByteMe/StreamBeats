import 'package:equatable/equatable.dart';
import 'package:streambeats/src/rust/api/plugin/plugin_info.dart';
import 'package:streambeats/src/rust/api/plugin/types.dart';

enum PluginOperation {
  loading,
  unloading,
  installing,
  deleting,
}

class PluginState extends Equatable {
  final List<PluginInfo> availablePlugins;

  final Set<String> loadedPluginIds;

  final bool isInitialized;

  final bool isLoading;

  final Map<String, PluginOperation> pluginOperations;

  final String? error;

  final String? successMessage;

  const PluginState({
    this.availablePlugins = const [],
    this.loadedPluginIds = const {},
    this.isInitialized = false,
    this.isLoading = false,
    this.pluginOperations = const {},
    this.error,
    this.successMessage,
  });

  const PluginState.initial()
      : availablePlugins = const [],
        loadedPluginIds = const {},
        isInitialized = false,
        isLoading = false,
        pluginOperations = const {},
        error = null,
        successMessage = null;

  List<PluginInfo> get loadedContentResolvers => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.contentResolver &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  List<PluginInfo> get loadedChartProviders => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.chartProvider &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  List<PluginInfo> get loadedLyricsProviders => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.lyricsProvider &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  List<PluginInfo> get loadedSearchSuggestionProviders => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.searchSuggestionProvider &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  List<PluginInfo> get loadedContentImporters => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.contentImporter &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  bool isPluginLoaded(String pluginId) => loadedPluginIds.contains(pluginId);

  bool get hasActiveOperations => isLoading || pluginOperations.isNotEmpty;

  PluginOperation? operationFor(String pluginId) => pluginOperations[pluginId];

  PluginState copyWith({
    List<PluginInfo>? availablePlugins,
    Set<String>? loadedPluginIds,
    bool? isInitialized,
    bool? isLoading,
    Map<String, PluginOperation>? pluginOperations,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return PluginState(
      availablePlugins: availablePlugins ?? this.availablePlugins,
      loadedPluginIds: loadedPluginIds ?? this.loadedPluginIds,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      pluginOperations: pluginOperations ?? this.pluginOperations,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        availablePlugins,
        loadedPluginIds,
        isInitialized,
        isLoading,
        pluginOperations,
        error,
        successMessage,
      ];
}