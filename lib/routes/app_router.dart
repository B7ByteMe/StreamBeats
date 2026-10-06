import 'package:streambeats/core/constants/route_paths.dart';
import 'package:streambeats/screens/widgets/global_footer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streambeats/screens/screen/common_views/add_to_playlist_screen.dart';
import 'package:streambeats/screens/screen/explore_screen.dart';
import 'package:streambeats/screens/screen/library_screen.dart';
import 'package:streambeats/screens/screen/library_views/import_media_view.dart';
import 'package:streambeats/screens/screen/library_views/import_process_screen.dart';
import 'package:streambeats/screens/screen/library_views/playlist_screen.dart';
import 'package:streambeats/screens/screen/library_views/shared_playlist_screen.dart';
import 'package:streambeats/screens/screen/home_views/party_room_screen.dart';
import 'package:streambeats/screens/screen/offline_screen.dart';
import 'package:streambeats/screens/screen/local_music_screen.dart';
import 'package:streambeats/screens/screen/search_screen.dart';
import 'package:streambeats/screens/screen/chart/chart_view.dart';

class AppRouter {
  static final globalRouterKey = GlobalKey<NavigatorState>();

  static final globalRouter = GoRouter(
    initialLocation: '/Explore',
    navigatorKey: globalRouterKey,
    routes: [
      GoRoute(
        path: '/AddToPlaylist',
        parentNavigatorKey: globalRouterKey,
        name: RoutePaths.addToPlaylistScreen,
        builder: (context, state) => const AddToPlaylistScreen(),
      ),
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              GlobalFooter(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  name: RoutePaths.exploreScreen,
                  path: '/Explore',
                  builder: (context, state) => const ExploreScreen(),
                  routes: [
                    GoRoute(
                        name: RoutePaths.chartScreen,
                        path: 'ChartScreen',
                        builder: (context, state) {
                          final qp = state.uri.queryParameters;
                          return ChartScreen(
                            pluginId: qp['pluginId'] ?? '',
                            chartId: qp['chartId'] ?? '',
                            chartTitle: qp['chartTitle'] ?? 'Chart',
                          );
                        }),
                  ])
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  name: RoutePaths.libraryScreen,
                  path: '/Library',
                  builder: (context, state) => const LibraryScreen(),
                  routes: [
                    GoRoute(
                      path: 'PartyRoom',
                      name: 'PartyRoom',
                      builder: (context, state) => const PartyRoomScreen(),
                    ),
                    GoRoute(
                      path: 'SharedPlaylist',
                      name: 'SharedPlaylist',
                      builder: (context, state) {
                        final code = state.uri.queryParameters['code'] ?? '';
                        final title = state.uri.queryParameters['title'] ?? 'Playlist Bersama';
                        return SharedPlaylistScreen(playlistCode: code, playlistTitle: title);
                      },
                    ),
                    GoRoute(
                      path: RoutePaths.importMediaFromPlatforms,
                      name: RoutePaths.importMediaFromPlatforms,
                      builder: (context, state) =>
                          const ImportMediaFromPlatformsView(),
                    ),
                    GoRoute(
                      path: RoutePaths.importProcess,
                      name: RoutePaths.importProcess,
                      builder: (context, state) {
                        final pluginId =
                            state.uri.queryParameters['pluginId'] ?? '';
                        return ImportProcessScreen(pluginId: pluginId);
                      },
                    ),
                    GoRoute(
                      name: RoutePaths.playlistView,
                      path: RoutePaths.playlistView,
                      builder: (context, state) {
                        final initialPlaylistName = state.extra as String?;
                        return PlaylistView(
                          initialPlaylistName: initialPlaylistName,
                        );
                      },
                    ),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: RoutePaths.searchScreen,
                path: '/Search',
                builder: (context, state) {
                  if (state.uri.queryParameters['query'] != null) {
                    return SearchScreen(
                      searchQuery:
                          state.uri.queryParameters['query']!.toString(),
                    );
                  } else {
                    return const SearchScreen();
                  }
                },
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: RoutePaths.localMusicScreen,
                path: '/LocalMusic',
                builder: (context, state) => const LocalMusicScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: RoutePaths.offlineScreen,
                path: '/Offline',
                builder: (context, state) => const OfflineScreen(),
              ),
            ]),
          ])
    ],
  );
}

typedef GlobalRoutes = AppRouter;