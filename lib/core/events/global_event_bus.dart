library global_event_bus;

import 'dart:async';
import 'dart:developer';

sealed class AppError {
  const AppError();

  const factory AppError.pluginNotLoaded({
    required String pluginId,
    String? mediaId,
  }) = PluginNotLoadedError;

  const factory AppError.malformedMediaId({
    required String rawId,
  }) = MalformedMediaIdError;

  const factory AppError.networkFailure({
    required String message,
  }) = NetworkFailureError;

  const factory AppError.pluginError({
    required String pluginId,
    required String message,
  }) = PluginErrorEvent;
}

class PluginNotLoadedError extends AppError {
  final String pluginId;
  final String? mediaId;

  const PluginNotLoadedError({required this.pluginId, this.mediaId});

  @override
  String toString() =>
      'Plugin "$pluginId" is not loaded${mediaId != null ? ' (mediaId: $mediaId)' : ''}';
}

class MalformedMediaIdError extends AppError {
  final String rawId;

  const MalformedMediaIdError({required this.rawId});

  @override
  String toString() => 'Malformed media ID: "$rawId"';
}

class NetworkFailureError extends AppError {
  final String message;

  const NetworkFailureError({required this.message});

  @override
  String toString() => 'Network failure: $message';
}

class PluginErrorEvent extends AppError {
  final String pluginId;
  final String message;

  const PluginErrorEvent({required this.pluginId, required this.message});

  @override
  String toString() => 'Plugin "$pluginId" error: $message';
}

class GlobalEventBus {
  GlobalEventBus._();

  static final GlobalEventBus instance = GlobalEventBus._();

  final StreamController<AppError> _controller =
      StreamController<AppError>.broadcast();

  Stream<AppError> get errors => _controller.stream;

  void emitError(AppError error) {
    log('GlobalEventBus: $error', name: 'GlobalEventBus');
    _controller.add(error);
  }

  void dispose() {
    _controller.close();
  }
}

bool requirePlugin(String pluginId, Set<String> loadedPluginIds) {
  if (loadedPluginIds.contains(pluginId)) return true;

  GlobalEventBus.instance.emitError(
    AppError.pluginNotLoaded(pluginId: pluginId),
  );
  return false;
}