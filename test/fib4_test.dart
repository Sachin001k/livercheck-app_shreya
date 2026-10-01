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
      expect(bmiCategory(25.0), BmiCategory.overweight);
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
