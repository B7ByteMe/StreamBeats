import 'dart:async';
import 'dart:io' as io;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:streambeats/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:streambeats/blocs/global_events/global_events_cubit.dart';
import 'package:streambeats/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:streambeats/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:streambeats/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:streambeats/blocs/lyrics/lyrics_cubit.dart';
import 'package:streambeats/blocs/mini_player/mini_player_cubit.dart';
import 'package:streambeats/blocs/notification/notification_cubit.dart';
import 'package:streambeats/blocs/history/cubit/history_cubit.dart';
import 'package:streambeats/blocs/explore/cubit/recently_cubit.dart';
import 'package:streambeats/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:streambeats/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:streambeats/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:streambeats/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:streambeats/plugins/blocs/plugin/plugin_event.dart';
import 'package:streambeats/repository/streambeats/download_repository.dart';
import 'package:streambeats/repository/streambeats/settings_repository.dart';
import 'package:streambeats/services/db/dao/cache_dao.dart';
import 'package:streambeats/services/db/dao/download_dao.dart';
import 'package:streambeats/services/db/dao/history_dao.dart';
import 'package:streambeats/services/db/dao/lyrics_dao.dart';
import 'package:streambeats/services/db/dao/notification_dao.dart';
import 'package:streambeats/services/db/dao/library_dao.dart';
import 'package:streambeats/services/db/dao/playlist_dao.dart';
import 'package:streambeats/services/db/dao/search_history_dao.dart';
import 'package:streambeats/core/di/service_locator.dart';
import 'package:streambeats/services/db/dao/track_dao.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/blocs/timer/timer_bloc.dart';
import 'package:streambeats/screens/widgets/global_event_listener.dart';
import 'package:streambeats/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:streambeats/services/bootstrap.dart';
import 'package:streambeats/services/audio_service_initializer.dart';
import 'package:streambeats/services/keyboard_shortcuts_service.dart';
import 'package:streambeats/services/shortcut_indicator_service.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/services/import_export_service.dart';
import 'package:streambeats/utils/ticker.dart';
import 'package:streambeats/utils/url_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streambeats/l10n/app_localizations.dart';
import 'package:streambeats/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:streambeats/blocs/library/cubit/library_items_cubit.dart';
import 'package:streambeats/plugins/blocs/import/content_import_cubit.dart';
import 'package:streambeats/routes/app_router.dart';
import 'package:streambeats/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/media_player/streambeats_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:streambeats/services/discord_service.dart';
import 'package:streambeats/services/supabase_party_service.dart';
import 'package:streambeats/services/db/legacy/legacy_migration_service.dart'
    as legacy_migration;
import 'package:streambeats/screens/widgets/legacy_migration_overlay.dart';
import 'package:streambeats/screens/widgets/onboarding_overlay.dart';
import 'package:streambeats/screens/widgets/plugin_bootstrap_overlay.dart';
import 'package:streambeats/services/onboarding_service.dart';
import 'package:streambeats/services/plugin_bootstrap_service.dart';
import 'package:streambeats/plugins/services/plugin_repository_service.dart';
import 'package:streambeats/services/shared_url_resolver_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void processIncomingIntent(SharedMedia sharedMedia) {
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    final urlType = getUrlType(sharedMedia.content!);
    switch (urlType) {
      case UrlType.youtubeVideo:
        _handleYoutubeVideoIntent(sharedMedia.content!);
        break;
      case UrlType.youtubePlaylist:
      case UrlType.spotifyTrack:
      case UrlType.spotifyPlaylist:
      case UrlType.spotifyAlbum:
      case UrlType.other:
        SnackbarService.showMessage(
            'Open the Import screen in Library to import from this URL.');
        break;
    }
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    final attachment = sharedMedia.attachments!.first;
    if (attachment != null) {
      SnackbarService.showMessage('Processing File...');
      importItems(attachment.path);
    }
  }
}

Future<void> _handleYoutubeVideoIntent(String url) async {
  if (extractVideoId(url) == null) {
    SnackbarService.showMessage('Invalid YouTube URL');
    return;
  }
  SnackbarService.showMessage('Getting YouTube Audio...');

  final result = await SharedUrlResolverService.resolveYoutubeVideo(url);
  if (result.status == SharedUrlResolveStatus.invalidUrl) {
    SnackbarService.showMessage('Invalid YouTube URL');
    return;
  }

  if (result.status == SharedUrlResolveStatus.noResolver) {
    SnackbarService.showMessage(
        'No loaded content resolver can handle this URL.');
    return;
  }

  final track = result.track;
  if (result.status == SharedUrlResolveStatus.success && track != null) {
    final player = await PlayerInitializer().getStreamBeatsMusicPlayer();
    await player.updateQueueTracks([track], doPlay: true);
    SnackbarService.showMessage('Playing: ${track.title}');
    return;
  }

  if (result.status == SharedUrlResolveStatus.failed) {
    SnackbarService.showMessage('Failed to get YouTube audio.');
  }
}

Future<void> importItems(String path) async {
  final context = GlobalRoutes.globalRouterKey.currentContext;
  if (context == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      importItems(path);
    });
    return;
  }

  await ImportExportService.handleImportOrRestore(context, path);
}

Future<void> setHighRefreshRate() async {
  if (io.Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}

late StreamBeatsPlayerCubit streambeatsPlayerCubit;
Future<void> setupPlayerCubit() async {
  await setupAudioSession();
  final player = await PlayerInitializer().getStreamBeatsMusicPlayer();
  streambeatsPlayerCubit = StreamBeatsPlayerCubit(player);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  MediaKit.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zawqnzfshwibrbvskhvr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inphd3FuemZzaHdpYnJidnNraHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUwNDU2NzYsImV4cCI6MjEwMDYyMTY3Nn0.bj5BBVK8UU8ctbe3Oy6jzOF38Ugt9nes0QY7K8PjQvQ',
  );

  await bootstrapApp();
  setHighRefreshRate();
  await setupPlayerCubit();
  DiscordService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<SharedMedia>? _intentSub;
  SharedMedia? sharedMedia;

  bool _migrationPending = false;
  bool _onboardingPending = false;
  bool _pluginBootstrapPending = false;
  bool _splashPending = io.Platform.isWindows;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _migrationPending = legacy_migration.needsMigration(
      DBProvider.appSuppDir,
      DBProvider.appDocDir,
    );

    _onboardingPending = !OnboardingService.onboardingDone;
    _pluginBootstrapPending = !PluginBootstrapService.bootstrapDone;

    if (io.Platform.isWindows) {
      final settingsDao = SettingsDAO(DBProvider.db);
      settingsDao.getSettingBool('show_splash_on_startup', defaultValue: true).then((showSplash) {
        if (mounted) {
          if (showSplash == false) {
            setState(() {
              _splashPending = false;
            });
          } else {
            Timer(const Duration(seconds: 7), () {
              if (mounted) {
                setState(() {
                  _splashPending = false;
                });
              }
            });
          }
        }
      });
    } else {
      _splashPending = false;
    }

    if (io.Platform.isAndroid) {
      initPlatformState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_ensurePlayerHealthyOnResume());
      unawaited(_checkPluginUpdatesOnResume());
      unawaited(SupabasePartyService.reconnectIfNecessary());
    }
  }

  Future<void> _ensurePlayerHealthyOnResume() async {
    try {
      final player = await PlayerInitializer().getStreamBeatsMusicPlayer();
      if (!player.isPlayerHealthy) {
        await player.revive();
      }
      player.syncPublicState();
    } catch (error, stackTrace) {
      debugPrint('Player health check on resume failed: $error\n$stackTrace');
    }
  }

  Future<void> _checkPluginUpdatesOnResume() async {
    try {
      final settingsDao = SettingsDAO(DBProvider.db);
      final repositoryService =
          PluginRepositoryService(settingsDao: settingsDao);
      await PluginBootstrapService.syncOnAppOpenIfDue(
        pluginService: ServiceLocator.pluginService,
        repositoryService: repositoryService,
        settingsDao: settingsDao,
      );
    } catch (error, stackTrace) {
      debugPrint('Plugin update check on resume failed: $error\n$stackTrace');
    }
  }

  Future<void> initPlatformState() async {
    try {
      final handler = ShareHandlerPlatform.instance;
      sharedMedia = await handler.getInitialSharedMedia();

      _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
        if (!mounted) return;
        setState(() {
          sharedMedia = media;
        });
        if (sharedMedia != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            processIncomingIntent(sharedMedia!);
          });
        }
      });
      if (!mounted) return;

      setState(() {
        if (sharedMedia != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            processIncomingIntent(sharedMedia!);
          });
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize share handler: $error\n$stackTrace');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    streambeatsPlayerCubit.close();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_splashPending && io.Platform.isWindows) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/loading.gif',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final ver = snapshot.hasData
                            ? 'Versi ${snapshot.data!.version}'
                            : 'Versi 3.2.6';
                        return Text(
                          ver,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            decoration: TextDecoration.none,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Power By Streambeats',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Developer : Valora Official',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        decoration: TextDecoration.none,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_migrationPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: LegacyMigrationOverlay(
          appSuppDir: DBProvider.appSuppDir,
          appDocDir: DBProvider.appDocDir,
          onComplete: (result) {
            if (!result.success) return;
            setState(() => _migrationPending = false);
          },
        ),
      );
    }

    if (_onboardingPending) {
      return OnboardingOverlay(
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _onboardingPending = false;
            _pluginBootstrapPending = !PluginBootstrapService.bootstrapDone;
          });
        },
      );
    }

    if (_pluginBootstrapPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: PluginBootstrapOverlay(
          onComplete: () {
            if (!mounted) return;
            setState(() => _pluginBootstrapPending = false);
          },
        ),
      );
    }

    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    final historyDao = HistoryDAO(DBProvider.db, trackDao);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PluginBloc(
            pluginService: ServiceLocator.pluginService,
            eventBus: ServiceLocator.pluginEventBus,
            repositoryService: ServiceLocator.pluginRepositoryService,
            settingsDao: SettingsDAO(DBProvider.db),
          )..add(const InitializePluginSystem()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => streambeatsPlayerCubit,
          lazy: false,
        ),
        BlocProvider(
            create: (context) =>
                MiniPlayerCubit(playerCubit: streambeatsPlayerCubit),
            lazy: true),
        BlocProvider(
          create: (context) => SettingsCubit(
            SettingsRepository(SettingsDAO(DBProvider.db)),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => NotificationCubit(
            notificationDao: NotificationDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
            create: (context) => TimerBloc(
                ticker: const Ticker(), streambeatsPlayer: streambeatsPlayerCubit)),
        BlocProvider(
          create: (context) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => CurrentPlaylistCubit(playlistDao: playlistDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => RecentlyCubit(historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => HistoryCubit(historyDao: historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => LibraryItemsCubit(
            playlistDao: playlistDao,
            libraryDao: LibraryDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => ContentImportCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AddToPlaylistCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => SearchSuggestionBloc(
            searchHistoryDao: SearchHistoryDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
            settingsDao: SettingsDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => LyricsCubit(
            streambeatsPlayerCubit,
            lyricsDao: LyricsDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(
            playerCubit: streambeatsPlayerCubit,
            cacheDao: CacheDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
            downloadRepo: DownloadRepository(
              DownloadDAO(DBProvider.db, trackDao, playlistDao),
            ),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => GlobalEventsCubit(
            settingsDao: SettingsDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PlayerOverlayCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ShortcutIndicatorCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => LocalMusicCubit(),
          lazy: true,
        ),
      ],
      child: BlocBuilder<StreamBeatsPlayerCubit, StreamBeatsPlayerState>(
        builder: (context, state) {
          if (state is StreamBeatsPlayerInitial) {
            return const Directionality(
              textDirection: TextDirection.ltr,
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final locale = settingsState.languageCode.isEmpty
                    ? null
                    : Locale(settingsState.languageCode);

                return KeyboardShortcutsHandler(
                  child: ShortcutIndicatorOverlay(
                    child: MaterialApp.router(
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: locale,
                      builder: (context, child) =>
                          ResponsiveBreakpoints.builder(
                        breakpoints: [
                          const Breakpoint(start: 0, end: 450, name: MOBILE),
                          const Breakpoint(start: 451, end: 800, name: TABLET),
                          const Breakpoint(
                              start: 801, end: 1920, name: DESKTOP),
                          const Breakpoint(
                              start: 1921, end: double.infinity, name: '4K'),
                        ],
                        child: GlobalEventListener(
                          navigatorKey: GlobalRoutes.globalRouterKey,
                          child: child!,
                        ),
                      ),
                      scaffoldMessengerKey: SnackbarService.messengerKey,
                      routerConfig: GlobalRoutes.globalRouter,
                      theme: Default_Theme().defaultThemeData,
                      scrollBehavior: CustomScrollBehavior(),
                      debugShowCheckedModeBanner: false,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}