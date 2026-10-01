import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/data_service.dart';
import '../survey/progress_store.dart' show dayKey;
import 'daily_targets.dart';

/// One day in the "Every day" history.
class DailyEntry {
  final DateTime day;
  final bool checkedIn;
  final DailyLog? log;
  final int? score;
  final int coins;

  const DailyEntry({
    required this.day,
    required this.checkedIn,
    required this.log,
    required this.score,
    required this.coins,
  });

  bool get logged => log != null && !log!.isEmpty;
}

class DailySummary {
  /// Keyed by 'yyyy-mm-dd'.
  final Map<String, DailyEntry> days;
  final int totalCoins;

  const DailySummary(this.days, this.totalCoins);

  DailyEntry? get today => days[dayKey(DateTime.now())];
}

/// Result of saving a day's log: the score and the coins newly earned.
class LogOutcome {
  final int score;
  final int coinsEarned;

  const LogOutcome(this.score, this.coinsEarned);
}

/// Adds up coin rows ({day, amount}) into a total and per-day totals.
/// Special survey coins have no day (they're once per survey, not per
/// day): they count towards the total but not any single day.
({Map<String, int> byDay, int total}) sumCoins(List<Map<String, dynamic>> rows) {
  final byDay = <String, int>{};
  var total = 0;
  for (final row in rows) {
    final amount = (row['amount'] as num).toInt();
    total += amount;
    final day = row['day'] as String?;
    if (day != null) byDay[day] = (byDay[day] ?? 0) + amount;
  }
  return (byDay: byDay, total: total);
}

/// Daily check-ins, daily logs and coins, stored in Supabase (tables
/// daily_checkins and coin_events — see supabase/migrations/).
class DailyStore {
  DailyStore._();

  static SupabaseClient get _db => Supabase.instance.client;

  static String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not signed in');
    return id;
  }

  static Future<DailySummary> load({int days = 120}) async {
    final since = dayKey(DateTime.now().subtract(Duration(days: days)));
    final results = await Future.wait([
      _db.from('daily_checkins').select().gte('day', since),
      _db.from('coin_events').select('day, amount'),
    ]);

    final (byDay: coinsByDay, total: total) = sumCoins(results[1]);

    final entries = <String, DailyEntry>{};
    for (final row in results[0]) {
      final day = row['day'] as String;
      final log = DailyLog.fromMap(row);
      entries[day] = DailyEntry(
        day: DateTime.parse(day),
        checkedIn: true,
        log: row['logged_at'] == null ? null : log,
        score: row['score'] as int?,
        coins: coinsByDay[day] ?? 0,
      );
    }
    return DailySummary(entries, total);
  }

  /// Taps "Check in" for today: +1 coin, once a day.
  static Future<bool> checkIn() async {
    final uid = _uid;
    final today = dayKey(DateTime.now());
    await _db
        .from('daily_checkins')
        .upsert(
          {'user_id': uid, 'day': today},
          onConflict: 'user_id,day',
          ignoreDuplicates: true,
        );
    final earned = await _award(uid, today, 'checkin', coinsForCheckin);
    DataService.changes.value++;
    return earned;
  }

  /// Saves today's log and awards coins the first time each is earned.
  static Future<LogOutcome> saveLog(DailyLog log, DailyTargets targets) async {
    final uid = _uid;
    final today = dayKey(DateTime.now());
    final score = scoreDay(log, targets).score;
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.from('daily_checkins').upsert({
      'user_id': uid,
      'day': today,
      ...log.toMap(),
      'score': score,
      'logged_at': now,
      'updated_at': now,
    }, onConflict: 'user_id,day');

    var coins = 0;
    // Logging counts as checking in too.
    if (await _award(uid, today, 'checkin', coinsForCheckin)) {
      coins += coinsForCheckin;
    }
    if (await _award(uid, today, 'daily_log', coinsForLog)) {
      coins += coinsForLog;
    }
    if (score >= bonusScore &&
        await _award(uid, today, 'daily_bonus', coinsForBonus)) {
      coins += coinsForBonus;
    }
    DataService.changes.value++;
    return LogOutcome(score, coins);
  }

  /// Inserts a coin event; returns false if it was already earned today.
  static Future<bool> _award(
    String uid,
    String day,
    String reason,
    int amount,
  ) async {
    final rows = await _db
        .from('coin_events')
        .upsert(
          {'user_id': uid, 'day': day, 'reason': reason, 'amount': amount},
          onConflict: 'user_id,day,reason',
          ignoreDuplicates: true,
        )
        .select('id');
    return rows.isNotEmpty;
  }
}
