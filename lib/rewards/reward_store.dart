import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../daily/daily_store.dart';
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

  /// Throws [FormatException] if the id or title is missing. Option
  /// values are read as text, so `{"v": 1}` works like `{"v": "1"}`.
  factory SurveyQuestion.fromJson(Map<String, dynamic> j) {
    final id = j['id'], title = j['title'];
    if (id == null || title == null) {
      throw FormatException('Survey question needs an id and a title', j);
    }
    return SurveyQuestion('$id', '${j['type'] ?? 'choice'}', '$title', [
      for (final o in (j['options'] as List? ?? const []))
        (
          v: '${(o as Map)['v']}',
          label: '${o['label'] ?? o['v']}',
          emoji: '${o['emoji'] ?? ''}',
        ),
    ]);
  }
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

  /// All coins ever earned (from the `coin_balances` view, so it isn't cut
  /// short like [events]).
  final int totalCoins;

  /// Special surveys answered, including ones that have since closed.
  final int specialSurveysDone;

  const RewardsData(
    this.rules,
    this.events,
    this.surveys, {
    required this.totalCoins,
    required this.specialSurveysDone,
  });

  List<SpecialSurvey> get openSurveys =>
      surveys.where((s) => !s.completed).toList();
}

/// Fallback rules shown if `reward_rules` can't be read. The description
/// here is English; the screen shows [ruleDescriptionKeys] instead when
/// the reason is known.
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

/// Emoji and translation key of the name of each coin source. The reason
/// codes are stored in the database, so they never change.
const reasonLabels = {
  'checkin': ('👋', 'rw_reasonCheckin'),
  'daily_log': ('📝', 'rw_reasonDailyLog'),
  'daily_bonus': ('🎯', 'rw_reasonDailyBonus'),
  'special_survey': ('📣', 'rw_reasonSpecialSurvey'),
};

/// Translation keys of the "how to earn" text for each known reason
/// (used instead of the English `reward_rules.description`).
const ruleDescriptionKeys = {
  'checkin': 'rw_ruleCheckin',
  'daily_log': 'rw_ruleDailyLog',
  'daily_bonus': 'rw_ruleDailyBonus',
  'special_survey': 'rw_ruleSpecialSurvey',
};

class RewardStore {
  RewardStore._();

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<RewardsData> load() async {
    final results = await Future.wait<dynamic>([
      _db
          .from('reward_rules')
          .select('reason, amount, description')
          .eq('active', true),
      // History list only; the total comes from coin_balances.
      _db
          .from('coin_events')
          .select('reason, amount, created_at, ref_id')
          .order('created_at', ascending: false)
          .limit(200),
      // RLS returns surveys that are live right now, plus (migration
      // 20261024120000) ones this user has answered.
      _db.from('special_surveys').select().order('starts_at', ascending: false),
      _db.from('special_survey_responses').select('survey_id'),
      DailyStore.fetchCoinTotal(),
    ]);

    final rules = [
      for (final r in results[0] as List)
        RewardRule(
          r['reason'] as String,
          (r['amount'] as num).toInt(),
          r['description'] as String,
        ),
    ];
    final events = [
      for (final r in results[1] as List)
        CoinEvent(
          r['reason'] as String,
          (r['amount'] as num).toInt(),
          DateTime.parse(r['created_at'] as String).toLocal(),
          r['ref_id'] as String?,
        ),
    ];
    final answered = {
      for (final r in results[3] as List) '${r['survey_id']}',
    };
    final surveys = parseSpecialSurveys(
      List<Map<String, dynamic>>.from(results[2] as List),
      answered,
    );
    return RewardsData(
      rules.isEmpty ? defaultRules : rules,
      events,
      surveys,
      totalCoins: results[4] as int,
      specialSurveysDone: answered.length,
    );
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
    // Both steps are safe to repeat: if the coin step failed last time, a
    // retry skips the saved answers and claims the coins.
    await _db
        .from('special_survey_responses')
        .upsert(
          {'survey_id': survey.id, 'user_id': uid, 'answers': answers},
          onConflict: 'survey_id,user_id',
          ignoreDuplicates: true,
        );
    try {
      await _db.from('coin_events').insert({
        'user_id': uid,
        'reason': 'special_survey',
        'ref_id': survey.id,
        'amount': 0, // replaced by the server with the survey's reward
      });
    } on PostgrestException catch (e) {
      // Unique violation: the coins were already paid. (The once-per-survey
      // index is partial, so ON CONFLICT can't target it — catch instead.)
      if (e.code != '23505') rethrow;
    }
    DataService.changes.value++;
    return survey.rewardCoins;
  }
}

/// Builds [SpecialSurvey]s from `special_surveys` rows. A malformed row
/// is skipped (and logged) so one bad survey can't break the Rewards tab
/// or the Home banner.
List<SpecialSurvey> parseSpecialSurveys(
  List<Map<String, dynamic>> rows,
  Set<String> answered,
) {
  final surveys = <SpecialSurvey>[];
  for (final r in rows) {
    try {
      final id = '${r['id']}';
      final title = r['title'];
      if (r['id'] == null || title == null) {
        throw const FormatException('Survey needs an id and a title');
      }
      surveys.add(
        SpecialSurvey(
          id: id,
          title: '$title',
          description: r['description'] == null ? null : '${r['description']}',
          questions: [
            for (final q in (r['questions'] as List? ?? const []))
              SurveyQuestion.fromJson(Map<String, dynamic>.from(q as Map)),
          ],
          rewardCoins: (r['reward_coins'] as num? ?? 0).toInt(),
          endsAt: r['ends_at'] == null
              ? null
              : DateTime.parse('${r['ends_at']}').toLocal(),
          completed: answered.contains(id),
        ),
      );
    } catch (e) {
      debugPrint('Skipping malformed special survey ${r['id']}: $e');
    }
  }
  return surveys;
}
