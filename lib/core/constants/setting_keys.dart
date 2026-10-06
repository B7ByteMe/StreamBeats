class SettingKeys {
  SettingKeys._();

  static const String autoUpdateNotify = "auto_update_notify";
  static const String autoSlideCharts = "auto_slide_charts";

  static const String strmQuality = "streamQuality";
  static const String autoPlay = "autoPlaySimilarItems";
  static const String autoResolveUnavailableTracks =
      "autoResolveUnavailableTracks";

  static const String crossfadeDuration = "crossfadeDuration";

  static const String eqEnabled = "eqEnabled";

  static const String eqBandGains = "eqBandGains";

  static const String eqPreset = "eqPreset";

  static const String eqSource = "eqSource";

  static const String downPathSetting = "downloadPath";

  static const String downloadPlaylist = "_DOWNLOADS";
  static const String downQuality = "downloadQuality";

  static const String backupPath = "backupPath";
  static const String autoBackup = "autoBackup";

  static const String lastBackupTimestamp = "lastBackupTimestamp";

  static const String historyClearTime = "autoHistoryCleanupTime";

  static const String recentlyPlayedPlaylist = "recently_played";

  static const String lastQueueState = 'lastQueueState';

  static const String languageCode = "languageCode";
  static const String autoGetCountry = "autoGetCountry";
  static const String countryCode = "countryCode";
  static const String chartShowMap = "chartShowMap";

  static const String autoSaveLyrics = "autoSaveLyrics";

  static const String readChangelogs = "readChangelogs";

  static const String repositoriesBootstrapped = "repositoriesBootstrapped";
  static const String appSetupCompleted = "appSetupCompleted";

  static const String autoLoadPluginIds = "autoLoadPluginIds";

  static const String homePluginId = "homePluginId";

  static const String searchPluginId = "searchPluginId";

  static const String resolverPriority = "resolverPriority";

  static const String lyricsPriority = "lyricsPriority";

  static const String suggestionPluginId = "suggestionPluginId";

  static const String pluginRepositoryLastSync = "pluginRepositoryLastSync";

  static const String localMusicFolders = "localMusicFolders";

  static const String localMusicAutoScan = "localMusicAutoScan";

  static const String localMusicLastScan = "localMusicLastScan";

  static const String localMusicPlaylist = "_LOCAL_MUSIC";

  static const String localMusicConfirmDelete = 'localMusicConfirmDelete';
}

class EqSourceValues {
  EqSourceValues._();

  static const String builtin = 'builtin';

  static const String device = 'device';
}