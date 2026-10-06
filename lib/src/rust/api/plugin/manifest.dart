import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class KeyRequirement {
  final String description;

  final String? defaultValue;

  final bool isSecret;

  const KeyRequirement({
    required this.description,
    this.defaultValue,
    required this.isSecret,
  });

  @override
  int get hashCode =>
      description.hashCode ^ defaultValue.hashCode ^ isSecret.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyRequirement &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          defaultValue == other.defaultValue &&
          isSecret == other.isSecret;
}

class Manifest {
  final int manifestVersion;
  final String id;
  final String name;
  final String version;
  final String type;
  final String description;
  final PluginPublisher publisher;
  final String license;
  final String homepage;
  final String? icon;
  final List<String> hostSite;
  final List<String> capabilities;
  final String? createdAt;
  final String? remoteUrl;
  final Map<String, KeyRequirement> keysRequired;
  final String? thumbnailUrl;
  final bool resolver;
  final String? lastUpdated;
  final List<String> countryAllowlist;

  const Manifest({
    required this.manifestVersion,
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    required this.description,
    required this.publisher,
    required this.license,
    required this.homepage,
    this.icon,
    required this.hostSite,
    required this.capabilities,
    this.createdAt,
    this.remoteUrl,
    required this.keysRequired,
    this.thumbnailUrl,
    required this.resolver,
    this.lastUpdated,
    required this.countryAllowlist,
  });

  @override
  int get hashCode =>
      manifestVersion.hashCode ^
      id.hashCode ^
      name.hashCode ^
      version.hashCode ^
      type.hashCode ^
      description.hashCode ^
      publisher.hashCode ^
      license.hashCode ^
      homepage.hashCode ^
      icon.hashCode ^
      hostSite.hashCode ^
      capabilities.hashCode ^
      createdAt.hashCode ^
      remoteUrl.hashCode ^
      keysRequired.hashCode ^
      thumbnailUrl.hashCode ^
      resolver.hashCode ^
      lastUpdated.hashCode ^
      countryAllowlist.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Manifest &&
          runtimeType == other.runtimeType &&
          manifestVersion == other.manifestVersion &&
          id == other.id &&
          name == other.name &&
          version == other.version &&
          type == other.type &&
          description == other.description &&
          publisher == other.publisher &&
          license == other.license &&
          homepage == other.homepage &&
          icon == other.icon &&
          hostSite == other.hostSite &&
          capabilities == other.capabilities &&
          createdAt == other.createdAt &&
          remoteUrl == other.remoteUrl &&
          keysRequired == other.keysRequired &&
          thumbnailUrl == other.thumbnailUrl &&
          resolver == other.resolver &&
          lastUpdated == other.lastUpdated &&
          countryAllowlist == other.countryAllowlist;
}

class PluginPublisher {
  final String name;
  final String? url;
  final String? contact;
  final String? keyId;

  const PluginPublisher({
    required this.name,
    this.url,
    this.contact,
    this.keyId,
  });

  @override
  int get hashCode =>
      name.hashCode ^ url.hashCode ^ contact.hashCode ^ keyId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginPublisher &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          url == other.url &&
          contact == other.contact &&
          keyId == other.keyId;
}