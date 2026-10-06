import 'dart:convert';
import 'dart:developer';
import 'package:streambeats/core/constants/setting_keys.dart';
import 'package:streambeats/core/constants/cache_keys.dart';
import 'package:streambeats/repository/streambeats/settings_repository.dart';
import 'package:streambeats/services/player/stream_quality_selector.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/utils/country_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepo;

  SettingsCubit(this._settingsRepo) : super(SettingsInitial()) {
    _initSettings();
    _autoBackupWithGate();
  }

  Future<void> _initSettings() async {
    final results = await Future.wait([
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoUpdateNotify),
        SettingKeys.autoUpdateNotify,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoSlideCharts),
        SettingKeys.autoSlideCharts,
      ),
      _resolveDownPath(),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.downQuality,
            defaultValue: AudioStreamQualityPreference.medium.label),
        SettingKeys.downQuality,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.strmQuality),
        SettingKeys.strmQuality,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.historyClearTime),
        SettingKeys.historyClearTime,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(CacheKeys.lFMScrobbleSetting),
        CacheKeys.lFMScrobbleSetting,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoPlay),
        SettingKeys.autoPlay,
      ),
      _readSetting(
        () => _settingsRepo
            .getSettingBool(SettingKeys.autoResolveUnavailableTracks),
        SettingKeys.autoResolveUnavailableTracks,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(CacheKeys.lFMUIPicks),
        CacheKeys.lFMUIPicks,
      ),
      _resolveBackupPath(),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoBackup),
        SettingKeys.autoBackup,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoGetCountry),
        SettingKeys.autoGetCountry,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.languageCode),
        SettingKeys.languageCode,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.countryCode),
        SettingKeys.countryCode,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.autoSaveLyrics),
        SettingKeys.autoSaveLyrics,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.chartShowMap),
        SettingKeys.chartShowMap,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.crossfadeDuration),
        SettingKeys.crossfadeDuration,
      ),
      _readSetting(
        () => _settingsRepo.getSettingBool(SettingKeys.eqEnabled),
        SettingKeys.eqEnabled,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.eqBandGains),
        SettingKeys.eqBandGains,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.eqPreset,
            defaultValue: 'Flat'),
        SettingKeys.eqPreset,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.eqSource,
            defaultValue: EqSourceValues.builtin),
        SettingKeys.eqSource,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.homePluginId,
            defaultValue: ''),
        SettingKeys.homePluginId,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.searchPluginId,
            defaultValue: ''),
        SettingKeys.searchPluginId,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.resolverPriority,
            defaultValue: '[]'),
        SettingKeys.resolverPriority,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.lyricsPriority,
            defaultValue: '[]'),
        SettingKeys.lyricsPriority,
      ),
      _readSetting(
        () => _settingsRepo.getSettingStr(SettingKeys.suggestionPluginId,
            defaultValue: ''),
        SettingKeys.suggestionPluginId,
      ),
    ]);

    final rawDownQ = results[3] as String?;
    final normalizedDownQ = normalizeStoredStreamQualityLabel(rawDownQ,
        fallback: AudioStreamQualityPreference.medium.label);
    if (rawDownQ != normalizedDownQ) {
      _settingsRepo.putSettingStr(SettingKeys.downQuality, normalizedDownQ);
    }

    final rawStrmQ = results[4] as String?;
    final normalizedStrmQ = normalizeStoredStreamQualityLabel(rawStrmQ,
        fallback: AudioStreamQualityPreference.high.label);
    if (rawStrmQ != normalizedStrmQ) {
      _settingsRepo.putSettingStr(SettingKeys.strmQuality, normalizedStrmQ);
    }

    Map chartMap = {};
    final chartJson = results[16] as String?;
    if (chartJson != null) {
      try {
        chartMap = jsonDecode(chartJson);
      } catch (_) {}
    }

    final cfStr = results[17] as String?;
    final crossfadeSeconds = int.tryParse((cfStr ?? '').trim()) ?? 2;
    if (cfStr != crossfadeSeconds.toString()) {
      _settingsRepo.putSettingStr(
          SettingKeys.crossfadeDuration, crossfadeSeconds.toString());
    }

    List<double> eqGains = List<double>.filled(10, 0.0);
    final gainsJson = results[19] as String?;
    if (gainsJson != null) {
      try {
        final decoded = jsonDecode(gainsJson) as List;
        final parsed = decoded.map((e) => (e as num).toDouble()).toList();
        if (parsed.length == 10) eqGains = parsed;
      } catch (e) {
        log('Failed to decode EQ gains: $e', name: 'SettingsCubit');
      }
    }

    List<String> resolverPriority = const [];
    try {
      final rj = results[24] as String?;
      if (rj != null && rj.isNotEmpty) {
        resolverPriority = (jsonDecode(rj) as List).cast<String>();
      }
    } catch (_) {}

    List<String> lyricsPriority = const [];
    try {
      final lj = results[25] as String?;
      if (lj != null && lj.isNotEmpty) {
        lyricsPriority = (jsonDecode(lj) as List).cast<String>();
      }
    } catch (_) {}

    final rawCountry = results[14] as String?;
    final normalizedCountry =
        CountryInfoService.normalizeCountryCode(rawCountry);
    final resolvedCountry = normalizedCountry.isNotEmpty
        ? normalizedCountry
        : CountryInfoService.defaultCountryCode;

    final rawEqSource = results[21] as String?;
    final eqSource = rawEqSource == EqSourceValues.device
        ? EqSourceValues.device
        : EqSourceValues.builtin;

    if (isClosed) return;

    emit(SettingsState(
      settingsReady: true,
      autoUpdateNotify: (results[0] as bool?) ?? false,
      autoSlideCharts: (results[1] as bool?) ?? true,
      downPath: results[2] as String,
      downQuality: normalizedDownQ,
      strmQuality: normalizedStrmQ,
      backupPath: results[10] as String,
      autoBackup: (results[11] as bool?) ?? false,
      historyClearTime: (results[5] as String?) ?? '30',
      autoGetCountry: (results[12] as bool?) ?? true,
      languageCode: (results[13] as String?) ?? '',
      countryCode: resolvedCountry,
      autoSaveLyrics: (results[15] as bool?) ?? false,
      lFMPicks: (results[9] as bool?) ?? false,
      lastFMScrobble: (results[6] as bool?) ?? false,
      chartMap: Map.from(chartMap),
      autoPlay: (results[7] as bool?) ?? true,
      autoResolveUnavailableTracks: (results[8] as bool?) ?? true,
      crossfadeDuration: crossfadeSeconds,
      eqEnabled: (results[18] as bool?) ?? false,
      eqBandGains: eqGains,
      eqPreset: (results[20] as String?) ?? 'Flat',
      eqSource: eqSource,
      homePluginId: (results[22] as String?) ?? '',
      searchPluginId: (results[23] as String?) ?? '',
      resolverPriority: resolverPriority,
      lyricsPriority: lyricsPriority,
      suggestionPluginId: (results[26] as String?) ?? '',
    ));
  }

  Future<T?> _readSetting<T>(Future<T?> Function() read, String key) async {
    try {
      return await read();
    } catch (e) {
      log('Failed to read setting $key: $e', name: 'SettingsCubit');
      return null;
    }
  }

  Future<String> _resolveDownPath() async {
    try {
      final saved =
          await _settingsRepo.getSettingStr(SettingKeys.downPathSetting);
      if (saved != null) return saved;
      final path = ((await getDownloadsDirectory()) ??
              (await getApplicationDocumentsDirectory()))
          .path;
      await _settingsRepo.putSettingStr(SettingKeys.downPathSetting, path);
      return path;
    } catch (e) {
      log('_resolveDownPath failed: $e', name: 'SettingsCubit');
      return '';
    }
  }

  Future<String> _resolveBackupPath() async {
    try {
      final defaultPath = await DBProvider.getDbBackupFilePath();
      await _settingsRepo.putSettingStr(SettingKeys.backupPath, defaultPath);
      return defaultPath;
    } catch (e) {
      log('_resolveBackupPath failed: $e', name: 'SettingsCubit');
      return '';
    }
  }

  void _autoBackupWithGate() {
    _settingsRepo.getSettingBool(SettingKeys.autoBackup).then((on) async {
      try {
        if (on != true) return;
        final lastStr =
            await _settingsRepo.getSettingStr(SettingKeys.lastBackupTimestamp);
        final last = lastStr != null ? DateTime.tryParse(lastStr) : null;
        final now = DateTime.now().toUtc();
        if (last == null || now.difference(last) > const Duration(hours: 24)) {
          await DBProvider.createBackUp();
          await _settingsRepo.putSettingStr(
              SettingKeys.lastBackupTimestamp, now.toIso8601String());
        }
      } catch (e) {
        log('Auto-backup check failed: $e', name: 'SettingsCubit');
      }
    });
  }

  void setChartShow(String title, bool value) {
    final m = Map.from(state.chartMap)..[title] = value;
    _settingsRepo.putSettingStr(SettingKeys.chartShowMap, jsonEncode(m));
    emit(state.copyWith(chartMap: m));
  }

  Future<void> setAutoPlay(bool v) async {
    await _settingsRepo.putSettingBool(SettingKeys.autoPlay, v);
    emit(state.copyWith(autoPlay: v));
  }

  Future<void> setAutoResolveUnavailableTracks(bool v) async {
    await _settingsRepo.putSettingBool(
        SettingKeys.autoResolveUnavailableTracks, v);
    emit(state.copyWith(autoResolveUnavailableTracks: v));
  }

  void setCountryCode(String v) {
    _settingsRepo.putSettingStr(SettingKeys.countryCode, v);
    emit(state.copyWith(countryCode: v));
  }

  void setLanguageCode(String v) {
    _settingsRepo.putSettingStr(SettingKeys.languageCode, v);
    emit(state.copyWith(languageCode: v));
  }

  void setAutoSaveLyrics(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.autoSaveLyrics, v);
    emit(state.copyWith(autoSaveLyrics: v));
  }

  void setLastFMScrobble(bool v) {
    _settingsRepo.putSettingBool(CacheKeys.lFMScrobbleSetting, v);
    emit(state.copyWith(lastFMScrobble: v));
  }

  void setLastFMExpore(bool v) {
    _settingsRepo.putSettingBool(CacheKeys.lFMUIPicks, v);
    emit(state.copyWith(lFMPicks: v));
  }

  void setAutoGetCountry(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.autoGetCountry, v);
    emit(state.copyWith(autoGetCountry: v));
  }

  void setAutoUpdateNotify(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.autoUpdateNotify, v);
    emit(state.copyWith(autoUpdateNotify: v));
  }

  void setAutoSlideCharts(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.autoSlideCharts, v);
    emit(state.copyWith(autoSlideCharts: v));
  }

  void setDownPath(String v) {
    _settingsRepo.putSettingStr(SettingKeys.downPathSetting, v);
    emit(state.copyWith(downPath: v));
  }

  void setDownQuality(String v) {
    final n = normalizeStoredStreamQualityLabel(v,
        fallback: AudioStreamQualityPreference.medium.label);
    _settingsRepo.putSettingStr(SettingKeys.downQuality, n);
    emit(state.copyWith(downQuality: n));
  }

  void setStrmQuality(String v) {
    final n = normalizeStoredStreamQualityLabel(v,
        fallback: AudioStreamQualityPreference.high.label);
    _settingsRepo.putSettingStr(SettingKeys.strmQuality, n);
    emit(state.copyWith(strmQuality: n));
  }

  void setBackupPath(String v) {
    _settingsRepo.putSettingStr(SettingKeys.backupPath, v);
    emit(state.copyWith(backupPath: v));
  }

  void setAutoBackup(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.autoBackup, v);
    emit(state.copyWith(autoBackup: v));
  }

  void setHistoryClearTime(String v) {
    _settingsRepo.putSettingStr(SettingKeys.historyClearTime, v);
    emit(state.copyWith(historyClearTime: v));
  }

  void setCrossfadeDuration(int seconds) {
    _settingsRepo.putSettingStr(
        SettingKeys.crossfadeDuration, seconds.toString());
    emit(state.copyWith(crossfadeDuration: seconds));
  }

  void setEqEnabled(bool v) {
    _settingsRepo.putSettingBool(SettingKeys.eqEnabled, v);
    emit(state.copyWith(eqEnabled: v));
  }

  void setEqBandGains(List<double> gains) {
    _settingsRepo.putSettingStr(SettingKeys.eqBandGains, jsonEncode(gains));
    emit(state.copyWith(eqBandGains: gains));
  }

  void setEqPreset(String preset) {
    _settingsRepo.putSettingStr(SettingKeys.eqPreset, preset);
    emit(state.copyWith(eqPreset: preset));
  }

  void setEqSource(String source) {
    final normalized = source == EqSourceValues.device
        ? EqSourceValues.device
        : EqSourceValues.builtin;
    _settingsRepo.putSettingStr(SettingKeys.eqSource, normalized);
    emit(state.copyWith(eqSource: normalized));
  }

  void setHomePluginId(String id) {
    _settingsRepo.putSettingStr(SettingKeys.homePluginId, id);
    emit(state.copyWith(homePluginId: id));
  }

  void setSearchPluginId(String id) {
    _settingsRepo.putSettingStr(SettingKeys.searchPluginId, id);
    emit(state.copyWith(searchPluginId: id));
  }

  void setResolverPriority(List<String> p) {
    _settingsRepo.putSettingStr(SettingKeys.resolverPriority, jsonEncode(p));
    emit(state.copyWith(resolverPriority: p));
  }

  void setLyricsPriority(List<String> p) {
    _settingsRepo.putSettingStr(SettingKeys.lyricsPriority, jsonEncode(p));
    emit(state.copyWith(lyricsPriority: p));
  }

  void setSuggestionPluginId(String id) {
    _settingsRepo.putSettingStr(SettingKeys.suggestionPluginId, id);
    emit(state.copyWith(suggestionPluginId: id));
  }

  Future<void> resetDownPath() async {
    final path = ((await getDownloadsDirectory()) ??
            (await getApplicationDocumentsDirectory()))
        .path;
    setDownPath(path);
  }

  Future<void> putSettingStr(String key, String value) async =>
      _settingsRepo.putSettingStr(key, value);
}