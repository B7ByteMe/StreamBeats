import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:streambeats/core/models/exported.dart' hide MediaItem;

import 'package:streambeats/core/models/exported.dart' hide MediaItem;

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

enum PartyRole { host, guest, none }

class SupabasePartyService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static RealtimeChannel? _channel;
  
  static PartyRole currentRole = PartyRole.none;
  static String? currentRoomCode;
  
  static Function(Track)? onTrackPlay;
  static Function()? onPause;
  static Function()? onResume;
  static Function(Duration)? onSeek;

  static Future<String?> createParty() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    currentRoomCode = _generateCode();
    currentRole = PartyRole.host;

    await _joinChannel(currentRoomCode!);
    return currentRoomCode;
  }

  static Future<bool> joinParty(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    currentRoomCode = code;
    currentRole = PartyRole.guest;

    await _joinChannel(code);
    return true; // Assume success for broadcast channels
  }

  static Timer? _reconnectTimer;

  static void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      if (currentRoomCode != null && currentRole != PartyRole.none) {
        print('SupabasePartyService: Attempting to reconnect to room $currentRoomCode...');
        await _joinChannel(currentRoomCode!);
      }
    });
  }

  static Future<void> reconnectIfNecessary() async {
    if (currentRoomCode != null && currentRole != PartyRole.none) {
      print('SupabasePartyService: Force reconnecting on app resume...');
      await _joinChannel(currentRoomCode!);
    }
  }

  static Future<void> leaveParty() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
    currentRole = PartyRole.none;
    currentRoomCode = null;
  }

  static Future<void> _joinChannel(String code) async {
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
    }

    _channel = _supabase.channel('party_$code');

    _channel!
      .onBroadcast(
        event: 'playback_sync',
        callback: (payload) {
          if (currentRole == PartyRole.guest) {
            _handleBroadcastMessage(payload);
          }
        },
      )
      .subscribe((status, [error]) {
        print('SupabasePartyService: subscription status: $status, error: $error');
        if (status == RealtimeSubscribeStatus.closed ||
            status == RealtimeSubscribeStatus.channelError) {
          _scheduleReconnect();
        } else if (status == RealtimeSubscribeStatus.subscribed) {
          _reconnectTimer?.cancel();
          _reconnectTimer = null;
        }
      });
  }

  static void _handleBroadcastMessage(Map<String, dynamic> payload) {
    final action = payload['action'] as String?;
    if (action == null) return;

    switch (action) {
      case 'PLAY_TRACK':
        if (onTrackPlay != null && payload['track'] != null) {
          final track = mapToTrack(Map<String, dynamic>.from(payload['track']));
          onTrackPlay!(track);
        }
        break;
      case 'PAUSE':
        if (onPause != null) onPause!();
        break;
      case 'RESUME':
        if (onResume != null) onResume!();
        break;
      case 'SEEK':
        if (onSeek != null && payload['position'] != null) {
          final pos = Duration(milliseconds: payload['position']);
          onSeek!(pos);
        }
        break;
    }
  }

  static void broadcastPlayTrack(Track track) {
    if (currentRole != PartyRole.host || _channel == null) return;
    _channel!.sendBroadcastMessage(
      event: 'playback_sync',
      payload: {
        'action': 'PLAY_TRACK',
        'track': trackToMap(track),
      },
    );
  }

  static void broadcastPause() {
    if (currentRole != PartyRole.host || _channel == null) return;
    _channel!.sendBroadcastMessage(
      event: 'playback_sync',
      payload: {'action': 'PAUSE'},
    );
  }

  static void broadcastResume() {
    if (currentRole != PartyRole.host || _channel == null) return;
    _channel!.sendBroadcastMessage(
      event: 'playback_sync',
      payload: {'action': 'RESUME'},
    );
  }

  static void broadcastSeek(Duration position) {
    if (currentRole != PartyRole.host || _channel == null) return;
    _channel!.sendBroadcastMessage(
      event: 'playback_sync',
      payload: {
        'action': 'SEEK',
        'position': position.inMilliseconds,
      },
    );
  }

  static String _generateCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
}