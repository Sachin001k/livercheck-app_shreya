/// The items in the daily check-in log, shared by every screen that shows it.
library;

import 'daily_targets.dart';

class DailyItem {
  final String key, emoji, title, unit;
  final double min, max, step;

  /// Size of one tap on the − / + buttons.
  final double tapStep;
  final String Function(DailyTargets t) goalText;

  /// Target the progress bar fills towards (null = lower is better).
  final double? Function(DailyTargets t) goal;
  final String? hint;

  const DailyItem({
    required this.key,
    required this.emoji,
    required this.title,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.tapStep,
    required this.goalText,
    required this.goal,
    this.hint,
  });

  String format(double v) => step < 1
      ? v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')
      : v.round().toString();

  /// Starting value when the user first touches this item.
  double startValue(DailyTargets t) => switch (key) {
    'water' => 1.5,
    'calories' => t.calories.toDouble(),
    'steps' => 3000,
    'sleep' => 7,
    'fruitVeg' => 2,
    _ => 0,
  };
}

final List<DailyItem> dailyItems = [
  DailyItem(
    key: 'water',
    emoji: '💧',
    title: 'Water',
    unit: 'L',
    min: 0,
    max: 5,
    step: 0.25,
    tapStep: 0.25,
    goalText: (t) => 'Goal ${(t.waterMl / 1000).toStringAsFixed(1)} L',
    goal: (t) => t.waterMl / 1000,
    hint: '1 glass ≈ 250 ml · 1 bottle ≈ 1 L',
  ),
  DailyItem(
    key: 'calories',
    emoji: '🍽️',
    title: 'Food eaten',
    unit: 'kcal',
    min: 0,
    max: 4000,
    step: 50,
    tapStep: 100,
    goalText: (t) => 'Goal about ${t.calories} kcal',
    goal: (t) => t.calories.toDouble(),
    hint: 'Thali ≈ 700 · roti ≈ 100 · samosa ≈ 250',
  ),
  DailyItem(
    key: 'exercise',
    emoji: '🏃',
    title: 'Exercise',
    unit: 'min',
    min: 0,
    max: 120,
    step: 5,
    tapStep: 5,
    goalText: (t) => 'Goal ${t.exerciseMin} min',
    goal: (t) => t.exerciseMin.toDouble(),
    hint: 'Brisk walk, yoga, cycling, sports, gym',
  ),
  DailyItem(
    key: 'steps',
    emoji: '👣',
    title: 'Steps',
    unit: 'steps',
    min: 0,
    max: 20000,
    step: 500,
    tapStep: 500,
    goalText: (t) => 'Goal ${t.steps} steps',
    goal: (t) => t.steps.toDouble(),
    hint: "See your phone's health app",
  ),
  DailyItem(
    key: 'sleep',
    emoji: '😴',
    title: 'Sleep',
    unit: 'hours',
    min: 3,
    max: 12,
    step: 0.5,
    tapStep: 0.5,
    goalText: (t) => 'Goal ${t.sleepMin.round()}–${t.sleepMax.round()} hours',
    goal: (t) => t.sleepMin,
  ),
  DailyItem(
    key: 'fruitVeg',
    emoji: '🥗',
    title: 'Fruit & veg',
    unit: 'servings',
    min: 0,
    max: 10,
    step: 1,
    tapStep: 1,
    goalText: (t) => 'Goal ${t.fruitVeg} servings',
    goal: (t) => t.fruitVeg.toDouble(),
    hint: '1 katori sabzi, 1 fruit or 1 bowl salad',
  ),
  DailyItem(
    key: 'sugar',
    emoji: '🍬',
    title: 'Sweets & sugary drinks',
    unit: 'items',
    min: 0,
    max: 6,
    step: 1,
    tapStep: 1,
    goalText: (_) => 'Goal 0',
    goal: (_) => null,
    hint: 'Mithai, cold drinks, sweet chai',
  ),
];

/// Item values keyed by [DailyItem.key]; null = skipped.
Map<String, double?> valuesFromLog(DailyLog? log) => {
  'water': log?.waterMl == null ? null : log!.waterMl! / 1000,
  'calories': log?.calories?.toDouble(),
  'exercise': log?.exerciseMin?.toDouble(),
  'steps': log?.steps?.toDouble(),
  'sleep': log?.sleepHours,
  'fruitVeg': log?.fruitVeg?.toDouble(),
  'sugar': log?.sugaryItems?.toDouble(),
};

DailyLog logFromValues(Map<String, double?> v, {Map<String, int>? meals}) =>
    DailyLog(
      waterMl: v['water'] == null ? null : (v['water']! * 1000).round(),
      calories: v['calories']?.round(),
      exerciseMin: v['exercise']?.round(),
      steps: v['steps']?.round(),
      sleepHours: v['sleep'],
      fruitVeg: v['fruitVeg']?.round(),
      sugaryItems: v['sugar']?.round(),
      meals: meals,
    );
