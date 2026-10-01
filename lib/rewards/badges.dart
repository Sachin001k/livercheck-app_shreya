/// Achievement badges. Shown on the Rewards tab.
library;

class Achievement {
  final String emoji;
  final String label;

  /// How to earn it, shown while locked.
  final String hint;
  final bool unlocked;

  const Achievement(this.emoji, this.label, this.hint, this.unlocked);
}

List<Achievement> computeBadges({
  required int healthChecks,
  required bool scoreImproved,
  required int longestStreak,
  required int bestDayScore,
  required int coins,
  required bool bloodReportAdded,
  required int specialSurveysDone,
}) => [
  Achievement(
    '🩺',
    'First check',
    'Take your first health check',
    healthChecks >= 1,
  ),
  Achievement(
    '📈',
    'Improved score',
    'Beat your first health check score',
    scoreImproved,
  ),
  Achievement(
    '🔥',
    '3-day streak',
    'Check in 3 days in a row',
    longestStreak >= 3,
  ),
  Achievement(
    '🏆',
    '7-day streak',
    'Check in 7 days in a row',
    longestStreak >= 7,
  ),
  Achievement(
    '💎',
    '30-day streak',
    'Check in 30 days in a row',
    longestStreak >= 30,
  ),
  Achievement(
    '🎯',
    '90+ day',
    'Score 90 or more in a daily log',
    bestDayScore >= 90,
  ),
  Achievement('🪙', '100 coins', 'Collect 100 coins', coins >= 100),
  Achievement('💰', '500 coins', 'Collect 500 coins', coins >= 500),
  Achievement(
    '🧪',
    'Blood report',
    'Add blood test values in a health check',
    bloodReportAdded,
  ),
  Achievement(
    '📣',
    'Survey star',
    'Complete a special survey',
    specialSurveysDone >= 1,
  ),
];
