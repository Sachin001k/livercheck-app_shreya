/// The items in the daily check-in log, shared by every screen that shows it.
library;

import '../translations.dart';
import 'daily_targets.dart';

/// Text for [key] in [lang] with `{name}` placeholders filled from [args].
String trf(AppLanguage lang, String key, [Map<String, Object?> args = const {}]) {
  var text = tr(lang, key);
  args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
  return text;
}

class DailyItem {
  /// Item id (stable; used in saved data and scoring).
  final String key;
  final String emoji;

  /// Translation keys (see `lib/translations/en.dart`).
  final String titleKey, unitKey, goalKey;
  final String? hintKey;
  final double min, max, step;

  /// Size of one tap on the − / + buttons.
  final double tapStep;

  /// Values for the `{placeholders}` in [goalKey].
  final Map<String, Object> Function(DailyTargets t) goalArgs;

  /// Target the progress bar fills towards (null = lower is better).
  final double? Function(DailyTargets t) goal;

  const DailyItem({
    required this.key,
    required this.emoji,
    required this.titleKey,
    required this.unitKey,
    required this.min,
    required this.max,
    required this.step,
    required this.tapStep,
    required this.goalKey,
    required this.goalArgs,
    required this.goal,
    this.hintKey,
  });

  String title(AppLanguage lang) => tr(lang, titleKey);
  String unit(AppLanguage lang) => tr(lang, unitKey);
  String? hint(AppLanguage lang) => hintKey == null ? null : tr(lang, hintKey!);
  String goalText(AppLanguage lang, DailyTargets t) =>
      trf(lang, goalKey, goalArgs(t));

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
    titleKey: 'dl_water',
    unitKey: 'dl_unitLitre',
    min: 0,
    max: 5,
    step: 0.25,
    tapStep: 0.25,
    goalKey: 'dl_goalWater',
    goalArgs: (t) => {'n': (t.waterMl / 1000).toStringAsFixed(1)},
    goal: (t) => t.waterMl / 1000,
    hintKey: 'dl_hintWater',
  ),
  DailyItem(
    key: 'calories',
    emoji: '🍽️',
    titleKey: 'dl_foodEaten',
    unitKey: 'dl_unitKcal',
    min: 0,
    max: 4000,
    step: 50,
    tapStep: 100,
    goalKey: 'dl_goalCalories',
    goalArgs: (t) => {'n': t.calories},
    goal: (t) => t.calories.toDouble(),
    hintKey: 'dl_hintCalories',
  ),
  DailyItem(
    key: 'exercise',
    emoji: '🏃',
    titleKey: 'dl_exercise',
    unitKey: 'dl_unitMin',
    min: 0,
    max: 120,
    step: 5,
    tapStep: 5,
    goalKey: 'dl_goalExercise',
    goalArgs: (t) => {'n': t.exerciseMin},
    goal: (t) => t.exerciseMin.toDouble(),
    hintKey: 'dl_hintExercise',
  ),
  DailyItem(
    key: 'steps',
    emoji: '👣',
    titleKey: 'dl_steps',
    unitKey: 'dl_unitSteps',
    min: 0,
    max: 20000,
    step: 500,
    tapStep: 500,
    goalKey: 'dl_goalSteps',
    goalArgs: (t) => {'n': t.steps},
    goal: (t) => t.steps.toDouble(),
    hintKey: 'dl_hintSteps',
  ),
  DailyItem(
    key: 'sleep',
    emoji: '😴',
    titleKey: 'dl_sleep',
    unitKey: 'dl_unitHours',
    min: 3,
    max: 12,
    step: 0.5,
    tapStep: 0.5,
    goalKey: 'dl_goalSleep',
    goalArgs: (t) => {'min': t.sleepMin.round(), 'max': t.sleepMax.round()},
    goal: (t) => t.sleepMin,
  ),
  DailyItem(
    key: 'fruitVeg',
    emoji: '🥗',
    titleKey: 'dl_fruitVeg',
    unitKey: 'dl_unitServings',
    min: 0,
    max: 10,
    step: 1,
    tapStep: 1,
    goalKey: 'dl_goalFruitVeg',
    goalArgs: (t) => {'n': t.fruitVeg},
    goal: (t) => t.fruitVeg.toDouble(),
    hintKey: 'dl_hintFruitVeg',
  ),
  DailyItem(
    key: 'sugar',
    emoji: '🍬',
    titleKey: 'dl_sweets',
    unitKey: 'dl_unitItems',
    min: 0,
    max: 6,
    step: 1,
    tapStep: 1,
    goalKey: 'dl_goalSweets',
    goalArgs: (_) => const {},
    goal: (_) => null,
    hintKey: 'dl_hintSweets',
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
