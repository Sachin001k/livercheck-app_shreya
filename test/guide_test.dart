import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/app_language.dart';
import 'package:livrcheck_app/learn/guide_content.dart';
import 'package:livrcheck_app/learn/guide_store.dart';
import 'package:livrcheck_app/learn/learn_screen.dart';
import 'package:livrcheck_app/services/data_service.dart';
import 'package:livrcheck_app/translations.dart';
import 'package:livrcheck_app/translations/en.dart';
import 'package:shared_preferences/shared_preferences.dart';

Iterable<String> _allKeys() sync* {
  for (final c in guideChapters) {
    yield c.titleKey;
    yield c.bodyKey;
    for (final t in c.topics) {
      yield t.titleKey;
      for (final b in t.blocks) {
        yield* b.keys;
      }
    }
  }
  for (final h in challengeHabits) {
    yield* h.keys;
  }
  for (final (_, t, h) in planFields) {
    yield t;
    yield h;
  }
  for (final g in AgeGroup.values) {
    yield g.labelKey;
    yield g.shortKey;
  }
}

Widget _app(Widget child, {double textScale = 1}) => MaterialApp(
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: LanguageScope(notifier: appLanguage, child: c!),
  ),
  home: child,
);

void main() {
  test('every guide text key has English text', () {
    final missing = _allKeys().where((k) => !en.containsKey(k)).toSet();
    expect(missing, isEmpty);
  });

  test('ages map to the guidebook groups', () {
    expect(ageGroupFor(10), AgeGroup.children);
    expect(ageGroupFor(17), AgeGroup.children);
    expect(ageGroupFor(18), AgeGroup.adults);
    expect(ageGroupFor(64), AgeGroup.adults);
    expect(ageGroupFor(65), AgeGroup.older);
    expect(ageGroupFor(null), AgeGroup.adults);
  });

  test('challenge week survives a save round trip', () {
    final w = ChallengeWeek.empty()
      ..toggle(0, 2)
      ..toggle(3, 2)
      ..toggle(3, 6)
      ..success = 'Walked daily';
    final back = ChallengeWeek.fromJson(w.toJson());
    expect(back.isTicked(0, 2), isTrue);
    expect(back.doneOn(2), 2);
    expect(back.total, 3);
    expect(back.success, 'Walked daily');
    expect(
      GuideStore.weekStart(DateTime(2026, 11, 19)),
      DateTime(2026, 11, 16),
    );
  });

  // Every topic page, for every age group, at normal and large text, on a
  // small phone: no overflow or layout errors.
  for (final scale in [1.0, 1.5]) {
    testWidgets('all guide pages lay out at ${scale}x text', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final g in AgeGroup.values) {
        guideAgeGroup.value = g;
        for (final c in guideChapters) {
          for (var i = 0; i < c.topics.length; i++) {
            await tester.pumpWidget(
              _app(
                TopicScreen(chapter: c, index: i, userId: 'u1'),
                textScale: scale,
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            // Scroll through the whole page so every block is built.
            final list = find.byType(Scrollable).first;
            for (var s = 0; s < 40; s++) {
              await tester.drag(list, const Offset(0, -500));
              await tester.pump();
            }
            final error = tester.takeException();
            expect(
              error,
              isNull,
              reason:
                  '${c.number}.${i + 1} ${g.name}\n'
                  '${error is FlutterError ? error.toStringDeep() : error}',
            );
          }
        }
      }
    });
  }

  testWidgets('Guide tab lists the 6 chapters', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = Profile(
      id: '1',
      fullName: 'Test',
      age: 70,
      gender: null,
      heightCm: null,
      weightKg: null,
      preferredLanguage: AppLanguage.en,
      createdAt: DateTime(2026, 9, 1),
    );
    await tester.pumpWidget(
      _app(Scaffold(body: LearnScreen(profile: profile))),
    );
    expect(find.text(tr(AppLanguage.en, 'gd_heroTitle')), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining(en['gd_c6T']!), 300);
    expect(tester.takeException(), isNull);
  });
}
