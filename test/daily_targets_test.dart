import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/daily/daily_targets.dart';

void main() {
  group('targetsFor', () {
    test('water is about 35 ml per kg, within 2–3.5 L', () {
      expect(targetsFor(weightKg: 60).waterMl, 2100);
      expect(targetsFor(weightKg: 40).waterMl, 2000);
      expect(targetsFor(weightKg: 150).waterMl, 3500);
    });

    test('calories include a deficit above the Asian BMI limit', () {
      final healthy = targetsFor(gender: 'male', age: 30, heightCm: 175, weightKg: 65);
      final heavy = targetsFor(gender: 'male', age: 30, heightCm: 175, weightKg: 85);
      expect(healthy.caloriesNote, contains('keep'));
      expect(heavy.caloriesNote, contains('deficit'));
      expect(healthy.calories % 50, 0);
    });

    test('calories never go below a safe minimum', () {
      final t = targetsFor(gender: 'female', age: 70, heightCm: 145, weightKg: 60);
      expect(t.calories, greaterThanOrEqualTo(1200));
    });

    test('older adults get a lower step goal', () {
      expect(targetsFor(age: 65).steps, lessThan(targetsFor(age: 30).steps));
    });
  });

  group('scoreDay', () {
    final t = targetsFor(gender: 'male', age: 30, heightCm: 175, weightKg: 70);

    test('meeting every target scores 100', () {
      final r = scoreDay(
        DailyLog(
          waterMl: t.waterMl, calories: t.calories, exerciseMin: 30,
          steps: t.steps, sleepHours: 8, fruitVeg: 5, sugaryItems: 0,
        ),
        t,
      );
      expect(r.score, 100);
      expect(r.items.length, 7);
    });

    test('skipped items are not counted', () {
      final r = scoreDay(const DailyLog(exerciseMin: 30), t);
      expect(r.score, 100);
      expect(r.items.length, 1);
    });

    test('an empty log scores 0', () {
      expect(scoreDay(const DailyLog(), t).score, 0);
    });

    test('half the water target gives half marks for water', () {
      final r = scoreDay(DailyLog(waterMl: t.waterMl ~/ 2), t);
      expect(r.score, 50);
    });

    test('eating far above the calorie target scores 0 for calories', () {
      final r = scoreDay(DailyLog(calories: (t.calories * 1.5).round()), t);
      expect(r.score, 0);
    });

    test('short sleep and sweets pull the score down', () {
      final r = scoreDay(const DailyLog(sleepHours: 5, sugaryItems: 3), t);
      expect(r.score, lessThan(50));
    });
  });
}
