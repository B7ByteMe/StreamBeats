import 'dart:developer';
import 'dart:io';
import 'package:streambeats/core/models/exported.dart';
import 'package:streambeats/core/constants/sentinel_values.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

class DiscordService {
  static DiscordRPC? _discordRPC;
  static int? _startTimeStamp; // Persisting timestamp

  static void initialize() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        DiscordRPC.initialize();
        _discordRPC = DiscordRPC(applicationId: '1339113296405725235');
        _discordRPC?.start(autoRegister: true);
        log(" Discord RPC initialized successfully", name: "DiscordService");
      } catch (e) {
        log(' Failed to initialize Discord RPC: $e', name: "DiscordService");
      }
    }
  }

  static void updatePresence({
    required Track track,
    required bool isPlaying,
  }) {
    if (_discordRPC != null && !isTrackNull(track)) {
      try {
        _startTimeStamp ??= DateTime.now().millisecondsSinceEpoch;

        final artistStr = track.artists.isNotEmpty
            ? track.artists.map((a) => a.name).join(', ')
            : 'Unknown Artist';

        _discordRPC!.updatePresence(
          DiscordPresence(
              details: track.title,
              state: isPlaying ? "Playing・$artistStr" : "Paused・$artistStr",
              largeImageKey: "streambeatstunes_logo",
              largeImageText: "StreamBeats",
              startTimeStamp: _startTimeStamp),
        );
      } catch (e) {
        log(" Discord RPC Error: $e", name: "DiscordService");
      }
    }
  }

  static void clearPresence() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        _discordRPC?.clearPresence();
        log(" Cleared Discord Presence", name: "DiscordService");
      } catch (e) {
        log(" Failed to clear Discord RPC: $e", name: "DiscordService");
      }
    }
  }
}