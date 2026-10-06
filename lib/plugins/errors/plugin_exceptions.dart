library plugin_exceptions;

sealed class PluginException implements Exception {
  final String? pluginId;

  final String message;

  final Object? cause;

  const PluginException({
    this.pluginId,
    required this.message,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (pluginId != null) buffer.write(' [plugin: $pluginId]');
    if (cause != null) buffer.write(' (cause: $cause)');
    return buffer.toString();
  }
}

class PluginNotLoadedException extends PluginException {
  const PluginNotLoadedException({
    required String pluginId,
    String message = 'Plugin is not loaded',
  }) : super(pluginId: pluginId, message: message);
}

class PluginExecutionException extends PluginException {
  final String? errorCode;

  const PluginExecutionException({
    String? pluginId,
    required String message,
    this.errorCode,
    Object? cause,
  }) : super(pluginId: pluginId, message: message, cause: cause);
}

class PluginInstallException extends PluginException {
  const PluginInstallException({
    String? pluginId,
    required String message,
    Object? cause,
  }) : super(pluginId: pluginId, message: message, cause: cause);
}

class PluginCountryRestrictedException extends PluginInstallException {
  final String countryCode;
  final List<String> allowlist;

  const PluginCountryRestrictedException({
    required String pluginId,
    required this.countryCode,
    required this.allowlist,
  }) : super(
          pluginId: pluginId,
          message:
              'Plugin "$pluginId" is not available in your country ($countryCode).',
        );
}

class PluginNotFoundException extends PluginException {
  const PluginNotFoundException({
    required String pluginId,
    String message = 'Plugin not found',
  }) : super(pluginId: pluginId, message: message);
}

class MalformedMediaIdException extends PluginException {
  final String rawId;

  const MalformedMediaIdException({
    required this.rawId,
    String message = 'Malformed media ID',
  }) : super(message: message);
}