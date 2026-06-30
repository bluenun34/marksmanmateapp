import 'package:collection/collection.dart';

import '../providers/shoot_log_provider.dart';

class ShootLogAnalyticsSnapshot {
  const ShootLogAnalyticsSnapshot({
    required this.totalSessions,
    required this.totalRounds,
    required this.hitRatePercent,
    required this.roundsByMonth,
    required this.roundsByDiscipline,
    required this.avgRating,
    required this.sessionsThisMonth,
    required this.roundsThisMonth,
  });

  final int totalSessions;
  final int totalRounds;
  final int? hitRatePercent;
  final List<({String label, int rounds})> roundsByMonth;
  final List<({String label, int rounds})> roundsByDiscipline;
  final double? avgRating;
  final int sessionsThisMonth;
  final int roundsThisMonth;
}

ShootLogAnalyticsSnapshot buildShootLogAnalytics(List<SessionItem> sessions) {
  final now = DateTime.now();
  var totalRounds = 0;
  var totalHits = 0;
  var totalMisses = 0;
  var ratingSum = 0;
  var ratingCount = 0;
  var sessionsThisMonth = 0;
  var roundsThisMonth = 0;

  final byMonth = <String, int>{};
  final byDiscipline = <String, int>{};

  for (final item in sessions) {
    final rounds = item.totalRounds ?? 0;
    totalRounds += rounds;
    totalHits += item.local.totalHits ?? 0;
    totalMisses += item.local.totalMisses ?? 0;

    final rating = item.local.rating;
    if (rating != null && rating > 0) {
      ratingSum += rating;
      ratingCount++;
    }

    if (item.date.year == now.year && item.date.month == now.month) {
      sessionsThisMonth++;
      roundsThisMonth += rounds;
    }

    final monthKey =
        '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}';
    byMonth[monthKey] = (byMonth[monthKey] ?? 0) + rounds;

    final discipline = item.local.discipline;
    byDiscipline[discipline] = (byDiscipline[discipline] ?? 0) + rounds;
  }

  final attempts = totalHits + totalMisses;
  final hitRate = attempts > 0 ? (100 * totalHits / attempts).round() : null;

  final monthRows = byMonth.entries
      .sorted((a, b) => b.key.compareTo(a.key))
      .take(6)
      .map((e) => (label: e.key, rounds: e.value))
      .toList();

  final disciplineRows = byDiscipline.entries
      .sorted((a, b) => b.value.compareTo(a.value))
      .map((e) => (label: e.key, rounds: e.value))
      .toList();

  return ShootLogAnalyticsSnapshot(
    totalSessions: sessions.length,
    totalRounds: totalRounds,
    hitRatePercent: hitRate,
    roundsByMonth: monthRows,
    avgRating: ratingCount > 0 ? ratingSum / ratingCount : null,
    roundsByDiscipline: disciplineRows,
    sessionsThisMonth: sessionsThisMonth,
    roundsThisMonth: roundsThisMonth,
  );
}
