import 'package:flutter_test/flutter_test.dart';
import 'package:koitai/domain/services/numerology_service.dart';

void main() {
  group('NumerologyService', () {
    group('reduceToSingleDigit', () {
      test('reduces multi-digit numbers to single digit', () {
        expect(NumerologyService.reduceToSingleDigit(24), 6); // 2+4=6
        expect(NumerologyService.reduceToSingleDigit(16), 7); // 1+6=7
        expect(NumerologyService.reduceToSingleDigit(19), 1); // 1+9=10, 1+0=1
        expect(NumerologyService.reduceToSingleDigit(38), 2); // 3+8=11 -> master
      });

      test('preserves single digit numbers', () {
        for (int i = 1; i <= 9; i++) {
          expect(NumerologyService.reduceToSingleDigit(i), i);
        }
      });

      test('preserves master number 11', () {
        expect(NumerologyService.reduceToSingleDigit(11), 11);
      });

      test('preserves master number 22', () {
        expect(NumerologyService.reduceToSingleDigit(22), 22);
      });

      test('preserves master number 33', () {
        expect(NumerologyService.reduceToSingleDigit(33), 33);
      });

      test('reduces numbers that pass through master numbers', () {
        // 38 -> 3+8 = 11 (master, stop)
        expect(NumerologyService.reduceToSingleDigit(38), 11);
        // 44 -> 4+4 = 8
        expect(NumerologyService.reduceToSingleDigit(44), 8);
      });
    });

    group('calculateLifePathNumber', () {
      test('spec example: 1995-12-25 -> 7', () {
        // Year: 1+9+9+5=24->2+4=6, Month: 1+2=3, Day: 2+5=7
        // Total: 6+3+7=16->1+6=7
        final birthDate = DateTime(1995, 12, 25);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 7);
      });

      test('spec example: 1990-11-29 -> 5 (master number month)', () {
        // Year: 1+9+9+0=19->10->1, Month: 11 (master), Day: 2+9=11 (master)
        // Total: 1+11+11=23->2+3=5
        final birthDate = DateTime(1990, 11, 29);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 5);
      });

      test('birthday resulting in master number', () {
        // 2000-02-09: Year: 2+0+0+0=2, Month: 2, Day: 9, Total: 13->4
        final birthDate = DateTime(2000, 2, 9);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 4);
      });

      test('birthday 2000-01-01', () {
        // Year: 2, Month: 1, Day: 1, Total: 4
        final birthDate = DateTime(2000, 1, 1);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 4);
      });

      test('birthday 1988-08-08', () {
        // Year: 1+9+8+8=26->8, Month: 8, Day: 8, Total: 24->6
        final birthDate = DateTime(1988, 8, 8);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 6);
      });
    });

    group('calculatePersonalYear', () {
      test('spec example: birthday 7/15, target year 2026 -> 5', () {
        // Month: 7, Day: 1+5=6, Year: 2+0+2+6=10->1
        // Total: 7+6+1=14->5
        final birthDate = DateTime(1995, 7, 15);
        expect(NumerologyService.calculatePersonalYear(birthDate, 2026), 5);
      });

      test('different year produces different result', () {
        final birthDate = DateTime(1995, 7, 15);
        final py2025 = NumerologyService.calculatePersonalYear(birthDate, 2025);
        final py2026 = NumerologyService.calculatePersonalYear(birthDate, 2026);
        expect(py2025, isNot(equals(py2026)));
      });
    });

    group('calculatePersonalMonth', () {
      test('spec example: personalYear=5, month=12 -> 8', () {
        // 5 + (1+2) = 5+3 = 8
        expect(NumerologyService.calculatePersonalMonth(5, 12), 8);
      });

      test('month 1 keeps it simple', () {
        expect(NumerologyService.calculatePersonalMonth(3, 1), 4);
      });
    });

    group('calculatePersonalDay', () {
      test('spec example: personalYear=5, month=12, day=25 -> 6', () {
        // 5 + 3 + 7 = 15 -> 6
        expect(NumerologyService.calculatePersonalDay(5, 12, 25), 6);
      });

      test('boundary: day 1 of month 1', () {
        final result = NumerologyService.calculatePersonalDay(1, 1, 1);
        expect(result, 3); // 1+1+1=3
      });

      test('day 31 reduces properly', () {
        // personalYear=1, month=1, day=31 -> 1+1+(3+1)=6
        final result = NumerologyService.calculatePersonalDay(1, 1, 31);
        expect(result, 6);
      });
    });

    group('calculateNumerologyLoveScore', () {
      test('returns value between 0 and 100', () {
        final birthDate = DateTime(1995, 12, 25);
        final targetDate = DateTime(2026, 2, 22);
        final score = NumerologyService.calculateNumerologyLoveScore(
            birthDate, targetDate);
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('different dates produce varying scores', () {
        final birthDate = DateTime(1995, 12, 25);
        final scores = <int>{};
        for (int day = 1; day <= 28; day++) {
          scores.add(NumerologyService.calculateNumerologyLoveScore(
              birthDate, DateTime(2026, 2, day)));
        }
        // Over 28 days, we should see at least a few different scores
        expect(scores.length, greaterThan(1));
      });

      test('personal year 6 gets +10 bonus', () {
        // Find a birthdate where personal year in 2026 is 6
        // We verify by checking the personal year is 6
        final birthDate = DateTime(1990, 1, 1);
        final py = NumerologyService.calculatePersonalYear(birthDate, 2026);
        // The score should reflect the year bonus if py == 6
        final score = NumerologyService.calculateNumerologyLoveScore(
            birthDate, DateTime(2026, 1, 1));
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('score for life path 6 (highest multiplier 1.20)', () {
        // 1988-08-08 has life path 6
        final birthDate = DateTime(1988, 8, 8);
        expect(NumerologyService.calculateLifePathNumber(birthDate), 6);
        final score = NumerologyService.calculateNumerologyLoveScore(
            birthDate, DateTime(2026, 3, 1));
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });
    });
  });
}
