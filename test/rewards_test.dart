import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/daily/daily_store.dart';
import 'package:livrcheck_app/daily/daily_targets.dart';
import 'package:livrcheck_app/daily/weekly_summary.dart';
import 'package:livrcheck_app/rewards/badges.dart';
import 'package:livrcheck_app/rewards/reward_store.dart';

DailyEntry _day(DateTime d, {int? score, bool logged = true}) => DailyEntry(
      day: d,
      checkedIn: true,
      log: logged ? const DailyLog(waterMl: 2000) : null,
      score: logged ? score : null,
      coins: 0,
    );

void main() {
  group('badges', () {
    test('a brand-new user has nothing unlocked', () {
      final b = computeBadges(
        healthChecks: 0, scoreImproved: false, longestStreak: 0, bestDayScore: 0,
        coins: 0, bloodReportAdded: false, specialSurveysDone: 0,
      );
      expect(b.where((x) => x.unlocked), isEmpty);
      expect(b.every((x) => x.hint.isNotEmpty), isTrue);
    });

    test('streak, coin and survey badges unlock at their thresholds', () {
      final b = {
        for (final x in computeBadges(
          healthChecks: 1, scoreImproved: true, longestStreak: 7, bestDayScore: 92,
          coins: 120, bloodReportAdded: true, specialSurveysDone: 1,
        ))
          x.label: x.unlocked,
      };
      expect(b['3-day streak'], isTrue);
      expect(b['7-day streak'], isTrue);
      expect(b['30-day streak'], isFalse);
      expect(b['100 coins'], isTrue);
      expect(b['500 coins'], isFalse);
      expect(b['Survey star'], isTrue);
    });
  });

  group('weekly summary', () {
    // Wednesday 1 Oct 2026; the week started Monday 29 Sep.
    final now = DateTime(2026, 10, 1, 18);

    test('averages this week and compares with last week', () {
      final s = weeklySummary([
        _day(DateTime(2026, 9, 29), score: 80),
        _day(DateTime(2026, 9, 30), score: 90),
        _day(DateTime(2026, 9, 22), score: 60), // last week
        _day(DateTime(2026, 9, 24), score: 70), // last week
      ], now);
      expect(s.averageScore, 85);
      expect(s.lastWeekAverage, 65);
      expect(s.change, 20);
      expect(s.daysLogged, 2);
      expect(s.bestScore, 90);
      expect(s.bestDay, DateTime(2026, 9, 30));
    });

    test('check-in-only days count as checked in but not logged', () {
      final s = weeklySummary([_day(DateTime(2026, 10, 1), logged: false)], now);
      expect(s.averageScore, isNull);
      expect(s.daysCheckedIn, 1);
      expect(s.daysLogged, 0);
      expect(s.change, isNull);
    });
  });

  test('special survey questions are read from JSON', () {
    final q = SurveyQuestion.fromJson({
      'id': 'water',
      'type': 'choice',
      'title': 'How much water do you drink?',
      'options': [
        {'v': 'low', 'label': 'Under 1 L', 'emoji': '🥤'},
        {'v': 'ok', 'label': '2–3 L'},
      ],
    });
    expect(q.type, 'choice');
    expect(q.options.length, 2);
    expect(q.options.last.emoji, '');
    expect(SurveyQuestion.fromJson({'id': 'x', 'title': 'Note'}).type, 'choice');
  });
}
