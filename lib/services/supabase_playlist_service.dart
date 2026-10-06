import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:streambeats/core/models/exported.dart' hide MediaItem;
import 'package:streambeats/services/db/db_provider.dart';
import 'package:streambeats/services/db/dao/settings_dao.dart';

Map<String, dynamic> trackToMap(Track track) {
  return {
    'id': track.id,
    'title': track.title,
    'artist': track.artists.isNotEmpty ? track.artists.first.name : '',
    'thumbnailUrl': track.thumbnail.url,
    'durationMs': track.durationMs?.toInt(),
  };
}

Track mapToTrack(Map<String, dynamic> map) {
  return Track(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    artists: [ArtistSummary(id: '', name: map['artist'] ?? '')],
    thumbnail: Artwork(url: map['thumbnailUrl'] ?? '', layout: ImageLayout.square),
    durationMs: map['durationMs'] != null ? BigInt.from(map['durationMs']) : null,
    isExplicit: false,
  );
}

class SupabasePlaylistService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'shared_playlists';

  static final _refreshController = StreamController<void>.broadcast();
  static Stream<void> get refreshStream => _refreshController.stream;

  static Future<String?> createSharedPlaylist(String title, List<Track> initialSongs) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    final code = _generateCode();
    
    final songsJson = initialSongs.map((t) => trackToMap(t)).toList();

    try {
      await _supabase.from(_table).insert({
        'code': code,
        'title': title,
        'owner_id': user.id,
        'members': [user.id],
        'songs': songsJson,
      });
      await _saveSharedPlaylistLocally(code, title);
      return code;
    } catch (e) {
      print('Error creating shared playlist: $e');
      rethrow;
    }
  }

  static Future<bool> joinPlaylist(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      final response = await _supabase.from(_table).select().eq('code', code).maybeSingle();
      if (response == null) return false;

      List<dynamic> members = response['members'] ?? [];
      if (!members.contains(user.id)) {
        members.add(user.id);
        await _supabase.from(_table).update({'members': members}).eq('code', code);
      }
      final title = response['title'] ?? 'Playlist Bersama';
      await _saveSharedPlaylistLocally(code, title);
      return true;
    } catch (e) {
      print('Error joining playlist: $e');
      return false;
    }
  }

  static Stream<List<Map<String, dynamic>>> streamPlaylist(String code) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('code', code)
        .map((maps) {
          if (maps.isEmpty) return [];
          final data = maps.first;
          final List<dynamic> rawSongs = data['songs'] ?? [];
          return rawSongs.cast<Map<String, dynamic>>();
        });
  }

  static Future<void> addSongToPlaylist(String code, Track track) async {
    try {
      final response = await _supabase.from(_table).select().eq('code', code).maybeSingle();
      if (response == null) return;

      List<dynamic> currentSongs = response['songs'] ?? [];
      if (!currentSongs.any((s) => s['id'] == track.id)) {
        currentSongs.add(trackToMap(track));
        
        await _supabase.from(_table).update({'songs': currentSongs}).eq('code', code);
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
    }
  }

  static String _generateCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<void> _saveSharedPlaylistLocally(String code, String title) async {
    try {
      final settings = SettingsDAO(DBProvider.db);
      final raw = await settings.getSettingStr('local_shared_playlists') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      
      if (!list.any((item) => item['code'] == code)) {
        list.add({'code': code, 'title': title});
        await settings.putSettingStr('local_shared_playlists', jsonEncode(list));
        _refreshController.add(null);
      }
    } catch (e) {
      print('Error saving shared playlist locally: $e');
    }
  }

  static Future<List<Map<String, String>>> getLocalSharedPlaylists() async {
    try {
      final settings = SettingsDAO(DBProvider.db);
      final raw = await settings.getSettingStr('local_shared_playlists') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => {
        'code': item['code'].toString(),
        'title': item['title'].toString(),
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> removeLocalSharedPlaylist(String code) async {
    try {
      final settings = SettingsDAO(DBProvider.db);
      final raw = await settings.getSettingStr('local_shared_playlists') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      list.removeWhere((item) => item['code'] == code);
      await settings.putSettingStr('local_shared_playlists', jsonEncode(list));
      _refreshController.add(null);
    } catch (e) {
      print('Error removing shared playlist locally: $e');
    }
  }
}