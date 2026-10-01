import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/data_service.dart';
import 'assess.dart';

// Health check history, stored per user in Supabase (table
// survey_responses — see supabase/migrations/). Daily check-ins and coins
// live in lib/daily/daily_store.dart.

class ScoreEntry {
  final String id;
  final DateTime date;
  final int score;
  final String tier;

  /// Full result, so a past check can be reopened. Null for rows saved
  /// before results were stored.
  final AssessmentResult? result;

  ScoreEntry(this.id, this.date, this.score, this.tier, this.result);
}

class ProgressData {
  /// Oldest first.
  final List<ScoreEntry> history;
  ProgressData(this.history);

  AssessmentResult? get last => history.isEmpty ? null : history.last.result;
}

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ProgressStore {
  ProgressStore._();

  static SupabaseClient get _db => Supabase.instance.client;

  /// Shared with [DataService] so every screen reloads after any save.
  static ValueNotifier<int> get changes => DataService.changes;

  static Future<ProgressData> load() async {
    final rows = await _db
        .from('survey_responses')
        .select('id, score, tier, result, created_at')
        .order('created_at')
        .limit(500);

    final history = <ScoreEntry>[];
    for (final row in rows) {
      AssessmentResult? result;
      try {
        final json = row['result'];
        if (json != null) {
          result = AssessmentResult.fromJson(Map<String, dynamic>.from(json as Map));
        }
      } catch (e) {
        debugPrint('Could not read saved result ${row['id']}: $e');
      }
      history.add(ScoreEntry(
        row['id'] as String,
        DateTime.parse(row['created_at'] as String).toLocal(),
        (row['score'] as num?)?.toInt() ?? 0,
        row['tier'] as String? ?? '',
        result,
      ));
    }

    return ProgressData(history);
  }

  /// Saves a finished health check. Also records the FIB-4 score (when
  /// blood values were entered) and updates age/height/weight on the profile.
  static Future<void> saveResult(AssessmentResult r, Map<String, dynamic> answers) async {
    await _db.from('survey_responses').insert({
      'survey_version': 'v1',
      'answers': answers,
      'score': r.score,
      'tier': r.tier,
      'result': r.toJson(),
    });

    final labs = answers['labs'] as Map?;
    final fib4 = r.fib4;
    if (fib4 != null && labs != null) {
      final age = (answers['age'] as num).toDouble();
      final lowCut = age >= 65 ? 2.0 : 1.3;
      await _db.from('assessments').insert({
        'age': age,
        'ast': labs['ast'],
        'alt': labs['alt'],
        'platelets': plateletsToG(
            (labs['plt'] as num).toDouble(), labs['unit'] as String? ?? 'lakh'),
        'fib4_score': fib4,
        'risk_tier': fib4 > 2.67 ? 'high' : fib4 >= lowCut ? 'intermediate' : 'low',
        'height_cm': answers['height'],
        'weight_kg': answers['weight'],
        'bmi': r.bmi,
      });
    }

    await DataService.updateBodyStats(
      age: (answers['age'] as num?)?.round(),
      heightCm: (answers['height'] as num?)?.toDouble(),
      weightKg: (answers['weight'] as num?)?.toDouble(),
    );
    changes.value++;
  }
}
