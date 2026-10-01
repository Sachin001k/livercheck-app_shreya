import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/daily/meal_catalog.dart';

void main() {
  test('totals add up calories, fruit & veg and sweets', () {
    final t = mealTotals({'roti': 3, 'dal': 1, 'sabzi': 2, 'chai': 2});
    expect(t.kcal, 3 * 100 + 150 + 2 * 120 + 2 * 80);
    expect(t.fruitVeg, 2);
    expect(t.sweets, 2);
    expect(t.items, 8);
  });

  test('unknown foods and zero counts are ignored', () {
    final t = mealTotals({'unknown_food': 4, 'rice': 0});
    expect(t.kcal, 0);
    expect(t.items, 0);
  });

  test('every food has a unique id and positive portion text', () {
    final ids = mealFoods.map((f) => f.id).toSet();
    expect(ids.length, mealFoods.length);
    expect(mealFoods.every((f) => f.portion.isNotEmpty && f.kcal >= 0), isTrue);
  });
}
