import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/app_language.dart';
import 'package:livrcheck_app/daily/daily_checkin_card.dart';
import 'package:livrcheck_app/daily/daily_items.dart';
import 'package:livrcheck_app/daily/daily_targets.dart';
import 'package:livrcheck_app/screens/home_screen.dart';
import 'package:livrcheck_app/services/data_service.dart';
import 'package:livrcheck_app/translations.dart';

DailyItem _item(String key) => dailyItems.firstWhere((i) => i.key == key);

void main() {
  group('itemScore matches the day score', () {
    final t = targetsFor(gender: 'male', age: 40, heightCm: 170, weightKg: 65);

    test('too many calories scores 0, not a full bar', () {
      expect(itemScore(_item('calories'), 4000, t), 0);
      expect(itemScore(_item('calories'), t.calories.toDouble(), t), 1);
    });

    test('too much sleep scores low', () {
      expect(itemScore(_item('sleep'), 12, t), 0);
      expect(itemScore(_item('sleep'), 8, t), 1);
    });

    test('each item equals its scoreDay value', () {
      for (final item in dailyItems) {
        final v = item.startValue(t) + item.step;
        final expected = scoreDay(logFromValues({item.key: v}), t).items.single;
        expect(itemScore(item, v, t), expected.value, reason: item.key);
      }
    });
  });

  testWidgets('daily card keeps its state when the layout switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final profile = Profile(
      id: '1',
      fullName: 'Test User',
      age: 40,
      gender: null,
      heightCm: null,
      weightKg: null,
      preferredLanguage: AppLanguage.en,
      createdAt: DateTime(2026, 9, 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            LanguageScope(notifier: appLanguage, child: child!),
        home: Scaffold(
          body: HomeScreen(profile: profile, onStartCheck: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final before = tester.state(find.byType(DailyCheckinCard));

    // Wide (side by side) → phone (stacked).
    tester.view.physicalSize = const Size(400, 1600);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.state(find.byType(DailyCheckinCard)), same(before));

    // And back again.
    tester.view.physicalSize = const Size(800, 1600);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.state(find.byType(DailyCheckinCard)), same(before));
    expect(tester.takeException(), isNull);
  });
}
