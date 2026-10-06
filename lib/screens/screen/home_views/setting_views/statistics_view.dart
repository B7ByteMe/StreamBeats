import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:streambeats/blocs/explore/cubit/recently_cubit.dart';
import 'package:streambeats/blocs/history/cubit/history_cubit.dart';
import 'package:streambeats/blocs/library/cubit/library_items_cubit.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/core/models/exported.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Default_Theme.primaryColor1),
        title: const Text(
          'Statistik',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, historyState) {
          final historyTracks = historyState.tracks;

          return BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
            builder: (context, libraryState) {
              final playlistsCount = libraryState.playlists.length;

              return BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                builder: (context, recentState) {
                  final recentCount = recentState.tracks.length;

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Overview Grid Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard(
                            context,
                            'Total Diputar',
                            '${historyTracks.length}',
                            MingCute.music_2_line,
                            const Color(0xFF9C27B0),
                          ),
                          _buildStatCard(
                            context,
                            'Playlist Saya',
                            '$playlistsCount',
                            MingCute.playlist_2_line,
                            const Color(0xFF00E676),
                          ),
                          _buildStatCard(
                            context,
                            'Terakhir Diputar',
                            '$recentCount',
                            MingCute.time_line,
                            const Color(0xFF29B6F6),
                          ),
                          _buildStatCard(
                            context,
                            'Estimasi Waktu',
                            '${historyTracks.length * 3} Mnt',
                            MingCute.stopwatch_line,
                            const Color(0xFFFF9100),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Listening habits / Top songs section
                      const Text(
                        'Paling Sering Diputar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (historyTracks.isEmpty)
                        _buildEmptyState('Belum ada riwayat lagu.')
                      else
                        _buildTopTracksList(historyTracks),

                      const SizedBox(height: 24),

                      // Artist diversity
                      const Text(
                        'Artis Terpopuler Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (historyTracks.isEmpty)
                        _buildEmptyState('Belum ada riwayat artis.')
                      else
                        _buildTopArtists(historyTracks),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTopTracksList(List<Track> tracks) {
    // Count track frequencies
    final map = <String, int>{};
    final trackMap = <String, Track>{};
    for (final t in tracks) {
      map[t.id] = (map[t.id] ?? 0) + 1;
      trackMap[t.id] = t;
    }

    final sortedKeys = map.keys.toList()
      ..sort((a, b) => map[b]!.compareTo(map[a]!));

    final topKeys = sortedKeys.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topKeys.length,
        separatorBuilder: (c, i) => const Divider(
          color: Color(0xFF222225),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final id = topKeys[index];
          final t = trackMap[id]!;
          final count = map[id]!;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Image.network(
                  t.thumbnail.urlLow ?? t.thumbnail.url,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[900],
                    child: const Icon(MingCute.music_2_line, color: Colors.white24),
                  ),
                ),
              ),
            ),
            title: Text(
              t.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              t.artists.map((a) => a.name).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count x',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopArtists(List<Track> tracks) {
    // Count artist frequencies
    final map = <String, int>{};
    for (final t in tracks) {
      for (final a in t.artists) {
        map[a.name] = (map[a.name] ?? 0) + 1;
      }
    }

    final sortedArtists = map.keys.toList()
      ..sort((a, b) => map[b]!.compareTo(map[a]!));

    final topArtists = sortedArtists.take(3).toList();

    return Column(
      children: List.generate(topArtists.length, (index) {
        final artistName = topArtists[index];
        final count = map[artistName]!;
        final maxCount = map[topArtists.first]!;
        final ratio = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161618),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      artistName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$count Lagu',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
