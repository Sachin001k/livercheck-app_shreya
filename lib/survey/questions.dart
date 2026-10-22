// Survey questions. Later you can serve this list as JSON from your backend
// so questions can be edited without releasing a new app version.
//
// All text fields (title, why, labels, units, ...) hold translation keys
// (see lib/translations/en.dart); the survey screen shows them with
// context.t / trText().

import 'assess.dart' show textRef;

enum QType { choice, multi, slider, labs }

typedef Answers = Map<String, dynamic>;

class Opt {
  final String v;
  final String label;
  final String emoji;
  final String? sub;
  final bool exclusive; // e.g. "None of these" clears other picks
  const Opt(this.v, this.label, this.emoji, {this.sub, this.exclusive = false});
}

class Question {
  final String id;
  final QType type;
  final String title;
  final String? why;
  final List<Opt> Function(Answers a)? options;
  final double min, max, step, def;
  final String unit;
  final String Function(double v)? alt;
  final String? unknownLabel;
  final bool Function(Answers a)? showIf;

  Question({
    required this.id,
    required this.type,
    required this.title,
    this.why,
    this.options,
    this.min = 0,
    this.max = 0,
    this.step = 1,
    this.def = 0,
    this.unit = '',
    this.alt,
    this.unknownLabel,
    this.showIf,
  });
}

List<Opt> Function(Answers) _fixed(List<Opt> o) =>
    (_) => o;

String _feetInches(double cm) {
  final i = (cm / 2.54).round();
  return textRef('sv_altFeetInches', {'ft': i ~/ 12, 'in': i % 12});
}

final List<Question> healthQuestions = [
  Question(
    id: 'sex',
    type: QType.choice,
    title: 'sv_qSexTitle',
    why: 'sv_qSexWhy',
    options: _fixed(const [
      Opt('m', 'sv_optMale', '👨'),
      Opt('f', 'sv_optFemale', '👩'),
    ]),
  ),
  Question(
    id: 'age',
    type: QType.slider,
    title: 'sv_qAgeTitle',
    min: 18,
    max: 90,
    step: 1,
    def: 30,
    unit: 'sv_unitYears',
    why: 'sv_qAgeWhy',
  ),
  Question(
    id: 'height',
    type: QType.slider,
    title: 'sv_qHeightTitle',
    min: 130,
    max: 210,
    step: 1,
    def: 165,
    unit: 'cm',
    alt: _feetInches,
  ),
  Question(
    id: 'weight',
    type: QType.slider,
    title: 'sv_qWeightTitle',
    min: 30,
    max: 180,
    step: 1,
    def: 65,
    unit: 'kg',
    why: 'sv_qWeightWhy',
  ),
  Question(
    id: 'waist',
    type: QType.slider,
    title: 'sv_qWaistTitle',
    min: 55,
    max: 150,
    step: 1,
    def: 85,
    unit: 'cm',
    alt: (v) => textRef('sv_altInches', {'n': (v / 2.54).round()}),
    why: 'sv_qWaistWhy',
    unknownLabel: 'sv_qWaistUnknown',
  ),
  Question(
    id: 'activity',
    type: QType.choice,
    title: 'sv_qActivityTitle',
    options: _fixed(const [
      Opt('sit', 'sv_optSit', '🪑', sub: 'sv_optSitSub'),
      Opt('light', 'sv_optLight', '🚶', sub: 'sv_optLightSub'),
      Opt('regular', 'sv_optRegular', '🏃', sub: 'sv_optRegularSub'),
      Opt('heavy', 'sv_optHeavy', '🏋️', sub: 'sv_optHeavySub'),
    ]),
  ),
  Question(
    id: 'sugar',
    type: QType.choice,
    title: 'sv_qSugarTitle',
    options: _fixed(const [
      Opt('rarely', 'sv_optRarely', '🙂'),
      Opt('weekly', 'sv_optFewTimesWeek', '🍬'),
      Opt('daily', 'sv_optEveryDay', '🥤'),
    ]),
  ),
  Question(
    id: 'fried',
    type: QType.choice,
    title: 'sv_qFriedTitle',
    options: _fixed(const [
      Opt('rarely', 'sv_optRarely', '🥗'),
      Opt('weekly', 'sv_optOnceWeek', '🥟'),
      Opt('often', 'sv_optMostDays', '🍔'),
    ]),
  ),
  Question(
    id: 'sleep',
    type: QType.slider,
    title: 'sv_qSleepTitle',
    min: 3,
    max: 12,
    step: 0.5,
    def: 7,
    unit: 'sv_unitHours',
  ),
  Question(
    id: 'smoke',
    type: QType.choice,
    title: 'sv_qSmokeTitle',
    why: 'sv_qSmokeWhy',
    options: _fixed(const [
      Opt('never', 'sv_optNever', '🚭'),
      Opt('past', 'sv_optQuit', '🙌'),
      Opt('current', 'sv_optYes', '🚬'),
    ]),
  ),
  Question(
    id: 'alcohol',
    type: QType.choice,
    title: 'sv_qAlcoholTitle',
    options: _fixed(const [
      Opt('never', 'sv_optNever', '💧'),
      Opt(
        'sometimes',
        'sv_optOccasionally',
        '🥂',
        sub: 'sv_optOccasionallySub',
      ),
      Opt('weekly', 'sv_optEveryWeek', '🍺'),
    ]),
  ),
  Question(
    id: 'conditions',
    type: QType.multi,
    title: 'sv_qConditionsTitle',
    why: 'sv_pickAll',
    options: (a) => [
      const Opt('diabetes', 'sv_optDiabetesPre', '🩸'),
      const Opt('bp', 'sv_optBp', '📈'),
      const Opt('chol', 'sv_optChol', '🧈'),
      const Opt('thyroid', 'sv_optThyroid', '🦋'),
      if (a['sex'] == 'f') const Opt('pcos', 'sv_optPcos', '🌸'),
      const Opt('none', 'sv_optNoneOfThese', '👍', exclusive: true),
      const Opt('unsure', 'sv_optNotSure', '🤷', exclusive: true),
    ],
  ),
  Question(
    id: 'family',
    type: QType.multi,
    title: 'sv_qFamilyTitle',
    why: 'sv_pickAll',
    options: _fixed(const [
      Opt('diabetes', 'sv_optDiabetes', '🩸'),
      Opt('heart', 'sv_optHeart', '❤️'),
      Opt('liver', 'sv_optLiver', '🍃'),
      Opt('kidney', 'sv_optKidney', '🫘'),
      Opt('none', 'sv_optNoneOrDontKnow', '🤷', exclusive: true),
    ]),
  ),
  Question(
    id: 'hasReport',
    type: QType.choice,
    title: 'sv_qReportTitle',
    why: 'sv_qReportWhy',
    options: _fixed(const [
      Opt('yes', 'sv_optHaveReport', '📄'),
      Opt('no', 'sv_optSkipReport', '⏭️', sub: 'sv_optSkipReportSub'),
    ]),
  ),
  Question(
    id: 'labs',
    type: QType.labs,
    title: 'sv_qLabsTitle',
    showIf: (a) => a['hasReport'] == 'yes',
  ),
];
