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
    required this.key, required this.name, required this.does, required this.level,
    required this.confidence, required this.reasons, this.extra,
  });
  Map<String, dynamic> toJson() => {
        'key': key, 'name': name, 'does': does, 'level': level,
        'confidence': confidence, 'reasons': reasons, 'extra': extra,
      };
  factory OrganResult.fromJson(Map<String, dynamic> j) => OrganResult(
        key: j['key'], name: j['name'], does: j['does'], level: j['level'],
        confidence: j['confidence'], reasons: List<String>.from(j['reasons']), extra: j['extra'],
      );
}

class PlanItem {
  final String emoji, title, sub;
  const PlanItem(this.emoji, this.title, this.sub);
  Map<String, dynamic> toJson() => {'e': emoji, 't': title, 's': sub};
  factory PlanItem.fromJson(Map<String, dynamic> j) => PlanItem(j['e'], j['t'], j['s']);
}

class HealthPlan {
  final List<PlanItem> eatMore, eatLess, move, habits;
  HealthPlan(this.eatMore, this.eatLess, this.move, this.habits);
  List<PlanItem> byKey(String k) =>
      k == 'eatMore' ? eatMore : k == 'eatLess' ? eatLess : k == 'move' ? move : habits;
  static List<Map<String, dynamic>> _l(List<PlanItem> x) => x.map((e) => e.toJson()).toList();
  static List<PlanItem> _p(dynamic x) =>
      (x as List).map((e) => PlanItem.fromJson(Map<String, dynamic>.from(e))).toList();
  Map<String, dynamic> toJson() =>
      {'eatMore': _l(eatMore), 'eatLess': _l(eatLess), 'move': _l(move), 'habits': _l(habits)};
  factory HealthPlan.fromJson(Map<String, dynamic> j) =>
      HealthPlan(_p(j['eatMore']), _p(j['eatLess']), _p(j['move']), _p(j['habits']));
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
    required this.score, required this.tier, required this.bmi, required this.waistEstimated,
    required this.organs, required this.tests, required this.notes,
    required this.seeDoctor, required this.plan, this.fib4,
  });
  Map<String, dynamic> toJson() => {
        'score': score, 'tier': tier, 'bmi': bmi, 'waistEstimated': waistEstimated,
        'organs': organs.map((k, v) => MapEntry(k, v.toJson())),
        'tests': tests, 'notes': notes, 'seeDoctor': seeDoctor, 'plan': plan.toJson(),
        'fib4': fib4,
      };
  factory AssessmentResult.fromJson(Map<String, dynamic> j) => AssessmentResult(
        score: (j['score'] as num).toInt(), tier: j['tier'], bmi: (j['bmi'] as num).toDouble(),
        waistEstimated: j['waistEstimated'],
        organs: (j['organs'] as Map).map((k, v) =>
            MapEntry(k as String, OrganResult.fromJson(Map<String, dynamic>.from(v)))),
        tests: List<String>.from(j['tests']), notes: List<String>.from(j['notes']),
        seeDoctor: j['seeDoctor'], plan: HealthPlan.fromJson(Map<String, dynamic>.from(j['plan'])),
        fib4: (j['fib4'] as num?)?.toDouble(),
      );
}

const _none = 'No major warning signs from your answers.';

/// Converts a platelet count typed in [unit] ('lakh', 'ul' or 'g') to ×10⁹/L.
double plateletsToG(double raw, String unit) =>
    unit == 'lakh' ? raw * 100 : unit == 'ul' ? raw / 1000 : raw;

AssessmentResult assess(Map<String, dynamic> a) {
  double n(String k, double d) => (a[k] as num?)?.toDouble() ?? d;
  final male = a['sex'] == 'm';
  final age = n('age', 30), height = n('height', 165), weight = n('weight', 65), sleep = n('sleep', 7);
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
  String lvl(int p, int m, int h) => p >= h ? 'high' : p >= m ? 'mod' : 'low';

  // Waist: real value, or estimated from BMI when unknown
  final waistEst = waist == null;
  int waistScore;
  bool waistHigh;
  if (waist != null) {
    waistHigh = male ? waist >= 90 : waist >= 80;
    waistScore = male
        ? (waist >= 100 ? 20 : waist >= 90 ? 10 : 0)
        : (waist >= 90 ? 20 : waist >= 80 ? 10 : 0);
  } else {
    waistScore = bmi >= 25 ? 20 : bmi >= 23 ? 10 : 0;
    waistHigh = bmi >= 25;
  }

  // ---- Pancreas / blood sugar: Indian Diabetes Risk Score
  {
    final r = <String>[];
    var idrs = age < 35 ? 0 : age < 50 ? 20 : 30;
    idrs += const {'heavy': 0, 'regular': 10, 'light': 20, 'sit': 30}[activity] ?? 20;
    idrs += famHas('diabetes') ? 10 : 0;
    idrs += waistScore;
    var level = idrs >= 60 ? 'high' : idrs >= 30 ? 'mod' : 'low';
    if (diabetes) {
      level = 'high';
      r.add('You already have diabetes or pre-diabetes. Keeping sugar in control protects your liver, heart and kidneys too.');
    }
    if (age >= 35) r.add('Age above 35 raises diabetes risk.');
    if (waistScore > 0) r.add(waistEst ? 'Your weight suggests extra belly fat.' : 'Your waist is above the healthy limit.');
    if (sedentary || activity == 'light') r.add('Low daily activity.');
    if (famHas('diabetes')) r.add('Diabetes runs in your family.');
    if (sugar == 'daily') r.add('Sweets or sugary drinks every day.');
    if (r.isEmpty) r.add(_none);
    if (level != 'low' || has('unsure')) tests.add('HbA1c (3-month sugar)');
    organs['pancreas'] = OrganResult(
      key: 'pancreas', name: 'Pancreas & blood sugar',
      does: 'Makes insulin, which controls your blood sugar.',
      level: level, reasons: r, confidence: 'Based on the Indian Diabetes Risk Score',
      extra: 'Risk score $idrs of 100',
    );
  }

  // ---- Liver
  {
    final r = <String>[];
    var p = 0;
    if (bmi >= 25) { p += 2; r.add('Your weight is in the obese range for Indians (BMI 25 or more).'); }
    else if (bmi >= 23) { p += 1; r.add('Your weight is slightly above healthy for Indians (BMI 23 to 25).'); }
    if (waistHigh) { p += 2; r.add('Belly fat is the strongest sign of fat in the liver.'); }
    if (diabetes) { p += 3; r.add('Diabetes strongly increases fatty liver risk.'); }
    if (bp) { p += 1; r.add('High blood pressure often goes with fatty liver.'); }
    if (chol) { p += 1; r.add('High cholesterol or triglycerides.'); }
    if (sedentary) { p += 1; r.add('Sitting most of the day.'); }
    if (sugar == 'daily') { p += 1; r.add('Daily sugar turns into liver fat quickly.'); }
    if (fried == 'often') { p += 1; r.add('Fried or outside food most days.'); }
    if (alcohol == 'weekly') { p += 2; r.add('Weekly alcohol adds to liver damage.'); }
    if (famHas('liver')) { p += 1; r.add('Fatty liver runs in your family.'); }
    if (has('pcos')) { p += 1; r.add('PCOS is linked to fatty liver.'); }
    if (has('thyroid')) { p += 1; r.add('Low thyroid can add to liver fat.'); }

    var level = lvl(p, 3, 6);
    var conf = 'Estimated from your lifestyle. Add a blood test for a more accurate check.';
    String? extra;
    final labs = a['labs'] as Map?;
    final ast = (labs?['ast'] as num?)?.toDouble();
    final alt = (labs?['alt'] as num?)?.toDouble();
    final pltRaw = (labs?['plt'] as num?)?.toDouble();
    if (ast != null && alt != null && pltRaw != null && alt > 0 && pltRaw > 0) {
      final plt = plateletsToG(pltRaw, labs!['unit'] as String? ?? 'lakh'); // → ×10⁹/L
      final fib4 = (age * ast) / (plt * math.sqrt(alt));
      fib4Value = double.parse(fib4.toStringAsFixed(2));
      final lowCut = age >= 65 ? 2.0 : 1.3;
      extra = 'FIB-4 score ${fib4.toStringAsFixed(2)}';
      conf = 'Checked with your blood test (FIB-4)';
      if (fib4 > 2.67) {
        level = 'high';
        r.insert(0, 'Your FIB-4 score suggests possible liver scarring.');
        tests.add('FibroScan');
      } else if (fib4 >= lowCut) {
        level = 'mod';
        r.insert(0, 'Your FIB-4 score is in the grey zone, so a scan is needed to be sure.');
        tests.add('FibroScan');
      } else {
        r.insert(0, 'Your FIB-4 score shows liver scarring is unlikely.');
        if (level == 'high') level = 'mod';
      }
      if (alt > 40) r.add('ALT (SGPT) is above normal, which means liver cells may be under stress.');
      if (age < 35) {
        notes.add('FIB-4 is less reliable under age 35. If you have several risk factors, ask a doctor about an ultrasound.');
      }
    } else {
      tests.add('Liver function test (LFT)');
      tests.add('Complete blood count (CBC)');
      if (level == 'high') tests.add('Liver ultrasound');
    }
    if (r.isEmpty) r.add(_none);
    organs['liver'] = OrganResult(
      key: 'liver', name: 'Liver', does: 'Cleans your blood, stores energy and helps digest fat.',
      level: level, reasons: r, confidence: conf, extra: extra,
    );
  }

  // ---- Heart
  {
    final r = <String>[];
    var p = 0;
    if ((male && age >= 45) || (!male && age >= 55)) { p += 2; r.add('Heart risk rises from this age.'); }
    if (age >= 65) p += 1;
    if (smoke == 'current') { p += 3; r.add('Smoking or tobacco is the biggest heart risk you can change.'); }
    else if (smoke == 'past') { p += 1; r.add('Past smoking still leaves some risk, and it drops every year you stay off it.'); }
    if (bp) { p += 2; r.add('High blood pressure strains the heart.'); }
    if (diabetes) { p += 2; r.add('Diabetes damages blood vessels.'); }
    if (chol) { p += 2; r.add('High cholesterol can block arteries.'); }
    if (bmi >= 25 || waistHigh) { p += 1; r.add('Extra weight around the belly.'); }
    if (sedentary) { p += 1; r.add('Very little exercise.'); }
    if (famHas('heart')) { p += 1; r.add('Heart disease runs in your family.'); }
    if (sleep < 6) { p += 1; r.add('Less than 6 hours of sleep.'); }
    final level = lvl(p, 3, 6);
    if (level != 'low' || chol) tests.add('Lipid profile (cholesterol)');
    if (level != 'low') tests.add('Blood pressure check');
    if (r.isEmpty) r.add(_none);
    organs['heart'] = OrganResult(
      key: 'heart', name: 'Heart', does: 'Pumps blood and oxygen to your whole body.',
      level: level, reasons: r, confidence: 'Estimated from your risk factors (no cholesterol test used)',
    );
  }

  // ---- Kidneys
  {
    final r = <String>[];
    var p = 0;
    if (diabetes) { p += 3; r.add('Diabetes is the top cause of kidney damage in India.'); }
    if (bp) { p += 3; r.add('High blood pressure damages kidney filters.'); }
    if (age >= 60) { p += 2; r.add('Kidney function slowly declines with age.'); }
    if (famHas('kidney')) { p += 2; r.add('Kidney disease runs in your family.'); }
    if (smoke == 'current') { p += 1; r.add('Smoking reduces blood flow to kidneys.'); }
    if (bmi >= 25) { p += 1; r.add('Obesity makes kidneys work harder.'); }
    final level = lvl(p, 3, 5);
    if (level != 'low') { tests.add('Serum creatinine'); tests.add('Urine albumin (ACR)'); }
    if (r.isEmpty) r.add(_none);
    organs['kidneys'] = OrganResult(
      key: 'kidneys', name: 'Kidneys', does: 'Filter waste and extra water out of your blood.',
      level: level, reasons: r, confidence: 'Estimated from your risk factors',
    );
  }

  // ---- Lungs
  {
    final r = <String>[];
    var level = 'low';
    if (smoke == 'current') { level = 'high'; r.add('Tobacco damages lungs every day you use it.'); }
    else if (smoke == 'past') { level = 'mod'; r.add('Your lungs are healing since you quit. Keep going.'); }
    else { r.add('No tobacco. That is the best thing you can do for your lungs.'); }
    if (sedentary) r.add('Regular walking keeps lung capacity up.');
    organs['lungs'] = OrganResult(
      key: 'lungs', name: 'Lungs', does: 'Bring oxygen into your blood.',
      level: level, reasons: r, confidence: 'Based on tobacco use',
    );
  }

  // ---- Overall score
  const pen = {'low': 0, 'mod': 9, 'high': 18};
  var score = 100;
  for (final o in organs.values) { score -= pen[o.level]!; }
  if (sleep < 6 || sleep > 9.5) score -= 4;
  score = math.max(10, score);
  final tier = score >= 80 ? 'Thriving' : score >= 60 ? 'Strong' : score >= 40 ? 'Building' : 'Needs care';

  return AssessmentResult(
    score: score, tier: tier, bmi: double.parse(bmi.toStringAsFixed(1)), waistEstimated: waistEst,
    organs: organs, tests: tests.toList(), notes: notes,
    seeDoctor: organs.values.any((o) => o.level == 'high'),
    plan: _buildPlan(a, organs, bmi, weight, activity, sugar, fried, smoke, alcohol, sleep, has('bp')),
    fib4: fib4Value,
  );
}

HealthPlan _buildPlan(Map<String, dynamic> a, Map<String, OrganResult> o, double bmi, double weight,
    String activity, String sugar, String fried, String smoke, String alcohol, double sleep, bool bp) {
  final eatMore = <PlanItem>[
    const PlanItem('🥬', 'Fill half your plate with vegetables', 'Bhindi, lauki, palak, cabbage, beans, cucumber salad.'),
    const PlanItem('🫘', 'Protein in every meal', 'Dal, chana, rajma, sprouts, paneer, curd, eggs or fish.'),
    const PlanItem('🌾', 'Swap white rice and maida for whole grains', 'Jowar, bajra or ragi roti, brown rice, whole-wheat atta.'),
    if (o['liver']!.level != 'low')
      const PlanItem('☕', 'Coffee without sugar is fine', '1 to 2 cups a day is linked with healthier livers.'),
    if (o['heart']!.level != 'low')
      const PlanItem('🥜', 'A small handful of nuts and seeds', 'Almonds, walnuts, flaxseed or til, most days.'),
    const PlanItem('🍎', 'Whole fruit, not juice', 'Guava, papaya, apple, orange. Eat 1 to 2 a day.'),
  ];
  final eatLess = <PlanItem>[
    if (sugar != 'rarely')
      const PlanItem('🥤', 'Sugary drinks, packaged juice, sweet chai', 'Liquid sugar turns into liver fat fastest. Cut sugar in chai to half, then less.'),
    if (fried != 'rarely')
      const PlanItem('🥟', 'Fried snacks', 'Samosa, pakora, bhujia, chips. Keep to once a week.'),
    const PlanItem('🍞', 'Maida foods', 'White bread, biscuits, naan, bakery items.'),
    if (bp || o['kidneys']!.level != 'low')
      const PlanItem('🧂', 'Salt', 'Pickles, papad, namkeen, instant noodles, extra salt at the table.'),
    if (alcohol != 'never')
      const PlanItem('🍺', 'Alcohol', 'It adds to liver damage even when fat is the main cause.'),
    const PlanItem('🛢️', 'Too much cooking oil', 'Measure it. About 3 to 4 teaspoons per person a day is enough.'),
  ];
  final move = <PlanItem>[];
  if (bmi >= 23) {
    final lo = (weight * 0.05).round(), hi = (weight * 0.10).round();
    move.add(PlanItem('🎯', 'Aim to lose $lo to $hi kg over 6 months', 'Losing 5 to 10% of your weight can reverse fat in the liver.'));
  }
  if (o['heart']!.level == 'high') {
    move.add(const PlanItem('🩺', 'Talk to a doctor before hard exercise', 'Start with walking until you get checked.'));
  }
  switch (activity) {
    case 'sit':
      move.addAll(const [
        PlanItem('🚶', 'Week 1 to 2: walk 10 minutes after each main meal', 'Walking after food lowers blood sugar spikes.'),
        PlanItem('⏱️', 'Week 3 onward: 30-minute brisk walk, 5 days a week', 'Walk fast enough that talking gets a little hard.'),
        PlanItem('🪑', 'Twice a week: chair squats and wall push-ups', '10 of each, 3 rounds. Takes 10 minutes.'),
        PlanItem('⏰', 'Stand up every 30 minutes', 'Set a reminder at work.'),
      ]);
      break;
    case 'light':
      move.addAll(const [
        PlanItem('⏱️', 'Brisk walk 30 to 40 minutes, 5 days a week', 'Faster than your normal pace.'),
        PlanItem('💪', 'Strength 2 days a week', 'Squats, lunges, push-ups and plank, 3 rounds of 10.'),
        PlanItem('🧘', 'On busy days, 10 rounds of surya namaskar', 'Works the whole body in 15 minutes.'),
      ]);
      break;
    case 'regular':
      move.addAll(const [
        PlanItem('✅', 'Keep 150+ minutes a week', 'You are already doing well.'),
        PlanItem('💪', 'Add 2 strength days if you only do cardio', 'Muscle helps your body use sugar.'),
        PlanItem('⚡', 'Try intervals once a week', '1 minute fast, 2 minutes easy, 8 rounds.'),
      ]);
      break;
    default:
      move.addAll(const [
        PlanItem('✅', 'Your activity level is great', 'Focus on food quality and recovery.'),
        PlanItem('🧘', 'Stretch or yoga 2 days a week', 'Helps you recover and avoid injury.'),
      ]);
  }
  final habits = <PlanItem>[
    PlanItem('😴', 'Sleep 7 to 8 hours', sleep < 7
        ? 'You sleep less than this now. Short sleep raises sugar and appetite.'
        : 'You are on track. Keep a fixed bedtime.'),
    if (smoke == 'current')
      const PlanItem('🚭', 'Quit tobacco', 'Call the free national quitline: 1800-11-2356.'),
    const PlanItem('🍽️', 'Eat dinner 2 to 3 hours before bed', 'Gives your liver and gut time to rest.'),
    const PlanItem('💧', 'Drink water instead of sweet drinks', 'Keep a bottle with you.'),
    const PlanItem('📅', 'Recheck in 3 months', 'Take this check again to see your score change.'),
  ];
  return HealthPlan(eatMore, eatLess, move, habits);
}
