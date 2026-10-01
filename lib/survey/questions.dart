// Survey questions. Later you can serve this list as JSON from your backend
// so questions can be edited without releasing a new app version.

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

List<Opt> Function(Answers) _fixed(List<Opt> o) => (_) => o;

String _feetInches(double cm) {
  final i = (cm / 2.54).round();
  return '${i ~/ 12} ft ${i % 12} in';
}

final List<Question> healthQuestions = [
  Question(
    id: 'sex', type: QType.choice, title: 'Are you male or female?',
    why: 'Healthy waist size and heart risk are different for men and women.',
    options: _fixed(const [Opt('m', 'Male', '👨'), Opt('f', 'Female', '👩')]),
  ),
  Question(
    id: 'age', type: QType.slider, title: 'How old are you?',
    min: 18, max: 90, step: 1, def: 30, unit: 'years',
    why: 'Risk for most organs slowly rises with age.',
  ),
  Question(
    id: 'height', type: QType.slider, title: 'How tall are you?',
    min: 130, max: 210, step: 1, def: 165, unit: 'cm', alt: _feetInches,
  ),
  Question(
    id: 'weight', type: QType.slider, title: 'How much do you weigh?',
    min: 30, max: 180, step: 1, def: 65, unit: 'kg',
    why: 'An approximate number is fine.',
  ),
  Question(
    id: 'waist', type: QType.slider, title: 'What is your waist size?',
    min: 55, max: 150, step: 1, def: 85, unit: 'cm',
    alt: (v) => '${(v / 2.54).round()} inches',
    why: 'Measure around your belly button, not where your trousers sit. '
        'Belly fat is the biggest clue for fatty liver.',
    unknownLabel: "I don't know, estimate it for me",
  ),
  Question(
    id: 'activity', type: QType.choice, title: 'How active is a normal day for you?',
    options: _fixed(const [
      Opt('sit', 'Mostly sitting', '🪑', sub: 'Desk job, little walking'),
      Opt('light', 'Some walking', '🚶', sub: 'Errands, stairs sometimes'),
      Opt('regular', 'I exercise', '🏃', sub: 'About 30 minutes, most days'),
      Opt('heavy', 'Very active', '🏋️', sub: 'Sport or physical work'),
    ]),
  ),
  Question(
    id: 'sugar', type: QType.choice,
    title: 'How often do you have sweets, sugary chai or cold drinks?',
    options: _fixed(const [
      Opt('rarely', 'Rarely', '🙂'),
      Opt('weekly', 'A few times a week', '🍬'),
      Opt('daily', 'Every day', '🥤'),
    ]),
  ),
  Question(
    id: 'fried', type: QType.choice, title: 'How often do you eat fried or outside food?',
    options: _fixed(const [
      Opt('rarely', 'Rarely', '🥗'),
      Opt('weekly', 'About once a week', '🥟'),
      Opt('often', 'Most days', '🍔'),
    ]),
  ),
  Question(
    id: 'sleep', type: QType.slider, title: 'How many hours do you sleep at night?',
    min: 3, max: 12, step: 0.5, def: 7, unit: 'hours',
  ),
  Question(
    id: 'smoke', type: QType.choice, title: 'Do you smoke or use tobacco?',
    why: 'This includes cigarettes, bidi, gutka and khaini.',
    options: _fixed(const [
      Opt('never', 'Never', '🚭'),
      Opt('past', 'I used to, but quit', '🙌'),
      Opt('current', 'Yes', '🚬'),
    ]),
  ),
  Question(
    id: 'alcohol', type: QType.choice, title: 'How often do you drink alcohol?',
    options: _fixed(const [
      Opt('never', 'Never', '💧'),
      Opt('sometimes', 'Occasionally', '🥂', sub: 'A few times a month or less'),
      Opt('weekly', 'Every week', '🍺'),
    ]),
  ),
  Question(
    id: 'conditions', type: QType.multi,
    title: 'Has a doctor ever told you that you have any of these?',
    why: 'Pick all that apply.',
    options: (a) => [
      const Opt('diabetes', 'Diabetes or pre-diabetes', '🩸'),
      const Opt('bp', 'High blood pressure', '📈'),
      const Opt('chol', 'High cholesterol', '🧈'),
      const Opt('thyroid', 'Thyroid problem', '🦋'),
      if (a['sex'] == 'f') const Opt('pcos', 'PCOS / PCOD', '🌸'),
      const Opt('none', 'None of these', '👍', exclusive: true),
      const Opt('unsure', 'Not sure, never tested', '🤷', exclusive: true),
    ],
  ),
  Question(
    id: 'family', type: QType.multi,
    title: 'Do your parents, brothers or sisters have any of these?',
    why: 'Pick all that apply.',
    options: _fixed(const [
      Opt('diabetes', 'Diabetes', '🩸'),
      Opt('heart', 'Heart attack or heart disease', '❤️'),
      Opt('liver', 'Fatty liver or cirrhosis', '🍃'),
      Opt('kidney', 'Kidney disease', '🫘'),
      Opt('none', "None, or I don't know", '🤷', exclusive: true),
    ]),
  ),
  Question(
    id: 'hasReport', type: QType.choice, title: 'Do you have a recent blood test report?',
    why: 'This is optional. With 3 numbers from it, we can check your liver much more accurately.',
    options: _fixed(const [
      Opt('yes', 'Yes, I have it', '📄'),
      Opt('no', 'No, skip this', '⏭️', sub: 'We will use your other answers'),
    ]),
  ),
  Question(
    id: 'labs', type: QType.labs, title: 'Copy these 3 numbers from your report',
    showIf: (a) => a['hasReport'] == 'yes',
  ),
];
