import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streambeats/core/theme/app_theme.dart';
import 'package:streambeats/services/supabase_playlist_service.dart';
import 'package:streambeats/core/models/exported.dart' hide MediaItem;
import 'package:streambeats/screens/widgets/song_tile.dart';
import 'package:streambeats/screens/widgets/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streambeats/blocs/media_player/streambeats_player_cubit.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class SharedPlaylistScreen extends StatelessWidget {
  final String playlistCode;
  final String playlistTitle;
  
  const SharedPlaylistScreen({
    Key? key,
    required this.playlistCode,
    this.playlistTitle = 'Playlist Bersama',
  }) : super(key: key);

  void _showAddSongSheet(BuildContext context) {
    final playerCubit = context.read<StreamBeatsPlayerCubit>();
    final currentTrack = playerCubit.streambeatsPlayer.currentMedia;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Tambah Lagu ke "$playlistTitle"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white10),
            if (currentTrack.title.isNotEmpty)
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white10,
                    image: currentTrack.thumbnail.url.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(currentTrack.thumbnail.url),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentTrack.thumbnail.url.isEmpty
                      ? const Icon(Icons.music_note, color: Colors.white54)
                      : null,
                ),
                title: Text(
                  currentTrack.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  currentTrack.artists.isNotEmpty ? currentTrack.artists.first.name : '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                ),
                trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.purpleAccent),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await SupabasePlaylistService.addSongToPlaylist(playlistCode, currentTrack);
                    SnackbarService.showMessage('Lagu "${currentTrack.title}" berhasil ditambahkan!');
                  } catch (e) {
                    SnackbarService.showMessage('Gagal menambahkan lagu: $e');
                  }
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Tidak ada lagu yang sedang diputar.\nPutar lagu terlebih dahulu, lalu tekan tombol + untuk menambahkannya ke playlist ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Default_Theme.primaryColor1),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              playlistTitle,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Kode: $playlistCode',
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(MingCute.play_fill, color: Default_Theme.accentColor2),
            onPressed: () {
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2FF7),
        onPressed: () => _showAddSongSheet(context),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabasePlaylistService.streamPlaylist(playlistCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Default_Theme.accentColor2));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan.', style: TextStyle(color: Default_Theme.primaryColor2)),
            );
          }
          
          final rawSongs = snapshot.data ?? [];
          final tracks = rawSongs.map((s) => mapToTrack(s)).toList();

          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MingCute.music_2_line, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada lagu di playlist ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan tombol + di bawah untuk menambahkan\nlagu yang sedang diputar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return SongCardWidget(
                song: track,
                onTap: () {
                  context.read<StreamBeatsPlayerCubit>().streambeatsPlayer.updateQueueTracks(tracks, doPlay: true, startIndex: index);
                },
              );
            },
          );
        },
      ),
    );
  }
}