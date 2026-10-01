import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/app_language.dart';
import 'package:livrcheck_app/data/home_content.dart';
import 'package:livrcheck_app/screens/food_detail_sheet.dart';
import 'package:livrcheck_app/screens/home_screen.dart';
import 'package:livrcheck_app/services/data_service.dart';
import 'package:livrcheck_app/translations.dart';

void main() {
  testWidgets('tapping a food card opens its details pop-up', (tester) async {
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

    expect(find.text('View details'), findsWidgets);
    await tester.tap(find.text('Leafy greens'));
    // The home cards animate forever, so wait a fixed time instead of
    // pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('How much is safe per day'), findsOneWidget);
  });

  testWidgets('every food has a complete pop-up that lays out cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            LanguageScope(notifier: appLanguage, child: child!),
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold();
          },
        ),
      ),
    );

    for (final tip in foodTips) {
      expect(tip.detail, isNotNull, reason: '${tip.name} has no details');
      showFoodDetail(ctx, tip);
      await tester.pumpAndSettle();
      expect(find.text(tip.name), findsOneWidget);
      expect(find.text('Nutrition'), findsOneWidget);
      if (!tip.recommended) {
        await tester.scrollUntilVisible(
          find.text('Healthier swaps'),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(
          find.text('Healthier swaps'),
          findsOneWidget,
          reason: '${tip.name} should suggest swaps',
        );
      }
      Navigator.of(ctx).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('home works with large phone text (no overflow)', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final profile = Profile(
      id: '1', fullName: 'Test User', age: 40, gender: null, heightCm: null,
      weightKg: null, preferredLanguage: AppLanguage.en, createdAt: DateTime(2026, 9, 1),
    );
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5)),
        child: LanguageScope(notifier: appLanguage, child: child!),
      ),
      home: Scaffold(body: HomeScreen(profile: profile, onStartCheck: () {})),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('Check your liver risk'), findsOneWidget);
  });
}
