/// Streak maths for the profile screen. Dates are compared by calendar day
/// only; any time-of-day part is ignored.
library;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Consecutive active days ending today — or ending yesterday, so a streak
/// isn't shown as broken before the user has opened the app today.
int currentStreak(Iterable<DateTime> activeDays, DateTime today) {
  final days = activeDays.map(_day).toSet();
  var cursor = _day(today);
  if (!days.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return streak;
}

/// Longest run of consecutive active days ever.
int longestStreak(Iterable<DateTime> activeDays) {
  final days = activeDays.map(_day).toSet().toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final day in days) {
    final isNextDay = previous != null &&
        DateTime(previous.year, previous.month, previous.day + 1) == day;
    run = isNextDay ? run + 1 : 1;
    if (run > best) best = run;
    previous = day;
  }
  return best;
}
