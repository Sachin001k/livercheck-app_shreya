import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/services/data_service.dart';
import 'package:livrcheck_app/survey/health_survey_screen.dart';
import 'package:livrcheck_app/translations.dart';

void main() {
  testWidgets('a user can tap through every question to the results',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final profile = Profile(
      id: '1', fullName: 'Test', age: 40, gender: 'male', heightCm: 170,
      weightKg: 70, preferredLanguage: AppLanguage.en, createdAt: DateTime(2026),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HealthSurveyScreen(
          profile: profile, onProfileChanged: () {}, onOpenProfile: () {},
        ),
      ),
    ));

    await tester.tap(find.text('Start my check'));
    await tester.pumpAndSettle();

    // Answer each screen: tap the first option, or press Continue.
    for (var i = 0; i < 20 && find.text('Your results').evaluate().isEmpty; i++) {
      if (find.text('No, skip this').evaluate().isNotEmpty) {
        await tester.tap(find.text('No, skip this'));
      } else if (find.textContaining('None').evaluate().isNotEmpty) {
        // Multi-select: pick "None…", then Continue.
        await tester.tap(find.textContaining('None').first);
        await tester.pump();
        await tester.tap(find.text('Continue'));
      } else if (find.text('Continue').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue').first);
      } else {
        // Single choice: the first InkWell is the Back button, so take the
        // next one, which is the first answer card.
        await tester.tap(find
            .descendant(of: find.byType(ListView), matching: find.byType(InkWell))
            .at(1));
      }
      await tester.pumpAndSettle();
    }

    // Saving fails in tests (no Supabase), but results must still show.
    expect(find.text('Your results'), findsOneWidget);
    expect(find.text('Tap an organ'), findsOneWidget);
  });
}
