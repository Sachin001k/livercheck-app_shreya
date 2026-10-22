/// Achievement badges. Shown on the Rewards tab.
library;

class Achievement {
  /// Stable id (never shown; safe to use in tests and storage).
  final String id;
  final String emoji;

  /// Translation key of the badge name (show with `context.t`).
  final String labelKey;

  /// Translation key of how to earn it, shown while locked.
  final String hintKey;
  final bool unlocked;

  const Achievement(
    this.id,
    this.emoji,
    this.labelKey,
    this.hintKey,
    this.unlocked,
  );
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
    'first_check',
    '🩺',
    'rw_badgeFirstCheck',
    'rw_badgeFirstCheckHint',
    healthChecks >= 1,
  ),
  Achievement(
    'improved',
    '📈',
    'rw_badgeImproved',
    'rw_badgeImprovedHint',
    scoreImproved,
  ),
  Achievement(
    'streak3',
    '🔥',
    'rw_badgeStreak3',
    'rw_badgeStreak3Hint',
    longestStreak >= 3,
  ),
  Achievement(
    'streak7',
    '🏆',
    'rw_badgeStreak7',
    'rw_badgeStreak7Hint',
    longestStreak >= 7,
  ),
  Achievement(
    'streak30',
    '💎',
    'rw_badgeStreak30',
    'rw_badgeStreak30Hint',
    longestStreak >= 30,
  ),
  Achievement(
    'day90',
    '🎯',
    'rw_badgeDay90',
    'rw_badgeDay90Hint',
    bestDayScore >= 90,
  ),
  Achievement(
    'coins100',
    '🪙',
    'rw_badgeCoins100',
    'rw_badgeCoins100Hint',
    coins >= 100,
  ),
  Achievement(
    'coins500',
    '💰',
    'rw_badgeCoins500',
    'rw_badgeCoins500Hint',
    coins >= 500,
  ),
  Achievement(
    'blood_report',
    '🧪',
    'rw_badgeBloodReport',
    'rw_badgeBloodReportHint',
    bloodReportAdded,
  ),
  Achievement(
    'survey_star',
    '📣',
    'rw_badgeSurveyStar',
    'rw_badgeSurveyStarHint',
    specialSurveysDone >= 1,
  ),
];
