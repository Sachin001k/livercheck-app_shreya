import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/daily/daily_targets.dart';
import 'package:livrcheck_app/rewards/reward_store.dart';

void main() {
  group('parseSpecialSurveys', () {
    final good = {
      'id': 's1',
      'title': 'Water habits',
      'description': null,
      'questions': [
        {
          'id': 'glasses',
          'type': 'choice',
          'title': 'How many glasses?',
          'options': [
            {'v': 1, 'label': 'One'}, // numeric value
            {'v': 'lots', 'label': 'Lots', 'emoji': '🥤'},
          ],
        },
      ],
      'reward_coins': 50,
      'ends_at': null,
    };

    test('a malformed survey is skipped, the rest still load', () {
      final surveys = parseSpecialSurveys(
        [
          good,
          {
            'id': 's2',
            'title': 'Broken',
            'questions': [
              {'id': 'q', 'type': 'text'}, // no title
            ],
            'reward_coins': 10,
          },
          {'id': 's3', 'questions': 'not a list', 'reward_coins': 10},
        ],
        {'s1'},
      );
      expect(surveys.map((s) => s.id), ['s1']);
      expect(surveys.single.completed, isTrue);
    });

    test('numeric option values are read as text', () {
      final s = parseSpecialSurveys([good], {}).single;
      expect(s.questions.single.options.first.v, '1');
      expect(s.questions.single.options.last.emoji, '🥤');
      expect(s.completed, isFalse);
    });
  });

  test('DailyLog.toMap always sends meals, null when empty', () {
    expect(const DailyLog(waterMl: 500).toMap().containsKey('meals'), isTrue);
    expect(const DailyLog(waterMl: 500).toMap()['meals'], isNull);
    expect(const DailyLog(meals: {}).toMap()['meals'], isNull);
    expect(const DailyLog(meals: {'roti': 2}).toMap()['meals'], {'roti': 2});
  });
}
