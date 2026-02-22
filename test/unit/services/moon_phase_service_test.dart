import 'package:flutter_test/flutter_test.dart';
import 'package:koitai/domain/services/moon_phase_service.dart';

void main() {
  group('MoonPhaseService', () {
    group('calculateMoonAge', () {
      test('reference new moon date returns ~0 moon age', () {
        final refDate = DateTime.utc(2000, 1, 6, 18, 14, 0);
        final moonAge = MoonPhaseService.calculateMoonAge(refDate);
        expect(moonAge, closeTo(0.0, 0.01));
      });

      test('half cycle after reference returns ~14.77 days', () {
        final halfCycle = DateTime.utc(2000, 1, 6, 18, 14, 0)
            .add(Duration(hours: (MoonPhaseService.lunarCycle / 2 * 24).round()));
        final moonAge = MoonPhaseService.calculateMoonAge(halfCycle);
        expect(moonAge, closeTo(MoonPhaseService.lunarCycle / 2, 0.1));
      });

      test('one full cycle after reference returns ~0', () {
        final fullCycle = DateTime.utc(2000, 1, 6, 18, 14, 0)
            .add(Duration(hours: (MoonPhaseService.lunarCycle * 24).round()));
        final moonAge = MoonPhaseService.calculateMoonAge(fullCycle);
        expect(moonAge, closeTo(0.0, 0.1));
      });

      test('moon age is always non-negative', () {
        // Test a date before the reference
        final earlyDate = DateTime.utc(1999, 12, 1);
        final moonAge = MoonPhaseService.calculateMoonAge(earlyDate);
        expect(moonAge, greaterThanOrEqualTo(0));
        expect(moonAge, lessThan(MoonPhaseService.lunarCycle));
      });

      test('moon age for known date in 2026', () {
        final date = DateTime.utc(2026, 2, 22, 12, 0, 0);
        final moonAge = MoonPhaseService.calculateMoonAge(date);
        expect(moonAge, greaterThanOrEqualTo(0));
        expect(moonAge, lessThan(MoonPhaseService.lunarCycle));
      });
    });

    group('calculateMoonFraction', () {
      test('fraction is between 0 and 1', () {
        final fraction = MoonPhaseService.calculateMoonFraction(15.0);
        expect(fraction, greaterThanOrEqualTo(0.0));
        expect(fraction, lessThanOrEqualTo(1.0));
      });

      test('age 0 gives fraction 0', () {
        expect(MoonPhaseService.calculateMoonFraction(0.0), 0.0);
      });

      test('half cycle gives fraction ~0.5', () {
        final halfAge = MoonPhaseService.lunarCycle / 2;
        expect(MoonPhaseService.calculateMoonFraction(halfAge), closeTo(0.5, 0.001));
      });
    });

    group('getMoonPhase', () {
      test('fraction 0.0 is new moon', () {
        expect(MoonPhaseService.getMoonPhase(0.0), MoonPhase.newMoon);
      });

      test('fraction 0.01 is new moon', () {
        expect(MoonPhaseService.getMoonPhase(0.01), MoonPhase.newMoon);
      });

      test('fraction 0.1 is waxing crescent', () {
        expect(MoonPhaseService.getMoonPhase(0.1), MoonPhase.waxingCrescent);
      });

      test('fraction 0.25 is first quarter', () {
        expect(MoonPhaseService.getMoonPhase(0.25), MoonPhase.firstQuarter);
      });

      test('fraction 0.4 is waxing gibbous', () {
        expect(MoonPhaseService.getMoonPhase(0.4), MoonPhase.waxingGibbous);
      });

      test('fraction 0.5 is full moon', () {
        expect(MoonPhaseService.getMoonPhase(0.5), MoonPhase.fullMoon);
      });

      test('fraction 0.6 is waning gibbous', () {
        expect(MoonPhaseService.getMoonPhase(0.6), MoonPhase.waningGibbous);
      });

      test('fraction 0.75 is last quarter', () {
        expect(MoonPhaseService.getMoonPhase(0.75), MoonPhase.lastQuarter);
      });

      test('fraction 0.9 is waning crescent', () {
        expect(MoonPhaseService.getMoonPhase(0.9), MoonPhase.waningCrescent);
      });

      test('fraction 0.97 is new moon (end of cycle)', () {
        expect(MoonPhaseService.getMoonPhase(0.97), MoonPhase.newMoon);
      });

      test('boundary: 0.034 is waxing crescent', () {
        expect(MoonPhaseService.getMoonPhase(0.034), MoonPhase.waxingCrescent);
      });

      test('boundary: 0.966 is new moon', () {
        expect(MoonPhaseService.getMoonPhase(0.966), MoonPhase.newMoon);
      });
    });

    group('getMoonPhaseName', () {
      test('returns correct Japanese names', () {
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.newMoon), '新月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.waxingCrescent), '三日月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.firstQuarter), '上弦の月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.waxingGibbous), '十三夜月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.fullMoon), '満月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.waningGibbous), '十八夜月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.lastQuarter), '下弦の月');
        expect(MoonPhaseService.getMoonPhaseName(MoonPhase.waningCrescent), '二十六夜月');
      });
    });

    group('calculateMoonLoveScore', () {
      test('full moon fraction (0.5) gives high score', () {
        final score = MoonPhaseService.calculateMoonLoveScore(0.5);
        // mainScore=95, subScore=-15, quarterBonus=0 -> 80
        expect(score, greaterThanOrEqualTo(80));
      });

      test('new moon fraction (0.0) gives moderate score', () {
        final score = MoonPhaseService.calculateMoonLoveScore(0.0);
        // mainScore = 50 + 45*cos(2*pi*(-0.5)) = 50 + 45*(-1) = 5
        // subScore = 15 * cos(0) = 15
        // total = 20
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('first quarter range (0.25) includes bonus', () {
        final score = MoonPhaseService.calculateMoonLoveScore(0.25);
        // Should include the quarterBonus of 10
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('score is always between 0 and 100', () {
        for (double f = 0.0; f <= 1.0; f += 0.01) {
          final score = MoonPhaseService.calculateMoonLoveScore(f);
          expect(score, greaterThanOrEqualTo(0));
          expect(score, lessThanOrEqualTo(100));
        }
      });
    });

    group('applyFullMoonBonus', () {
      test('guarantees minimum 85 within 0.1 of full moon', () {
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.5), 85);
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.45), 85);
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.55), 85);
      });

      test('does not reduce scores above 85', () {
        expect(MoonPhaseService.applyFullMoonBonus(95, 0.5), 95);
      });

      test('does not apply bonus outside range', () {
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.3), 60);
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.7), 60);
      });

      test('boundary: beyond 0.1 distance does not get bonus', () {
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.61), 60);
        expect(MoonPhaseService.applyFullMoonBonus(60, 0.39), 60);
      });
    });
  });
}
