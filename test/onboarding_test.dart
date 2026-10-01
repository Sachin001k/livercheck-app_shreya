import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/app_language.dart';
import 'package:livrcheck_app/onboarding/consent_screen.dart';
import 'package:livrcheck_app/onboarding/welcome_screen.dart';

Widget _app(Widget home) => MaterialApp(
      builder: (context, child) => LanguageScope(notifier: appLanguage, child: child!),
      home: home,
    );

void main() {
  testWidgets('welcome slides: Next through all four, then Get started', (tester) async {
    var done = false;
    await tester.pumpWidget(_app(WelcomeScreen(onDone: () => done = true)));
    expect(find.text('Know your liver'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      // Let the page slide finish (the emoji keeps floating, so no settle).
      for (var f = 0; f < 10; f++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    expect(find.text('Your data stays yours'), findsOneWidget);
    expect(done, isFalse);

    await tester.tap(find.text('Get started'));
    expect(done, isTrue);
  });

  testWidgets('consent: Agree stays disabled until both boxes are ticked', (tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(ConsentScreen(onAccepted: () {})));
    FilledButton agree() => tester.widget<FilledButton>(find.byType(FilledButton));

    expect(agree().onPressed, isNull);
    final boxes = find.byType(CheckboxListTile);
    expect(boxes, findsNWidgets(2));
    await tester.tap(boxes.at(0));
    await tester.pump();
    expect(agree().onPressed, isNull);
    await tester.tap(boxes.at(1));
    await tester.pump();
    expect(agree().onPressed, isNotNull);
  });
}
