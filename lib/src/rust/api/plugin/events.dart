import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
import 'plugin_info.dart';
import 'types.dart';
part 'events.freezed.dart';

@freezed
sealed class PluginManagerEvent with _$PluginManagerEvent {
  const PluginManagerEvent._();

  const factory PluginManagerEvent.pluginLoading({
    required String id,
  }) = PluginManagerEvent_PluginLoading;

  const factory PluginManagerEvent.pluginLoaded({
    required String id,
    required PluginType pluginType,
  }) = PluginManagerEvent_PluginLoaded;

  const factory PluginManagerEvent.pluginLoadFailed({
    required String id,
    required String error,
  }) = PluginManagerEvent_PluginLoadFailed;

  const factory PluginManagerEvent.pluginUnloading({
    required String id,
  }) = PluginManagerEvent_PluginUnloading;

  const factory PluginManagerEvent.pluginUnloaded({
    required String id,
  }) = PluginManagerEvent_PluginUnloaded;

  const factory PluginManagerEvent.pluginUnloadFailed({
    required String id,
    required String error,
  }) = PluginManagerEvent_PluginUnloadFailed;

  const factory PluginManagerEvent.pluginInstalling({
    required String id,
  }) = PluginManagerEvent_PluginInstalling;

  const factory PluginManagerEvent.pluginInstalled({
    required String id,
  }) = PluginManagerEvent_PluginInstalled;

  const factory PluginManagerEvent.pluginInstallFailed({
    required String id,
    required String error,
  }) = PluginManagerEvent_PluginInstallFailed;

  const factory PluginManagerEvent.pluginDeleting({
    required String id,
  }) = PluginManagerEvent_PluginDeleting;

  const factory PluginManagerEvent.pluginDeleted({
    required String id,
  }) = PluginManagerEvent_PluginDeleted;

  const factory PluginManagerEvent.pluginDeleteFailed({
    required String id,
    required String error,
  }) = PluginManagerEvent_PluginDeleteFailed;

  const factory PluginManagerEvent.pluginListRefreshed({
    required List<PluginInfo> plugins,
  }) = PluginManagerEvent_PluginListRefreshed;

  const factory PluginManagerEvent.storageSet({
    required String pluginId,
    required String key,
    required String value,
  }) = PluginManagerEvent_StorageSet;

  const factory PluginManagerEvent.storageDeleted({
    required String pluginId,
    required String key,
  }) = PluginManagerEvent_StorageDeleted;

  const factory PluginManagerEvent.storageCleared({
    required String pluginId,
  }) = PluginManagerEvent_StorageCleared;

  const factory PluginManagerEvent.managerInitialized() =
      PluginManagerEvent_ManagerInitialized;

  const factory PluginManagerEvent.error({
    required String message,
  }) = PluginManagerEvent_Error;
}