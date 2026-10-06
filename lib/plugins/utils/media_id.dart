library media_id;

import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart' show sha256;

const String kMediaIdSeparator = '::';

class MediaIdParts {
  final String pluginId;

  final String localId;

  const MediaIdParts({required this.pluginId, required this.localId});

  @override
  String toString() => '$pluginId$kMediaIdSeparator$localId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaIdParts &&
          pluginId == other.pluginId &&
          localId == other.localId;

  @override
  int get hashCode => pluginId.hashCode ^ localId.hashCode;
}

MediaIdParts? tryParseMediaId(String id) {
  final idx = id.indexOf(kMediaIdSeparator);
  if (idx == -1) return null;
  return MediaIdParts(
    pluginId: id.substring(0, idx),
    localId: id.substring(idx + kMediaIdSeparator.length),
  );
}

MediaIdParts parseMediaId(String id) {
  final parts = tryParseMediaId(id);
  if (parts == null) {
    throw FormatException(
      'Malformed media ID — expected "pluginId${kMediaIdSeparator}localId", '
      'got: "$id"',
    );
  }
  return parts;
}

String buildMediaId(String pluginId, String localId) =>
    '$pluginId$kMediaIdSeparator$localId';

String? pluginIdOf(String id) => tryParseMediaId(id)?.pluginId;

String? localIdOf(String id) => tryParseMediaId(id)?.localId;

bool isStampedId(String id) => id.contains(kMediaIdSeparator);

const String kLocalPluginId = 'local';

bool isLocalMediaId(String id) => pluginIdOf(id) == kLocalPluginId;

String buildLocalMediaId(String absoluteFilePath) {
  final hash = sha256.convert(utf8.encode(absoluteFilePath)).toString();
  return buildMediaId(kLocalPluginId, hash);
}

String buildMobileLocalMediaId(String assetId) =>
    buildMediaId(kLocalPluginId, assetId);