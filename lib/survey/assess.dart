// ======================================================================
// SCORING LOGIC. Runs in the app for now. Move this to your backend
// (e.g. a Supabase Edge Function) later: the app sends the answers map
// and receives AssessmentResult.toJson() back.
// ======================================================================
import 'dart:math' as math;

class OrganResult {
  final String key, name, does, level, confidence;
  final List<String> reasons;
  final String? extra;
  OrganResult({
    required this.key,
    required this.name,
    required this.does,
    required this.level,
    required this.confidence,
    required this.reasons,
    this.extra,
  });
  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'does': does,
    'level': level,
    'confidence': confidence,
    'reasons': reasons,
    'extra': extra,
  };
  factory OrganResult.fromJson(Map<String, dynamic> j) => OrganResult(
    key: j['key'],
    name: j['name'],
    does: j['does'],
    level: j['level'],
    confidence: j['confidence'],
    reasons: List<String>.from(j['reasons']),
    extra: j['extra'],
  );
}

class PlanItem {
  final String emoji, title, sub;
  const PlanItem(this.emoji, this.title, this.sub);
  Map<String, dynamic> toJson() => {'e': emoji, 't': title, 's': sub};
  factory PlanItem.fromJson(Map<String, dynamic> j) =>
      PlanItem(j['e'], j['t'], j['s']);
}

class HealthPlan {
  final List<PlanItem> eatMore, eatLess, move, habits;
  HealthPlan(this.eatMore, this.eatLess, this.move, this.habits);
  List<PlanItem> byKey(String k) => k == 'eatMore'
      ? eatMore
      : k == 'eatLess'
      ? eatLess
      : k == 'move'
      ? move
      : habits;
  static List<Map<String, dynamic>> _l(List<PlanItem> x) =>
      x.map((e) => e.toJson()).toList();
  static List<PlanItem> _p(dynamic x) => (x as List)
      .map((e) => PlanItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  Map<String, dynamic> toJson() => {
    'eatMore': _l(eatMore),
    'eatLess': _l(eatLess),
    'move': _l(move),
    'habits': _l(habits),
  };
  factory HealthPlan.fromJson(Map<String, dynamic> j) => HealthPlan(
    _p(j['eatMore']),
    _p(j['eatLess']),
    _p(j['move']),
    _p(j['habits']),
  );
}

class AssessmentResult {
  final int score;
  final String tier;
  final double bmi;
  final bool waistEstimated;
  final Map<String, OrganResult> organs;
  final List<String> tests, notes;
  final bool seeDoctor;
  final HealthPlan plan;

  /// FIB-4 score when blood test values were entered, otherwise null.
  final double? fib4;
  AssessmentResult({
    required this.score,
    required this.tier,
    required this.bmi,
    required this.waistEstimated,
    required this.organs,
    required this.tests,
    required this.notes,
    required this.seeDoctor,
    required this.plan,
    this.fib4,
  });
  Map<String, dynamic> toJson() => {
    'score': score,
    'tier': tier,
    'bmi': bmi,
    'waistEstimated': waistEstimated,
    'organs': organs.map((k, v) => MapEntry(k, v.toJson())),
    'tests': tests,
    'notes': notes,
    'seeDoctor': seeDoctor,
    'plan': plan.toJson(),
    'fib4': fib4,
  };
  factory AssessmentResult.fromJson(Map<String, dynamic> j) => AssessmentResult(
    score: (j['score'] as num).toInt(),
    tier: j['tier'],
    bmi: (j['bmi'] as num).toDouble(),
    waistEstimated: j['waistEstimated'],
    organs: (j['organs'] as Map).map(
      (k, v) => MapEntry(
        k as String,
        OrganResult.fromJson(Map<String, dynamic>.from(v)),
      ),
    ),
    tests: List<String>.from(j['tests']),
    notes: List<String>.from(j['notes']),
    seeDoctor: j['seeDoctor'],
    plan: HealthPlan.fromJson(Map<String, dynamic>.from(j['plan'])),
    fib4: (j['fib4'] as num?)?.toDouble(),
  );
}

const _none = 'sv_reasonNone';

/// Builds a translatable text reference for saved results: a translation
/// key, plus `|name=value` for each `{name}` placeholder. Shown with
/// `trText()` in health_ui.dart. Older saved results hold plain English,
/// which `trText()` shows unchanged.
String textRef(String key, [Map<String, Object> args = const {}]) =>
    [key, for (final e in args.entries) '${e.key}=${e.value}'].join('|');

/// Converts a platelet count typed in [unit] ('lakh', 'ul' or 'g') to ×10⁹/L.
double plateletsToG(double raw, String unit) => unit == 'lakh'
    ? raw * 100
    : unit == 'ul'
    ? raw / 1000
    : raw;

AssessmentResult assess(Map<String, dynamic> a) {
  double n(String k, double d) => (a[k] as num?)?.toDouble() ?? d;
  final male = a['sex'] == 'm';
  final age = n('age', 30),
      height = n('height', 165),
      weight = n('weight', 65),
      sleep = n('sleep', 7);
  final waist = (a['waist'] as num?)?.toDouble();
  final activity = a['activity'] as String? ?? 'light';
  final sugar = a['sugar'] as String? ?? 'rarely';
  final fried = a['fried'] as String? ?? 'rarely';
  final smoke = a['smoke'] as String? ?? 'never';
  final alcohol = a['alcohol'] as String? ?? 'never';
  final cond = List<String>.from(a['conditions'] ?? const <String>[]);
  final fam = List<String>.from(a['family'] ?? const <String>[]);
  bool has(String c) => cond.contains(c);
  bool famHas(String c) => fam.contains(c);
  final diabetes = has('diabetes'), bp = has('bp'), chol = has('chol');
  final sedentary = activity == 'sit';
  final hM = height / 100;
  final bmi = weight / (hM * hM); // Asian cut-offs: 23 overweight, 25 obese
  final tests = <String>{};
  final notes = <String>[];
  final organs = <String, OrganResult>{};
  double? fib4Value;
  String lvl(int p, int m, int h) => p >= h
      ? 'high'
      : p >= m
      ? 'mod'
      : 'low';

  // Waist: real value, or estimated from BMI when unknown
  final waistEst = waist == null;
  int waistScore;
  bool waistHigh;
  if (waist != null) {
    waistHigh = male ? waist >= 90 : waist >= 80;
    waistScore = male
        ? (waist >= 100
              ? 20
              : waist >= 90
              ? 10
              : 0)
        : (waist >= 90
              ? 20
              : waist >= 80
              ? 10
              : 0);
  } else {
    waistScore = bmi >= 25
        ? 20
        : bmi >= 23
        ? 10
        : 0;
    waistHigh = bmi >= 25;
  }

  // ---- Pancreas / blood sugar: Indian Diabetes Risk Score
  {
    final r = <String>[];
    var idrs = age < 35
        ? 0
        : age < 50
        ? 20
        : 30;
    idrs +=
        const {'heavy': 0, 'regular': 10, 'light': 20, 'sit': 30}[activity] ??
        20;
    idrs += famHas('diabetes') ? 10 : 0;
    idrs += waistScore;
    var level = idrs >= 60
        ? 'high'
        : idrs >= 30
        ? 'mod'
        : 'low';
    if (diabetes) {
      level = 'high';
      r.add('sv_rPanHasDiabetes');
    }
    if (age >= 35) r.add('sv_rPanAge35');
    if (waistScore > 0) {
      r.add(waistEst ? 'sv_rPanWeightBelly' : 'sv_rPanWaistHigh');
    }
    if (sedentary || activity == 'light') r.add('sv_rPanLowActivity');
    if (famHas('diabetes')) r.add('sv_rPanFamilyDiabetes');
    if (sugar == 'daily') r.add('sv_rPanDailySugar');
    if (r.isEmpty) r.add(_none);
    if (level != 'low' || has('unsure')) tests.add('sv_testHba1c');
    organs['pancreas'] = OrganResult(
      key: 'pancreas',
      name: 'sv_organPancreas',
      does: 'sv_doesPancreas',
      level: level,
      reasons: r,
      confidence: 'sv_confPancreas',
      extra: textRef('sv_extraRiskScore', {'n': idrs}),
    );
  }

  // ---- Liver
  {
    final r = <String>[];
    var p = 0;
    if (bmi >= 25) {
      p += 2;
      r.add('sv_rLivBmi25');
    } else if (bmi >= 23) {
      p += 1;
      r.add('sv_rLivBmi23');
    }
    if (waistHigh) {
      p += 2;
      r.add('sv_rLivBelly');
    }
    if (diabetes) {
      p += 3;
      r.add('sv_rLivDiabetes');
    }
    if (bp) {
      p += 1;
      r.add('sv_rLivBp');
    }
    if (chol) {
      p += 1;
      r.add('sv_rLivChol');
    }
    if (sedentary) {
      p += 1;
      r.add('sv_rLivSitting');
    }
    if (sugar == 'daily') {
      p += 1;
      r.add('sv_rLivSugar');
    }
    if (fried == 'often') {
      p += 1;
      r.add('sv_rLivFried');
    }
    if (alcohol == 'weekly') {
      p += 2;
      r.add('sv_rLivAlcohol');
    }
    if (famHas('liver')) {
      p += 1;
      r.add('sv_rLivFamily');
    }
    if (has('pcos')) {
      p += 1;
      r.add('sv_rLivPcos');
    }
    if (has('thyroid')) {
      p += 1;
      r.add('sv_rLivThyroid');
    }

    var level = lvl(p, 3, 6);
    var conf = 'sv_confLiverLifestyle';
    String? extra;
    final labs = a['labs'] as Map?;
    final ast = (labs?['ast'] as num?)?.toDouble();
    final alt = (labs?['alt'] as num?)?.toDouble();
    final pltRaw = (labs?['plt'] as num?)?.toDouble();
    if (ast != null && alt != null && pltRaw != null && alt > 0 && pltRaw > 0) {
      final plt = plateletsToG(
        pltRaw,
        labs!['unit'] as String? ?? 'lakh',
      ); // → ×10⁹/L
      final fib4 = (age * ast) / (plt * math.sqrt(alt));
      fib4Value = double.parse(fib4.toStringAsFixed(2));
      final lowCut = age >= 65 ? 2.0 : 1.3;
      extra = textRef('sv_extraFib4', {'n': fib4.toStringAsFixed(2)});
      conf = 'sv_confLiverFib4';
      if (fib4 > 2.67) {
        level = 'high';
        r.insert(0, 'sv_rLivFib4High');
        tests.add('sv_testFibroscan');
      } else if (fib4 >= lowCut) {
        level = 'mod';
        r.insert(0, 'sv_rLivFib4Mid');
        tests.add('sv_testFibroscan');
      } else {
        r.insert(0, 'sv_rLivFib4Low');
        if (level == 'high') level = 'mod';
      }
      if (alt > 40) r.add('sv_rLivAltHigh');
      if (age < 35) {
        notes.add('sv_noteFib4Under35');
      }
    } else {
      tests.add('sv_testLft');
      tests.add('sv_testCbc');
      if (level == 'high') tests.add('sv_testUltrasound');
    }
    if (r.isEmpty) r.add(_none);
    organs['liver'] = OrganResult(
      key: 'liver',
      name: 'sv_organLiver',
      does: 'sv_doesLiver',
      level: level,
      reasons: r,
      confidence: conf,
      extra: extra,
    );
  }

  // ---- Heart
  {
    final r = <String>[];
    var p = 0;
    if ((male && age >= 45) || (!male && age >= 55)) {
      p += 2;
      r.add('sv_rHeartAge');
    }
    if (age >= 65) p += 1;
    if (smoke == 'current') {
      p += 3;
      r.add('sv_rHeartSmoke');
    } else if (smoke == 'past') {
      p += 1;
      r.add('sv_rHeartPastSmoke');
    }
    if (bp) {
      p += 2;
      r.add('sv_rHeartBp');
    }
    if (diabetes) {
      p += 2;
      r.add('sv_rHeartDiabetes');
    }
    if (chol) {
      p += 2;
      r.add('sv_rHeartChol');
    }
    if (bmi >= 25 || waistHigh) {
      p += 1;
      r.add('sv_rHeartBelly');
    }
    if (sedentary) {
      p += 1;
      r.add('sv_rHeartNoExercise');
    }
    if (famHas('heart')) {
      p += 1;
      r.add('sv_rHeartFamily');
    }
    if (sleep < 6) {
      p += 1;
      r.add('sv_rHeartSleep');
    }
    final level = lvl(p, 3, 6);
    if (level != 'low' || chol) tests.add('sv_testLipid');
    if (level != 'low') tests.add('sv_testBp');
    if (r.isEmpty) r.add(_none);
    organs['heart'] = OrganResult(
      key: 'heart',
      name: 'sv_organHeart',
      does: 'sv_doesHeart',
      level: level,
      reasons: r,
      confidence: 'sv_confHeart',
    );
  }

  // ---- Kidneys
  {
    final r = <String>[];
    var p = 0;
    if (diabetes) {
      p += 3;
      r.add('sv_rKidDiabetes');
    }
    if (bp) {
      p += 3;
      r.add('sv_rKidBp');
    }
    if (age >= 60) {
      p += 2;
      r.add('sv_rKidAge');
    }
    if (famHas('kidney')) {
      p += 2;
      r.add('sv_rKidFamily');
    }
    if (smoke == 'current') {
      p += 1;
      r.add('sv_rKidSmoke');
    }
    if (bmi >= 25) {
      p += 1;
      r.add('sv_rKidObesity');
    }
    final level = lvl(p, 3, 5);
    if (level != 'low') {
      tests.add('sv_testCreatinine');
      tests.add('sv_testAcr');
    }
    if (r.isEmpty) r.add(_none);
    organs['kidneys'] = OrganResult(
      key: 'kidneys',
      name: 'sv_organKidneys',
      does: 'sv_doesKidneys',
      level: level,
      reasons: r,
      confidence: 'sv_confKidneys',
    );
  }

  // ---- Lungs
  {
    final r = <String>[];
    var level = 'low';
    if (smoke == 'current') {
      level = 'high';
      r.add('sv_rLungSmoke');
    } else if (smoke == 'past') {
      level = 'mod';
      r.add('sv_rLungPastSmoke');
    } else {
      r.add('sv_rLungNoTobacco');
    }
    if (sedentary) r.add('sv_rLungWalking');
    organs['lungs'] = OrganResult(
      key: 'lungs',
      name: 'sv_organLungs',
      does: 'sv_doesLungs',
      level: level,
      reasons: r,
      confidence: 'sv_confLungs',
    );
  }

  // ---- Overall score
  const pen = {'low': 0, 'mod': 9, 'high': 18};
  var score = 100;
  for (final o in organs.values) {
    score -= pen[o.level]!;
  }
  if (sleep < 6 || sleep > 9.5) score -= 4;
  score = math.max(10, score);
  final tier = score >= 80
      ? 'Thriving'
      : score >= 60
      ? 'Strong'
      : score >= 40
      ? 'Building'
      : 'Needs care';

  return AssessmentResult(
    score: score,
    tier: tier,
    bmi: double.parse(bmi.toStringAsFixed(1)),
    waistEstimated: waistEst,
    organs: organs,
    tests: tests.toList(),
    notes: notes,
    seeDoctor: organs.values.any((o) => o.level == 'high'),
    plan: _buildPlan(
      a,
      organs,
      bmi,
      weight,
      activity,
      sugar,
      fried,
      smoke,
      alcohol,
      sleep,
      has('bp'),
    ),
    fib4: fib4Value,
  );
}

HealthPlan _buildPlan(
  Map<String, dynamic> a,
  Map<String, OrganResult> o,
  double bmi,
  double weight,
  String activity,
  String sugar,
  String fried,
  String smoke,
  String alcohol,
  double sleep,
  bool bp,
) {
  final eatMore = <PlanItem>[
    const PlanItem('🥬', 'sv_pVegTitle', 'sv_pVegSub'),
    const PlanItem('🫘', 'sv_pProteinTitle', 'sv_pProteinSub'),
    const PlanItem('🌾', 'sv_pGrainsTitle', 'sv_pGrainsSub'),
    if (o['liver']!.level != 'low')
      const PlanItem('☕', 'sv_pCoffeeTitle', 'sv_pCoffeeSub'),
    if (o['heart']!.level != 'low')
      const PlanItem('🥜', 'sv_pNutsTitle', 'sv_pNutsSub'),
    const PlanItem('🍎', 'sv_pFruitTitle', 'sv_pFruitSub'),
  ];
  final eatLess = <PlanItem>[
    if (sugar != 'rarely')
      const PlanItem('🥤', 'sv_pSugaryDrinksTitle', 'sv_pSugaryDrinksSub'),
    if (fried != 'rarely')
      const PlanItem('🥟', 'sv_pFriedTitle', 'sv_pFriedSub'),
    const PlanItem('🍞', 'sv_pMaidaTitle', 'sv_pMaidaSub'),
    if (bp || o['kidneys']!.level != 'low')
      const PlanItem('🧂', 'sv_pSaltTitle', 'sv_pSaltSub'),
    if (alcohol != 'never')
      const PlanItem('🍺', 'sv_pAlcoholTitle', 'sv_pAlcoholSub'),
    const PlanItem('🛢️', 'sv_pOilTitle', 'sv_pOilSub'),
  ];
  final move = <PlanItem>[];
  if (bmi >= 23) {
    final lo = (weight * 0.05).round(), hi = (weight * 0.10).round();
    move.add(
      PlanItem(
        '🎯',
        textRef('sv_pLoseTitle', {'lo': lo, 'hi': hi}),
        'sv_pLoseSub',
      ),
    );
  }
  if (o['heart']!.level == 'high') {
    move.add(
      const PlanItem('🩺', 'sv_pDoctorFirstTitle', 'sv_pDoctorFirstSub'),
    );
  }
  switch (activity) {
    case 'sit':
      move.addAll(const [
        PlanItem('🚶', 'sv_pSitWalkTitle', 'sv_pSitWalkSub'),
        PlanItem('⏱️', 'sv_pSitBriskTitle', 'sv_pSitBriskSub'),
        PlanItem('🪑', 'sv_pSitSquatsTitle', 'sv_pSitSquatsSub'),
        PlanItem('⏰', 'sv_pSitStandTitle', 'sv_pSitStandSub'),
      ]);
      break;
    case 'light':
      move.addAll(const [
        PlanItem('⏱️', 'sv_pLightBriskTitle', 'sv_pLightBriskSub'),
        PlanItem('💪', 'sv_pLightStrengthTitle', 'sv_pLightStrengthSub'),
        PlanItem('🧘', 'sv_pLightSuryaTitle', 'sv_pLightSuryaSub'),
      ]);
      break;
    case 'regular':
      move.addAll(const [
        PlanItem('✅', 'sv_pRegKeepTitle', 'sv_pRegKeepSub'),
        PlanItem('💪', 'sv_pRegStrengthTitle', 'sv_pRegStrengthSub'),
        PlanItem('⚡', 'sv_pRegIntervalsTitle', 'sv_pRegIntervalsSub'),
      ]);
      break;
    default:
      move.addAll(const [
        PlanItem('✅', 'sv_pHeavyGreatTitle', 'sv_pHeavyGreatSub'),
        PlanItem('🧘', 'sv_pHeavyYogaTitle', 'sv_pHeavyYogaSub'),
      ]);
  }
  final habits = <PlanItem>[
    PlanItem(
      '😴',
      'sv_pSleepTitle',
      sleep < 7 ? 'sv_pSleepShortSub' : 'sv_pSleepOkSub',
    ),
    if (smoke == 'current')
      const PlanItem('🚭', 'sv_pQuitTitle', 'sv_pQuitSub'),
    const PlanItem('🍽️', 'sv_pDinnerTitle', 'sv_pDinnerSub'),
    const PlanItem('💧', 'sv_pWaterTitle', 'sv_pWaterSub'),
    const PlanItem('📅', 'sv_pRecheckTitle', 'sv_pRecheckSub'),
  ];
  return HealthPlan(eatMore, eatLess, move, habits);
}
