import 'dart:math';

/// Core FIB-4 calculation logic for the LivrCheck Flutter app.
///
/// Formula source: Sterling RK, Lissen E, Clumeck N, et al. Development of
/// a simple noninvasive index to predict significant fibrosis in patients
/// with HIV/HCV coinfection. Hepatology. 2006;43(6):1317-1325.
///
///   FIB-4 = (Age * AST) / (Platelets * sqrt(ALT))
///
/// The score is rounded once to 2 decimals and that rounded value is used
/// for the tier, the display and storage, so they always agree.
///
/// Risk tiers (standard NAFLD cut-offs, same as the health check):
///   < 1.30 (< 2.0 at age 65+)  -> low
///   up to 2.67                 -> intermediate
///   >= 2.67                    -> high
///
/// Validated primarily for adults aged 35-65.

const double lowRiskCutoff = 1.30;
const double lowRiskCutoffAge65 = 2.0;
const double highRiskCutoff = 2.67;
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

  final score = roundFib4((age * ast) / (platelets * sqrt(alt)));
  final tier = fib4Tier(score, age);

  final ageOutOfRange = age < validatedAgeMin || age > validatedAgeMax;

  return Fib4Result(
    score: score,
    tier: tier,
    ageOutOfValidatedRange: ageOutOfRange,
  );
}

/// Rounds a raw FIB-4 value to 2 decimals (done once, before any cut-off).
double roundFib4(double raw) => double.parse(raw.toStringAsFixed(2));

/// Tier for an already rounded FIB-4 [score]. The low cut-off is 2.0 from
/// age 65.
RiskTier fib4Tier(double score, double age) {
  final lowCut = age >= 65 ? lowRiskCutoffAge65 : lowRiskCutoff;
  if (score >= highRiskCutoff) return RiskTier.high;
  if (score >= lowCut) return RiskTier.intermediate;
  return RiskTier.low;
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
/// lower BMI values: 23 overweight, 25 obese (same as the health check).
BmiCategory bmiCategory(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 23.0) return BmiCategory.normal;
  if (bmi < 25.0) return BmiCategory.overweight;
  return BmiCategory.obese;
}
