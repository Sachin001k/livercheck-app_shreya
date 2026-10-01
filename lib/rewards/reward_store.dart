import 'package:supabase_flutter/supabase_flutter.dart';

import '../daily/daily_targets.dart';
import '../services/data_service.dart';

/// One way to earn coins (table `reward_rules`).
class RewardRule {
  final String reason;
  final int amount;
  final String description;

  const RewardRule(this.reason, this.amount, this.description);
}

/// One coin reward the user received (table `coin_events`).
class CoinEvent {
  final String reason;
  final int amount;
  final DateTime createdAt;

  /// The special survey it came from, if any.
  final String? refId;

  const CoinEvent(this.reason, this.amount, this.createdAt, this.refId);
}

/// One question in a special survey. Stored as JSON in
/// `special_surveys.questions`; see CLAUDE.md for the format.
class SurveyQuestion {
  final String id;

  /// 'choice', 'multi', 'scale' (1–5) or 'text'.
  final String type;
  final String title;
  final List<({String v, String label, String emoji})> options;

  const SurveyQuestion(this.id, this.type, this.title, this.options);

  factory SurveyQuestion.fromJson(Map<String, dynamic> j) => SurveyQuestion(
    j['id'] as String,
    j['type'] as String? ?? 'choice',
    j['title'] as String,
    [
      for (final o in (j['options'] as List? ?? const []))
        (
          v: (o as Map)['v'] as String,
          label: o['label'] as String,
          emoji: o['emoji'] as String? ?? '',
        ),
    ],
  );
}

/// An announced survey with its own coin reward (table `special_surveys`).
class SpecialSurvey {
  final String id;
  final String title;
  final String? description;
  final List<SurveyQuestion> questions;
  final int rewardCoins;
  final DateTime? endsAt;
  final bool completed;

  const SpecialSurvey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.rewardCoins,
    required this.endsAt,
    required this.completed,
  });
}

class RewardsData {
  final List<RewardRule> rules;

  /// Newest first.
  final List<CoinEvent> events;
  final List<SpecialSurvey> surveys;

  const RewardsData(this.rules, this.events, this.surveys);

  int get totalCoins => events.fold(0, (s, e) => s + e.amount);
  int get specialSurveysDone => surveys.where((s) => s.completed).length;
  List<SpecialSurvey> get openSurveys =>
      surveys.where((s) => !s.completed).toList();
}

/// Fallback rules shown if `reward_rules` can't be read.
const defaultRules = [
  RewardRule(
    'checkin',
    coinsForCheckin,
    'Tapped Check in on the Home page (once a day)',
  ),
  RewardRule(
    'daily_log',
    coinsForLog,
    'Filled in the daily health log (once a day)',
  ),
  RewardRule(
    'daily_bonus',
    coinsForBonus,
    'Daily log scored 90 or more (once a day)',
  ),
  RewardRule('special_survey', 0, 'Completed a special survey'),
];

/// Friendly name and emoji for each coin source.
const reasonLabels = {
  'checkin': ('👋', 'Daily check-in'),
  'daily_log': ('📝', 'Daily log'),
  'daily_bonus': ('🎯', '90+ day bonus'),
  'special_survey': ('📣', 'Special survey'),
};

class RewardStore {
  RewardStore._();

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<RewardsData> load() async {
    final results = await Future.wait([
      _db
          .from('reward_rules')
          .select('reason, amount, description')
          .eq('active', true),
      _db
          .from('coin_events')
          .select('reason, amount, created_at, ref_id')
          .order('created_at', ascending: false)
          .limit(200),
      // RLS only returns surveys that are live right now.
      _db.from('special_surveys').select().order('starts_at', ascending: false),
      _db.from('special_survey_responses').select('survey_id'),
    ]);

    final rules = [
      for (final r in results[0])
        RewardRule(
          r['reason'] as String,
          (r['amount'] as num).toInt(),
          r['description'] as String,
        ),
    ];
    final events = [
      for (final r in results[1])
        CoinEvent(
          r['reason'] as String,
          (r['amount'] as num).toInt(),
          DateTime.parse(r['created_at'] as String).toLocal(),
          r['ref_id'] as String?,
        ),
    ];
    final answered = {for (final r in results[3]) r['survey_id'] as String};
    final surveys = [
      for (final r in results[2])
        SpecialSurvey(
          id: r['id'] as String,
          title: r['title'] as String,
          description: r['description'] as String?,
          questions: [
            for (final q in (r['questions'] as List? ?? const []))
              SurveyQuestion.fromJson(Map<String, dynamic>.from(q as Map)),
          ],
          rewardCoins: (r['reward_coins'] as num).toInt(),
          endsAt: r['ends_at'] == null
              ? null
              : DateTime.parse(r['ends_at'] as String).toLocal(),
          completed: answered.contains(r['id']),
        ),
    ];
    return RewardsData(rules.isEmpty ? defaultRules : rules, events, surveys);
  }

  /// Live surveys the user hasn't answered yet (for the Home banner).
  static Future<List<SpecialSurvey>> openSurveys() async {
    final data = await load();
    return data.openSurveys;
  }

  /// Saves the answers, then claims the survey's coins (the server checks
  /// the survey is open and answered, and sets the amount).
  static Future<int> submitSpecialSurvey(
    SpecialSurvey survey,
    Map<String, dynamic> answers,
  ) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Not signed in');
    await _db.from('special_survey_responses').insert({
      'survey_id': survey.id,
      'user_id': uid,
      'answers': answers,
    });
    await _db.from('coin_events').insert({
      'user_id': uid,
      'reason': 'special_survey',
      'ref_id': survey.id,
      'amount': 0, // replaced by the server with the survey's reward
    });
    DataService.changes.value++;
    return survey.rewardCoins;
  }
}
