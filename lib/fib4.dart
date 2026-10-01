import 'dart:math';

/// Core FIB-4 calculation logic for the LivrCheck Flutter app.
///
/// Formula source: Sterling RK, Lissen E, Clumeck N, et al. Development of
/// a simple noninvasive index to predict significant fibrosis in patients
/// with HIV/HCV coinfection. Hepatology. 2006;43(6):1317-1325.
///
///   FIB-4 = (Age * AST) / (Platelets * sqrt(ALT))
///
/// Risk tiers:
///   < 1.30           -> low          (NPV ~90.7% for advanced fibrosis)
///   1.30 - 3.25       -> intermediate
///   > 3.25           -> high         (97% specificity for advanced fibrosis)
///
/// Validated primarily for adults aged 35-65.

const double lowRiskCutoff = 1.30;
const double highRiskCutoff = 3.25;
const int validatedAgeMin = 35;
const int validatedAgeMax = 65;

enum RiskTier { low, intermediate, high }

class InvalidInputError implements Exception {
  final String message;
  InvalidInputError(this.message);

  @override
  String toString() => message;
}

class Fib4Result {
  final double score;
  final RiskTier tier;
  final bool ageOutOfValidatedRange;

  Fib4Result({
    required this.score,
    required this.tier,
    required this.ageOutOfValidatedRange,
  });
}

Fib4Result calculateFib4({
  required double age,
  required double ast,
  required double alt,
  required double platelets,
}) {
  final values = {'age': age, 'AST': ast, 'ALT': alt, 'platelets': platelets};
  for (final entry in values.entries) {
    if (entry.value <= 0) {
      throw InvalidInputError('${entry.key} must be a positive number.');
    }
  }

  final rawScore = (age * ast) / (platelets * sqrt(alt));
  final score = double.parse(rawScore.toStringAsFixed(2));

  RiskTier tier;
  if (score < lowRiskCutoff) {
    tier = RiskTier.low;
  } else if (score <= highRiskCutoff) {
    tier = RiskTier.intermediate;
  } else {
    tier = RiskTier.high;
  }

  final ageOutOfRange = age < validatedAgeMin || age > validatedAgeMax;

  return Fib4Result(
    score: score,
    tier: tier,
    ageOutOfValidatedRange: ageOutOfRange,
  );
}

enum BmiCategory { underweight, normal, overweight, obese }

double calculateBmi({required double heightCm, required double weightKg}) {
  if (heightCm <= 0 || weightKg <= 0) {
    throw InvalidInputError('Height and weight must be positive numbers.');
  }
  final heightM = heightCm / 100;
  final bmi = weightKg / (heightM * heightM);
  return double.parse(bmi.toStringAsFixed(1));
}

/// Uses Asian-population BMI thresholds (lower than standard WHO
/// thresholds), since these populations show elevated metabolic risk at
/// lower BMI values.
BmiCategory bmiCategory(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 23.0) return BmiCategory.normal;
  if (bmi < 27.5) return BmiCategory.overweight;
  return BmiCategory.obese;
}
