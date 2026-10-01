/// This week vs last week, for the Profile's weekly summary card.
library;

import 'daily_store.dart';

class WeeklySummary {
  /// Average daily log score this week (null = nothing logged).
  final int? averageScore;
  final int? lastWeekAverage;
  final int daysLogged;
  final int daysCheckedIn;
  final DateTime? bestDay;
  final int? bestScore;

  const WeeklySummary({
    required this.averageScore,
    required this.lastWeekAverage,
    required this.daysLogged,
    required this.daysCheckedIn,
    required this.bestDay,
    required this.bestScore,
  });

  /// Change in average score vs last week (null if either week is empty).
  int? get change => averageScore == null || lastWeekAverage == null
      ? null
      : averageScore! - lastWeekAverage!;
}

/// Weeks run Monday–Sunday in the user's local time.
WeeklySummary weeklySummary(Iterable<DailyEntry> days, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );
  final lastWeekStart = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day - 7,
  );

  bool inRange(DateTime d, DateTime from, DateTime to) =>
      !d.isBefore(from) && d.isBefore(to);
  final thisWeek = days.where(
    (e) => inRange(e.day, weekStart, today.add(const Duration(days: 1))),
  );
  final lastWeek = days.where((e) => inRange(e.day, lastWeekStart, weekStart));

  int? avg(Iterable<DailyEntry> es) {
    final scores = [
      for (final e in es)
        if (e.logged && e.score != null) e.score!,
    ];
    return scores.isEmpty
        ? null
        : (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  DailyEntry? best;
  for (final e in thisWeek) {
    if (e.logged && e.score != null && (best == null || e.score! > best.score!)) {
      best = e;
    }
  }

  return WeeklySummary(
    averageScore: avg(thisWeek),
    lastWeekAverage: avg(lastWeek),
    daysLogged: thisWeek.where((e) => e.logged).length,
    daysCheckedIn: thisWeek.where((e) => e.checkedIn).length,
    bestDay: best?.day,
    bestScore: best?.score,
  );
}
