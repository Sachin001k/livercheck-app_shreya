import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/app_language.dart';
import 'package:livrcheck_app/rewards/badges.dart';
import 'package:livrcheck_app/rewards/rewards_screen.dart';
import 'package:livrcheck_app/screens/profile_screen.dart';
import 'package:livrcheck_app/survey/health_ui.dart';

/// Pumps [child] in a scrolling page on a 360×640 phone at [scale] text
/// size, like a small Android phone with large text turned on.
Future<void> _pumpPhone(
  WidgetTester tester,
  Widget child, {
  required double scale,
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: LanguageScope(notifier: appLanguage, child: c!),
      ),
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [child]),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  final stats = StatGrid(
    children: const [
      StatCard(
        icon: Icons.savings,
        label: 'Coins',
        value: '12345',
        caption: 'Level 124',
        color: Colors.amber,
      ),
      StatCard(
        icon: Icons.fact_check,
        label: 'Checks done',
        value: '12',
        caption: 'health checks',
        color: Colors.teal,
      ),
      StatCard(
        icon: Icons.monitor_heart,
        label: 'Latest FIB-4',
        value: '1.23',
        caption: 'Add a blood report to see it',
        color: Colors.grey,
      ),
      StatCard(
        icon: Icons.monitor_weight,
        label: 'BMI',
        value: '24.5',
        caption: 'Overweight',
        color: Colors.purple,
      ),
    ],
  );

  final badges = BadgesGrid(
    badges: computeBadges(
      healthChecks: 1,
      scoreImproved: false,
      longestStreak: 3,
      bestDayScore: 50,
      coins: 20,
      bloodReportAdded: false,
      specialSurveysDone: 0,
    ),
  );

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('profile stat cards fit at 360 dp, ${scale}x text', (
      tester,
    ) async {
      await _pumpPhone(tester, stats, scale: scale);
      expect(tester.takeException(), isNull);
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('rewards badge grid fits at 360 dp, ${scale}x text', (
      tester,
    ) async {
      await _pumpPhone(tester, badges, scale: scale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BigButton grows for a long label at ${scale}x text', (
      tester,
    ) async {
      await _pumpPhone(
        tester,
        const BigButton(
          label: 'A rather long button label that wraps onto two lines',
          onPressed: null,
        ),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(BigButton)).height,
        greaterThanOrEqualTo(56),
      );
    });
  }
}
