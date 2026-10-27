import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/fib4.dart';

void main() {
  group('calculateFib4', () {
    test('known value matches manual calculation', () {
      final result = calculateFib4(age: 50, ast: 40, alt: 30, platelets: 200);
      final expected = (50 * 40) / (200 * sqrt(30));
      expect(result.score, double.parse(expected.toStringAsFixed(2)));
    });

    test('low risk tier', () {
      final result = calculateFib4(age: 30, ast: 20, alt: 30, platelets: 300);
      expect(result.score, lessThan(lowRiskCutoff));
      expect(result.tier, RiskTier.low);
    });

    test('high risk tier', () {
      final result = calculateFib4(age: 70, ast: 120, alt: 20, platelets: 80);
      expect(result.score, greaterThan(highRiskCutoff));
      expect(result.tier, RiskTier.high);
    });

    test(
      'tier uses the rounded score (2.6704 and 2.6696 show 2.67 → high)',
      () {
        // 50 × AST / (100 × √25) = AST / 10
        final a = calculateFib4(age: 50, ast: 26.704, alt: 25, platelets: 100);
        expect(a.score, 2.67);
        expect(a.tier, RiskTier.high);
        final b = calculateFib4(age: 50, ast: 26.696, alt: 25, platelets: 100);
        expect(b.score, 2.67);
        expect(b.tier, RiskTier.high);
      },
    );

    test('1.2996 shows 1.30 → intermediate, not low', () {
      final r = calculateFib4(age: 50, ast: 12.996, alt: 25, platelets: 100);
      expect(r.score, 1.30);
      expect(r.tier, RiskTier.intermediate);
    });

    test('low cut-off is 2.0 from age 65', () {
      expect(fib4Tier(1.8, 64), RiskTier.intermediate);
      expect(fib4Tier(1.8, 65), RiskTier.low);
      expect(fib4Tier(2.0, 65), RiskTier.intermediate);
      expect(fib4Tier(2.66, 40), RiskTier.intermediate);
      expect(fib4Tier(2.67, 40), RiskTier.high);
    });

    test('age out of validated range', () {
      final young = calculateFib4(age: 25, ast: 30, alt: 30, platelets: 250);
      expect(young.ageOutOfValidatedRange, isTrue);

      final midAge = calculateFib4(age: 45, ast: 30, alt: 30, platelets: 250);
      expect(midAge.ageOutOfValidatedRange, isFalse);
    });

    test('invalid inputs throw InvalidInputError', () {
      expect(
        () => calculateFib4(age: 0, ast: 30, alt: 30, platelets: 200),
        throwsA(isA<InvalidInputError>()),
      );
      expect(
        () => calculateFib4(age: 40, ast: -5, alt: 30, platelets: 200),
        throwsA(isA<InvalidInputError>()),
      );
      expect(
        () => calculateFib4(age: 40, ast: 30, alt: 0, platelets: 200),
        throwsA(isA<InvalidInputError>()),
      );
      expect(
        () => calculateFib4(age: 40, ast: 30, alt: 30, platelets: 0),
        throwsA(isA<InvalidInputError>()),
      );
    });
  });

  group('calculateBmi', () {
    test('calculates BMI correctly', () {
      final bmi = calculateBmi(heightCm: 170, weightKg: 70);
      final expected = 70 / (1.7 * 1.7);
      expect(bmi, double.parse(expected.toStringAsFixed(1)));
    });

    test('categorizes BMI using Asian thresholds', () {
      expect(bmiCategory(17.0), BmiCategory.underweight);
      expect(bmiCategory(22.0), BmiCategory.normal);
      expect(bmiCategory(24.0), BmiCategory.overweight);
      expect(bmiCategory(25.0), BmiCategory.obese);
      expect(bmiCategory(30.0), BmiCategory.obese);
    });

    test('invalid inputs throw InvalidInputError', () {
      expect(
        () => calculateBmi(heightCm: 0, weightKg: 70),
        throwsA(isA<InvalidInputError>()),
      );
      expect(
        () => calculateBmi(heightCm: 170, weightKg: -1),
        throwsA(isA<InvalidInputError>()),
      );
    });
  });
}
