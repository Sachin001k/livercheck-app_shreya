import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../fib4.dart';
import '../translations.dart';

/// A row of the `profiles` table (see supabase/migrations/).
class Profile {
  final String id;
  final String? fullName;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final AppLanguage preferredLanguage;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.preferredLanguage,
    required this.createdAt,
  });

  /// Name and age are required before the user can reach the home page.
  bool get isComplete => (fullName?.trim().isNotEmpty ?? false) && age != null;

  double? get bmi {
    final h = heightCm, w = weightKg;
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    return calculateBmi(heightCm: h, weightKg: w);
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      preferredLanguage: AppLanguage.values.firstWhere(
        (l) => l.name == map['preferred_language'],
        orElse: () => AppLanguage.en,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// A row of the `assessments` table: one saved FIB-4 check.
class Assessment {
  final String id;
  final double score;
  final RiskTier tier;
  final DateTime createdAt;

  const Assessment({
    required this.id,
    required this.score,
    required this.tier,
    required this.createdAt,
  });

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] as String,
      score: (map['fib4_score'] as num).toDouble(),
      tier: RiskTier.values.byName(map['risk_tier'] as String),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}

/// All reads and writes of the user's own data. Row Level Security in
/// Supabase guarantees a user can only touch their own rows.
class DataService {
  DataService._();

  static SupabaseClient get _db => Supabase.instance.client;
  static String? get _userId => _db.auth.currentUser?.id;

  /// Bumped after every write, so screens showing saved data can reload.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<Profile?> fetchProfile() async {
    final id = _userId;
    if (id == null) return null;
    final row = await _db.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  static Future<void> saveProfile({
    required String fullName,
    required int age,
    String? gender,
    double? heightCm,
    double? weightKg,
    required AppLanguage language,
  }) async {
    final id = _userId;
    if (id == null) return;
    await _db.from('profiles').upsert({
      'id': id,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'preferred_language': language.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    changes.value++;
  }

  /// Updates only the body measurements that are given (from the health
  /// check), leaving name, gender and language untouched.
  static Future<void> updateBodyStats({
    int? age,
    double? heightCm,
    double? weightKg,
  }) async {
    final id = _userId;
    if (id == null) return;
    final fields = <String, dynamic>{
      'age': ?age,
      'height_cm': ?heightCm,
      'weight_kg': ?weightKg,
    };
    if (fields.isEmpty) return;
    fields['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await _db.from('profiles').update(fields).eq('id', id);
  }

  /// Best effort: a failed language save shouldn't interrupt the user.
  static Future<void> saveLanguage(AppLanguage language) async {
    final id = _userId;
    if (id == null) return;
    try {
      await _db
          .from('profiles')
          .update({'preferred_language': language.name}).eq('id', id);
    } catch (e) {
      debugPrint('Could not save language: $e');
    }
  }

  static Future<void> saveAssessment({
    required double age,
    required double ast,
    required double alt,
    required double platelets,
    required Fib4Result result,
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? hasDiabetes,
    String? familyHistory,
  }) async {
    await _db.from('assessments').insert({
      'age': age,
      'ast': ast,
      'alt': alt,
      'platelets': platelets,
      'fib4_score': result.score,
      'risk_tier': result.tier.name,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'has_diabetes': hasDiabetes,
      'family_history': familyHistory,
    });
    changes.value++;
  }

  static Future<List<Assessment>> fetchAssessments({int limit = 100}) async {
    final rows = await _db
        .from('assessments')
        .select('id, fib4_score, risk_tier, created_at')
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(Assessment.fromMap).toList();
  }

  /// Marks today (in the user's local time zone) as an active day.
  static Future<void> logActivityToday() async {
    final id = _userId;
    if (id == null) return;
    await _db.from('daily_activity').upsert(
      {'user_id': id, 'activity_date': _dateOnly(DateTime.now())},
      onConflict: 'user_id,activity_date',
      ignoreDuplicates: true,
    );
  }

  static Future<List<DateTime>> fetchActivityDays({int days = 365}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await _db
        .from('daily_activity')
        .select('activity_date')
        .gte('activity_date', _dateOnly(since));
    return rows
        .map((r) => DateTime.parse(r['activity_date'] as String))
        .toList();
  }

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
