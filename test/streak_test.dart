import 'package:flutter_test/flutter_test.dart';
import 'package:livrcheck_app/streak.dart';

void main() {
  final today = DateTime(2026, 9, 29);
  DateTime daysAgo(int n) => DateTime(2026, 9, 29 - n);

  group('currentStreak', () {
    test('is 0 with no activity', () {
      expect(currentStreak([], today), 0);
    });

    test('counts consecutive days ending today', () {
      expect(currentStreak([daysAgo(0), daysAgo(1), daysAgo(2)], today), 3);
    });

    test('still counts when today is not logged yet', () {
      expect(currentStreak([daysAgo(1), daysAgo(2)], today), 2);
    });

    test('stops at a gap', () {
      expect(currentStreak([daysAgo(0), daysAgo(2), daysAgo(3)], today), 1);
    });

    test('ignores time of day and duplicates', () {
      expect(
        currentStreak([
          DateTime(2026, 9, 29, 23, 59),
          DateTime(2026, 9, 29, 8),
          DateTime(2026, 9, 28, 12),
        ], today),
        2,
      );
    });

    test('crosses month boundaries', () {
      final oct1 = DateTime(2026, 10, 1);
      expect(
        currentStreak(
            [DateTime(2026, 9, 29), DateTime(2026, 9, 30), oct1], oct1),
        3,
      );
    });
  });

  group('longestStreak', () {
    test('is 0 with no activity', () {
      expect(longestStreak([]), 0);
    });

    test('finds the longest run anywhere', () {
      expect(
        longestStreak([
          daysAgo(20), daysAgo(19), daysAgo(18), daysAgo(17), // 4
          daysAgo(10), daysAgo(9), // 2
          daysAgo(0), // 1
        ]),
        4,
      );
    });
  });
}
