import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/survey/assess.dart';

void main() {
  final healthy = <String, dynamic>{
    'sex': 'f', 'age': 28.0, 'height': 162.0, 'weight': 55.0, 'waist': 72.0,
    'activity': 'regular', 'sugar': 'rarely', 'fried': 'rarely', 'sleep': 7.5,
    'smoke': 'never', 'alcohol': 'never', 'conditions': ['none'], 'family': ['none'],
  };

  test('a healthy young adult scores well with no doctor warning', () {
    final r = assess(healthy);
    expect(r.score, greaterThanOrEqualTo(80));
    expect(r.tier, 'Thriving');
    expect(r.seeDoctor, isFalse);
    expect(r.organs.keys, containsAll(['liver', 'heart', 'kidneys', 'lungs', 'pancreas']));
    expect(r.fib4, isNull);
  });

  test('diabetes, BP and smoking give a low score and a doctor warning', () {
    final r = assess({
      ...healthy,
      'sex': 'm', 'age': 55.0, 'weight': 85.0, 'waist': 102.0, 'activity': 'sit',
      'sugar': 'daily', 'smoke': 'current', 'conditions': ['diabetes', 'bp'],
    });
    expect(r.score, lessThan(40));
    expect(r.seeDoctor, isTrue);
    expect(r.organs['liver']!.level, 'high');
    expect(r.organs['lungs']!.level, 'high');
  });

  test('FIB-4 is calculated from lab values, with lakh platelets converted', () {
    final r = assess({
      ...healthy,
      'age': 50.0,
      'labs': {'ast': 40.0, 'alt': 30.0, 'plt': 2.0, 'unit': 'lakh'},
    });
    // (50 × 40) / (200 × √30) = 1.83 → grey zone.
    expect(r.fib4, closeTo(1.83, 0.01));
    expect(r.organs['liver']!.level, 'mod');
    expect(r.tests, contains('FibroScan'));
  });

  test('missing waist is estimated', () {
    final r = assess({...healthy, 'waist': null});
    expect(r.waistEstimated, isTrue);
  });

  test('results survive a JSON round trip (as stored in Supabase)', () {
    final r = assess({
      ...healthy,
      'labs': {'ast': 40.0, 'alt': 30.0, 'plt': 250000.0, 'unit': 'ul'},
    });
    final back = AssessmentResult.fromJson(r.toJson());
    expect(back.score, r.score);
    expect(back.tier, r.tier);
    expect(back.fib4, r.fib4);
    expect(back.organs['liver']!.reasons, r.organs['liver']!.reasons);
    expect(back.plan.move.length, r.plan.move.length);
  });

  test('platelet units convert to ×10⁹/L', () {
    expect(plateletsToG(2.5, 'lakh'), 250);
    expect(plateletsToG(250000, 'ul'), 250);
    expect(plateletsToG(250, 'g'), 250);
  });
}
