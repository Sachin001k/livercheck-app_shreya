import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/daily/daily_store.dart';

void main() {
  test('coins without a day (special surveys) count in the total only', () {
    final r = sumCoins([
      {'day': '2026-10-01', 'amount': 1},
      {'day': '2026-10-01', 'amount': 10},
      {'day': null, 'amount': 50}, // special survey
      {'day': '2026-09-30', 'amount': 1},
    ]);
    expect(r.total, 62);
    expect(r.byDay, {'2026-10-01': 11, '2026-09-30': 1});
  });
}
