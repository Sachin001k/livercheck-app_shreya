/// Daily healthy targets and the score for a day's log.
///
/// Targets are personalised from the profile (sex, age, height, weight).
/// Sources: water ~35 ml/kg (ICMR-NIN / EFSA ranges), calories from the
/// Mifflin-St Jeor equation, activity from WHO (150 min/week) and a common
/// step goal. These are general guides, not medical advice.
library;

import 'dart:math' as math;

class DailyTargets {
  final int waterMl;
  final int calories;
  final int exerciseMin;
  final int steps;
  final double sleepMin, sleepMax;
  final int fruitVeg;

  /// Why the calorie target is what it is, e.g. "includes a small deficit".
  final String caloriesNote;

  const DailyTargets({
    required this.waterMl,
    required this.calories,
    required this.exerciseMin,
    required this.steps,
    required this.sleepMin,
    required this.sleepMax,
    required this.fruitVeg,
    required this.caloriesNote,
  });
}

/// Personal targets. Missing profile values fall back to typical adults.
DailyTargets targetsFor({
  String? gender,
  int? age,
  double? heightCm,
  double? weightKg,
}) {
  final male = gender != 'female';
  final a = (age ?? 35).toDouble();
  final h = heightCm ?? (male ? 168 : 155);
  final w = weightKg ?? (male ? 68 : 58);

  // Water: about 35 ml per kg, rounded to 100 ml, kept in a sensible range.
  final water = ((w * 35 / 100).round() * 100).clamp(2000, 3500);

  // Calories: BMR (Mifflin-St Jeor) × light activity, minus 500 kcal if the
  // BMI is above the Asian healthy limit (23) to support slow weight loss.
  final bmr = 10 * w + 6.25 * h - 5 * a + (male ? 5 : -161);
  var kcal = bmr * 1.375;
  final bmi = w / math.pow(h / 100, 2);
  var note = 'To keep your current weight';
  if (bmi >= 23) {
    kcal -= 500;
    note = 'Includes a small deficit to lose about 0.5 kg a week';
  }
  final minKcal = male ? 1500 : 1200;
  final calories = ((math.max(kcal, minKcal) / 50).round() * 50);

  return DailyTargets(
    waterMl: water,
    calories: calories,
    exerciseMin: 30,
    steps: a >= 60 ? 6000 : 8000,
    sleepMin: 7,
    sleepMax: 9,
    fruitVeg: 5,
    caloriesNote: note,
  );
}

/// One day's log. Null fields were skipped and are not scored.
class DailyLog {
  final int? waterMl;
  final int? calories;
  final int? exerciseMin;
  final int? steps;
  final double? sleepHours;
  final int? fruitVeg;
  final int? sugaryItems;

  /// Foods picked in the meal picker ({food id: portions}); optional.
  final Map<String, int>? meals;

  const DailyLog({
    this.waterMl,
    this.calories,
    this.exerciseMin,
    this.steps,
    this.sleepHours,
    this.fruitVeg,
    this.sugaryItems,
    this.meals,
  });

  bool get isEmpty =>
      waterMl == null &&
      calories == null &&
      exerciseMin == null &&
      steps == null &&
      sleepHours == null &&
      fruitVeg == null &&
      sugaryItems == null;

  factory DailyLog.fromMap(Map<String, dynamic> m) => DailyLog(
    waterMl: m['water_ml'] as int?,
    calories: m['calories'] as int?,
    exerciseMin: m['exercise_min'] as int?,
    steps: m['steps'] as int?,
    sleepHours: (m['sleep_hours'] as num?)?.toDouble(),
    fruitVeg: m['fruit_veg'] as int?,
    sugaryItems: m['sugary_items'] as int?,
    meals: m['meals'] == null
        ? null
        : (m['meals'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toInt()),
          ),
  );

  Map<String, dynamic> toMap() => {
    'water_ml': waterMl,
    'calories': calories,
    'exercise_min': exerciseMin,
    'steps': steps,
    'sleep_hours': sleepHours,
    'fruit_veg': fruitVeg,
    'sugary_items': sugaryItems,
    // Only sent when used, so saving still works before migration 5.
    if (meals != null && meals!.isNotEmpty) 'meals': meals,
  };
}

/// How well one item met its target, from 0 to 1.
class ItemScore {
  final String key;
  final double value;

  const ItemScore(this.key, this.value);
}

/// Scores a day's log out of 100. Only filled-in items count, so skipping
/// one (e.g. calories you didn't track) doesn't pull the score down.
({int score, List<ItemScore> items}) scoreDay(DailyLog log, DailyTargets t) {
  double upTo(num v, num target) => (v / target).clamp(0, 1).toDouble();

  final items = <ItemScore>[
    if (log.waterMl != null) ItemScore('water', upTo(log.waterMl!, t.waterMl)),
    if (log.calories != null)
      ItemScore('calories', () {
        // Full marks within ±10% of target, falling to 0 at ±40%.
        final off = (log.calories! - t.calories).abs() / t.calories;
        return (1 - ((off - 0.10) / 0.30)).clamp(0, 1).toDouble();
      }()),
    if (log.exerciseMin != null)
      ItemScore('exercise', upTo(log.exerciseMin!, t.exerciseMin)),
    if (log.steps != null) ItemScore('steps', upTo(log.steps!, t.steps)),
    if (log.sleepHours != null)
      ItemScore('sleep', () {
        final s = log.sleepHours!;
        if (s >= t.sleepMin && s <= t.sleepMax) return 1.0;
        final off = s < t.sleepMin ? t.sleepMin - s : s - t.sleepMax;
        return (1 - off / 3).clamp(0, 1).toDouble();
      }()),
    if (log.fruitVeg != null)
      ItemScore('fruitVeg', upTo(log.fruitVeg!, t.fruitVeg)),
    if (log.sugaryItems != null)
      ItemScore('sugar', switch (log.sugaryItems!) {
        0 => 1.0,
        1 => 0.6,
        2 => 0.3,
        _ => 0.0,
      }),
  ];
  if (items.isEmpty) return (score: 0, items: items);
  final avg = items.fold<double>(0, (s, i) => s + i.value) / items.length;
  return (score: (avg * 100).round(), items: items);
}

/// Coins for the day's log: +10 for logging, +20 more at 90 or above.
const int coinsForCheckin = 1;
const int coinsForLog = 10;
const int coinsForBonus = 20;
const int bonusScore = 90;
