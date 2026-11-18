import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'guide_content.dart';

/// The age group the Guide shows advice for. Set from the profile age when
/// the Guide opens; the reader can switch it on any page.
final ValueNotifier<AgeGroup> guideAgeGroup = ValueNotifier(AgeGroup.adults);

/// Saves the 7-day challenge and the personal action plan.
///
/// PREVIEW: stored on this device only (per user), so the screens can be
/// tried out. Moves to Supabase (with coins) once the UI is approved.
class GuideStore {
  GuideStore._();

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Guide storage unavailable: $e');
      return null;
    }
  }

  /// Monday of the week containing [day] (local date, no time).
  static DateTime weekStart(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static String _weekKey(String userId, DateTime monday) =>
      'guide_challenge_${userId}_${monday.year}-${monday.month}-${monday.day}';

  /// Ticks for one week: habit index → set of weekday indexes (0 = Mon).
  static Future<ChallengeWeek> loadWeek(String userId, DateTime monday) async {
    final raw = (await _prefs())?.getString(_weekKey(userId, monday));
    if (raw == null) return ChallengeWeek.empty();
    try {
      return ChallengeWeek.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return ChallengeWeek.empty();
    }
  }

  static Future<void> saveWeek(
    String userId,
    DateTime monday,
    ChallengeWeek w,
  ) async {
    try {
      await (await _prefs())?.setString(
        _weekKey(userId, monday),
        jsonEncode(w.toJson()),
      );
    } catch (e) {
      debugPrint('Could not save challenge: $e');
    }
  }

  static String _planKey(String userId) => 'guide_plan_$userId';

  /// Plan field values by key (`gd_pl1T` … plus `date` and `ask`).
  static Future<Map<String, String>> loadPlan(String userId) async {
    final raw = (await _prefs())?.getString(_planKey(userId));
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, '$v'),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> savePlan(String userId, Map<String, String> plan) async {
    try {
      await (await _prefs())?.setString(_planKey(userId), jsonEncode(plan));
    } catch (e) {
      debugPrint('Could not save plan: $e');
    }
  }
}

/// One week of the 7-day challenge.
class ChallengeWeek {
  /// habit index → weekday indexes ticked (0 = Monday … 6 = Sunday).
  final Map<int, Set<int>> ticks;
  String success;
  String improve;

  ChallengeWeek(this.ticks, {this.success = '', this.improve = ''});

  factory ChallengeWeek.empty() => ChallengeWeek({});

  bool isTicked(int habit, int day) => ticks[habit]?.contains(day) ?? false;

  void toggle(int habit, int day) {
    final set = ticks.putIfAbsent(habit, () => <int>{});
    if (!set.remove(day)) set.add(day);
  }

  int doneOn(int day) => ticks.values.where((s) => s.contains(day)).length;

  int get total => ticks.values.fold(0, (a, s) => a + s.length);

  Map<String, dynamic> toJson() => {
    'ticks': {
      for (final e in ticks.entries) '${e.key}': e.value.toList()..sort(),
    },
    'success': success,
    'improve': improve,
  };

  factory ChallengeWeek.fromJson(Map<String, dynamic> j) => ChallengeWeek(
    {
      for (final e in ((j['ticks'] as Map?) ?? {}).entries)
        int.parse('${e.key}'): {
          for (final d in (e.value as List)) (d as num).toInt(),
        },
    },
    success: '${j['success'] ?? ''}',
    improve: '${j['improve'] ?? ''}',
  );
}
