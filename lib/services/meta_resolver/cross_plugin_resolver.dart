import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:streambeats/services/plugin/plugin_service.dart';
import 'package:streambeats/src/rust/api/plugin/commands.dart';
import 'package:streambeats/src/rust/api/plugin/models.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

final RegExp _kBrackets = RegExp(r'[$$$$\(\){}]');
final RegExp _kAsciiPunct = RegExp(r'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]');
final RegExp _kMultiSpace = RegExp(r'\s+');
final RegExp _kParenthetical = RegExp(r'\(.*?\)');
final RegExp _kFeatSuffix = RegExp(r'\b(?:feat|ft|featuring)\b.*$');
final RegExp _kVersionWords =
    RegExp(r'\b(?:remaster(?:ed)?|version|edit|mix|remix)\b');
final RegExp _kEditionWords =
    RegExp(r'\b(?:single|album|deluxe|edition|bonus)\b');

final Map<String, List<RegExp>> _kVersionTagPatterns = {
  'live': [
    RegExp(r'\blive\b'),
    RegExp(r'\blive at\b'),
    RegExp(r'\blive from\b'),
    RegExp(r'\blive in\b'),
  ],
  'acoustic': [RegExp(r'\bacoustic\b')],
  'karaoke': [RegExp(r'\bkaraoke\b')],
  'instrumental': [RegExp(r'\binstrumental\b')],
  'remix': [RegExp(r'\bremix\b'), RegExp(r'\bmixed\b'), RegExp(r'\brmx\b')],
  'remaster': [RegExp(r'\bremaster\b'), RegExp(r'\bremastered\b')],
  'clean': [RegExp(r'\bclean\b')],
  'explicit': [RegExp(r'\bexplicit\b')],
  'demo': [RegExp(r'\bdemo\b')],
  'cover': [RegExp(r'\bcover\b')],
  'radio': [RegExp(r'\bradio edit\b'), RegExp(r'\bradio version\b')],
  'extended': [RegExp(r'\bextended\b')],
  'unplugged': [RegExp(r'\bunplugged\b')],
  'stripped': [RegExp(r'\bstripped\b')],
};

class TrackMatchTarget {
  final String title;

  final List<String> artistNames;
  final String? albumTitle;
  final BigInt? durationMs;

  const TrackMatchTarget({
    required this.title,
    required this.artistNames,
    this.albumTitle,
    this.durationMs,
  });

  factory TrackMatchTarget.fromTrack(Track track) => TrackMatchTarget(
        title: track.title,
        artistNames: track.artists
            .map((a) => a.name.trim())
            .where((n) => n.isNotEmpty)
            .toList(growable: false),
        albumTitle: track.album?.title,
        durationMs: track.durationMs,
      );

  factory TrackMatchTarget.fromImport({
    required String title,
    required List<String> artists,
    int? durationMs,
  }) =>
      TrackMatchTarget(
        title: title,
        artistNames:
            artists.map((a) => a.trim()).where((a) => a.isNotEmpty).toList(),
        albumTitle: null,
        durationMs: durationMs != null ? BigInt.from(durationMs) : null,
      );

  String get primaryArtist => artistNames.isNotEmpty ? artistNames.first : '';
  String get allArtists => artistNames.join(' ');
}

class ScoredTrackCandidate {
  final Track track;
  final String pluginId;

  final double confidence;

  const ScoredTrackCandidate({
    required this.track,
    required this.pluginId,
    required this.confidence,
  });

  @override
  String toString() => 'ScoredTrackCandidate(plugin=$pluginId, '
      'confidence=${(confidence * 100).toStringAsFixed(1)}%, '
      'track="${track.title}")';
}

class MediaSearchResult {
  final MediaItem item;
  final String pluginId;
  final int rank;

  const MediaSearchResult({
    required this.item,
    required this.pluginId,
    required this.rank,
  });
}

class CrossPluginResolver {
  final PluginService _pluginService;

  final Duration pluginTimeout;

  final int maxResultsPerQuery;

  const CrossPluginResolver({
    required PluginService pluginService,
    this.pluginTimeout = const Duration(seconds: 10),
    this.maxResultsPerQuery = 12,
  }) : _pluginService = pluginService;

  Future<List<ScoredTrackCandidate>> resolveTrack({
    required TrackMatchTarget target,
    required List<String> pluginIds,
    int limit = 5,
    double minConfidence = 0.45,
    double earlyAcceptThreshold = 0.93,
    bool sequential = false,
    Set<String> excludeTrackIds = const {},
    ContentSearchFilter searchFilter = ContentSearchFilter.track,
    List<String>? queries,
  }) async {
    if (pluginIds.isEmpty) return const [];

    final effectiveQueries = queries ?? buildTrackQueries(target);
    if (effectiveQueries.isEmpty) return const [];

    final candidates = <String, ScoredTrackCandidate>{};

    if (sequential) {
      for (final pluginId in pluginIds) {
        final batch = await _searchOnePlugin(
          pluginId: pluginId,
          target: target,
          queries: effectiveQueries,
          filter: searchFilter,
          minConfidence: minConfidence,
          earlyAcceptThreshold: earlyAcceptThreshold,
          excludeTrackIds: excludeTrackIds,
        );
        _mergeCandidates(candidates, batch);

        final best = _bestConfidence(candidates);
        if (best >= earlyAcceptThreshold) {
          log(
            'Early accept from $pluginId: '
            '${(best * 100).toStringAsFixed(1)}%',
            name: 'CrossPluginResolver',
          );
          break;
        }
      }
    } else {
      final futures = pluginIds.map((pluginId) => _searchOnePlugin(
            pluginId: pluginId,
            target: target,
            queries: effectiveQueries,
            filter: searchFilter,
            minConfidence: minConfidence,
            earlyAcceptThreshold: earlyAcceptThreshold,
            excludeTrackIds: excludeTrackIds,
          ).catchError((Object e) {
            log('Plugin $pluginId failed: $e', name: 'CrossPluginResolver');
            return <ScoredTrackCandidate>[];
          }));

      final batches = await Future.wait(futures);
      for (final batch in batches) {
        _mergeCandidates(candidates, batch);
      }
    }

    final sorted = candidates.values.toList(growable: false)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return sorted.take(limit).toList(growable: false);
  }

  Future<List<MediaSearchResult>> searchMedia({
    required String pluginId,
    required List<String> queries,
    required ContentSearchFilter filter,
  }) async {
    final results = <MediaSearchResult>[];

    for (final query in queries) {
      try {
        final response = await _pluginService
            .execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: query,
                  filter: filter,
                ),
              ),
            )
            .timeout(pluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            final items =
                field0.items.take(maxResultsPerQuery).toList(growable: false);
            for (var i = 0; i < items.length; i++) {
              results.add(MediaSearchResult(
                item: items[i],
                pluginId: pluginId,
                rank: i,
              ));
            }
          default:
        }
      } on TimeoutException {
        log('Timeout: plugin=$pluginId query="$query"',
            name: 'CrossPluginResolver');
      } catch (e) {
        log('Search failed: plugin=$pluginId query="$query" error=$e',
            name: 'CrossPluginResolver');
      }
    }

    return results;
  }

  double scoreTrack(TrackMatchTarget target, Track candidate) {
    final targetTitleNorm = normalized(target.title);
    final candTitleNorm = normalized(candidate.title);
    final targetArtKey = _artistKeyFromNames(target.artistNames);
    final candArtKey = artistKeyFromSummaries(candidate.artists);

    if (targetTitleNorm.isNotEmpty &&
        targetTitleNorm == candTitleNorm &&
        targetArtKey.isNotEmpty &&
        targetArtKey == candArtKey) {
      final dur = durationSimilarity(target.durationMs, candidate.durationMs);
      return (0.92 + dur * 0.08).clamp(0.0, 1.0);
    }

    final titleScore = blendedTextSimilarity(target.title, candidate.title);
    final simplifiedTitleScore = blendedTextSimilarity(
      simplifyTitle(target.title),
      simplifyTitle(candidate.title),
    );

    final candArtistNames = candidate.artists
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);
    final artistScore =
        artistNamesSimilarity(target.artistNames, candArtistNames);

    final dur = durationSimilarity(target.durationMs, candidate.durationMs);

    final targetAlbum = target.albumTitle?.trim() ?? '';
    final candAlbum = candidate.album?.title.trim() ?? '';
    final hasAlbum = targetAlbum.isNotEmpty && candAlbum.isNotEmpty;
    final albumScore =
        hasAlbum ? blendedTextSimilarity(targetAlbum, candAlbum) : 0.0;

    final vPenalty = versionPenalty(
      target.title,
      target.albumTitle,
      candidate.title,
      candidate.album?.title,
    );

    final wTitle = hasAlbum ? 0.32 : 0.36;
    final wSimplified = hasAlbum ? 0.12 : 0.14;
    final wArtist = hasAlbum ? 0.28 : 0.32;
    final wAlbum = hasAlbum ? 0.10 : 0.00;
    const wDuration = 0.13;

    var score = titleScore * wTitle +
        simplifiedTitleScore * wSimplified +
        artistScore * wArtist +
        albumScore * wAlbum +
        dur * wDuration;

    if (targetTitleNorm.isNotEmpty && targetTitleNorm == candTitleNorm) {
      score += 0.06;
    }
    final tSimple = simplifyTitle(target.title);
    final cSimple = simplifyTitle(candidate.title);
    if (tSimple.isNotEmpty && cSimple.isNotEmpty && tSimple == cSimple) {
      score += 0.04;
    }
    if (targetArtKey.isNotEmpty && targetArtKey == candArtKey) {
      score += 0.05;
    }

    score -= vPenalty;
    return score.clamp(0.0, 1.0);
  }

  bool isStrongMatch(TrackMatchTarget target, Track candidate) {
    final tNorm = normalized(target.title);
    final cNorm = normalized(candidate.title);
    final tSimple = simplifyTitle(target.title);
    final cSimple = simplifyTitle(candidate.title);

    final titleMatch =
        (tNorm.isNotEmpty && cNorm.isNotEmpty && tNorm == cNorm) ||
            (tSimple.isNotEmpty && cSimple.isNotEmpty && tSimple == cSimple);
    if (!titleMatch) return false;

    if (target.artistNames.isEmpty) return true;
    final candNames = candidate.artists
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);
    if (candNames.isEmpty) return true;

    return artistNamesSimilarity(target.artistNames, candNames) >= 0.7;
  }

  double blendedTextSimilarity(String? left, String? right) {
    final l = normalized(left);
    final r = normalized(right);
    if (l.isEmpty || r.isEmpty) return 0;
    if (l == r) return 1.0;

    final direct = fw.ratio(l, r) / 100;
    final partial = fw.partialRatio(l, r) / 100;
    final sorted = fw.tokenSortRatio(l, r) / 100;
    final overlap = tokenOverlap(l, r);

    return (direct * 0.35 + partial * 0.20 + sorted * 0.25 + overlap * 0.20)
        .clamp(0.0, 1.0);
  }

  double tokenOverlap(String left, String right) {
    final lt = left.split(' ').where((t) => t.isNotEmpty).toSet();
    final rt = right.split(' ').where((t) => t.isNotEmpty).toSet();
    if (lt.isEmpty || rt.isEmpty) return 0;
    final i = lt.intersection(rt).length;
    if (i == 0) return 0;
    final p = i / rt.length;
    final r = i / lt.length;
    return (2 * p * r) / (p + r);
  }

  double artistNamesSimilarity(
    List<String> leftNames,
    List<String> rightNames,
  ) {
    final ln =
        leftNames.where((n) => n.trim().isNotEmpty).toList(growable: false);
    final rn =
        rightNames.where((n) => n.trim().isNotEmpty).toList(growable: false);

    if (ln.isEmpty && rn.isEmpty) return 0;
    if (ln.isEmpty || rn.isEmpty) {
      return blendedTextSimilarity(ln.join(' '), rn.join(' '));
    }

    double fwd = 0;
    for (final n in ln) {
      var best = 0.0;
      for (final o in rn) {
        best = math.max(best, blendedTextSimilarity(n, o));
      }
      fwd += best;
    }

    double rev = 0;
    for (final n in rn) {
      var best = 0.0;
      for (final o in ln) {
        best = math.max(best, blendedTextSimilarity(n, o));
      }
      rev += best;
    }

    final combined = blendedTextSimilarity(ln.join(' '), rn.join(' '));
    final primaryBonus =
        blendedTextSimilarity(ln.first, rn.first) > 0.85 ? 0.05 : 0.0;

    return ((fwd / ln.length) * 0.35 +
            (rev / rn.length) * 0.30 +
            combined * 0.25 +
            primaryBonus)
        .clamp(0.0, 1.0);
  }

  double artistSummarySimilarity(
    List<ArtistSummary> left,
    List<ArtistSummary> right,
  ) {
    return artistNamesSimilarity(
      left.map((a) => a.name.trim()).where((n) => n.isNotEmpty).toList(),
      right.map((a) => a.name.trim()).where((n) => n.isNotEmpty).toList(),
    );
  }

  double durationSimilarity(BigInt? left, BigInt? right) {
    if (left == null || right == null) return 0.35;
    final lMs = left.toDouble();
    final rMs = right.toDouble();
    if (lMs <= 0 || rMs <= 0) return 0.35;

    final diff = (lMs - rMs).abs();
    final maxMs = math.max(lMs, rMs);
    final relErr = diff / maxMs;

    final double absScore;
    if (diff <= 1500) {
      absScore = 1.00;
    } else if (diff <= 3000) {
      absScore = 0.85;
    } else if (diff <= 5000) {
      absScore = 0.55;
    } else if (diff <= 10000) {
      absScore = 0.25;
    } else if (diff <= 20000) {
      absScore = 0.08;
    } else {
      absScore = 0.00;
    }

    final double relScore;
    if (relErr <= 0.02) {
      relScore = 1.00;
    } else if (relErr <= 0.05) {
      relScore = 0.85;
    } else if (relErr <= 0.10) {
      relScore = 0.55;
    } else if (relErr <= 0.20) {
      relScore = 0.25;
    } else if (relErr <= 0.35) {
      relScore = 0.08;
    } else {
      relScore = 0.00;
    }

    return (absScore * 0.50 + relScore * 0.50).clamp(0.0, 1.0);
  }

  Set<String> versionTags(String value) {
    if (value.isEmpty) return const {};
    final norm = value
        .toLowerCase()
        .replaceAll(_kBrackets, ' ')
        .replaceAll(_kAsciiPunct, ' ')
        .replaceAll(_kMultiSpace, ' ')
        .trim();
    if (norm.isEmpty) return const {};

    final tags = <String>{};
    for (final entry in _kVersionTagPatterns.entries) {
      if (entry.value.any((p) => p.hasMatch(norm))) tags.add(entry.key);
    }
    return tags;
  }

  double versionPenalty(
    String? targetTitle,
    String? targetAlbum,
    String? candidateTitle,
    String? candidateAlbum,
  ) {
    final tt = versionTags(joinNonEmpty([targetTitle, targetAlbum]));
    final ct = versionTags(joinNonEmpty([candidateTitle, candidateAlbum]));
    if (tt.isEmpty && ct.isEmpty) return 0;
    final missing = tt.difference(ct).length;
    final extra = ct.difference(tt).length;
    return (missing * 0.08 + extra * 0.04).clamp(0.0, 0.25);
  }

  String normalized(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return value
        .toLowerCase()
        .replaceAll(_kBrackets, ' ')
        .replaceAll('&', ' and ')
        .replaceAll(_kAsciiPunct, ' ')
        .replaceAll(_kMultiSpace, ' ')
        .trim();
  }

  String simplifyTitle(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return value
        .trim()
        .replaceAll(_kParenthetical, ' ')
        .toLowerCase()
        .replaceAll(_kFeatSuffix, '')
        .replaceAll(_kVersionWords, ' ')
        .replaceAll(_kEditionWords, ' ')
        .replaceAll(_kAsciiPunct, ' ')
        .replaceAll('&', ' and ')
        .replaceAll(_kMultiSpace, ' ')
        .trim();
  }

  String artistNamesJoined(List<ArtistSummary> artists) {
    return artists
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .join(' ');
  }

  String artistKeyFromSummaries(List<ArtistSummary> artists) {
    return _artistKeyFromNames(
      artists.map((a) => a.name).toList(growable: false),
    );
  }

  String _artistKeyFromNames(List<String> names) {
    final norm = names
        .map((n) => normalized(n))
        .where((n) => n.isNotEmpty)
        .toList(growable: false)
      ..sort();
    return norm.join('|');
  }

  List<String> buildTrackQueries(TrackMatchTarget target) {
    final title = target.title.trim();
    final simplified = simplifyTitle(title);
    final allArtists = target.allArtists;
    final primary = target.primaryArtist;
    final album = target.albumTitle?.trim() ?? '';

    final seen = <String>{};
    final queries = <String>[];

    void add(String q) {
      final t = q.trim();
      if (t.isEmpty) return;
      final k = normalized(t);
      if (k.isEmpty || !seen.add(k)) return;
      queries.add(t);
    }

    add('$title $allArtists');
    if (simplified != normalized(title)) add('$simplified $allArtists');
    add('$title $primary');
    if (album.isNotEmpty) add('$title $primary $album');
    add(title);
    if (simplified.isNotEmpty && simplified != normalized(title)) {
      add(simplified);
    }

    return queries;
  }

  String joinNonEmpty(List<String?> parts) {
    return parts
        .map((p) => p?.trim() ?? '')
        .where((p) => p.isNotEmpty)
        .join(' ');
  }

  List<String> uniqueQueries(List<String> values) {
    final seen = <String>{};
    final queries = <String>[];
    for (final v in values) {
      final q = v.trim();
      if (q.isEmpty) continue;
      final k = normalized(q);
      if (k.isEmpty || !seen.add(k)) continue;
      queries.add(q);
    }
    return queries;
  }

  Future<List<ScoredTrackCandidate>> _searchOnePlugin({
    required String pluginId,
    required TrackMatchTarget target,
    required List<String> queries,
    required ContentSearchFilter filter,
    required double minConfidence,
    required double earlyAcceptThreshold,
    required Set<String> excludeTrackIds,
  }) async {
    final candidates = <String, ScoredTrackCandidate>{};
    double bestThisPlugin = 0;

    for (final query in queries) {
      if (bestThisPlugin >= earlyAcceptThreshold) break;

      try {
        final response = await _pluginService
            .execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: query,
                  filter: filter,
                ),
              ),
            )
            .timeout(pluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            final items =
                field0.items.take(maxResultsPerQuery).toList(growable: false);
            for (final item in items) {
              final track = switch (item) {
                MediaItem_Track(:final field0) => field0,
                _ => null,
              };
              if (track == null) continue;
              if (excludeTrackIds.contains(track.id)) continue;

              final confidence = scoreTrack(target, track);
              if (confidence < minConfidence) continue;
              if (confidence > bestThisPlugin) bestThisPlugin = confidence;

              final existing = candidates[track.id];
              if (existing == null || confidence > existing.confidence) {
                candidates[track.id] = ScoredTrackCandidate(
                  track: track,
                  pluginId: pluginId,
                  confidence: confidence,
                );
              }
            }
          default:
        }
      } on TimeoutException {
        log('Timeout: plugin=$pluginId query="$query"',
            name: 'CrossPluginResolver');
      } catch (e) {
        log('Search failed: plugin=$pluginId query="$query" error=$e',
            name: 'CrossPluginResolver');
      }
    }

    return candidates.values.toList(growable: false);
  }

  void _mergeCandidates(
    Map<String, ScoredTrackCandidate> target,
    List<ScoredTrackCandidate> batch,
  ) {
    for (final c in batch) {
      final existing = target[c.track.id];
      if (existing == null || c.confidence > existing.confidence) {
        target[c.track.id] = c;
      }
    }
  }

  double _bestConfidence(Map<String, ScoredTrackCandidate> candidates) {
    if (candidates.isEmpty) return 0;
    return candidates.values
        .map((c) => c.confidence)
        .reduce((a, b) => a > b ? a : b);
  }
}

class Semaphore {
  final int maxConcurrent;
  int _active = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this.maxConcurrent);

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= maxConcurrent) {
      final waiter = Completer<void>();
      _queue.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      }
    }
  }
}