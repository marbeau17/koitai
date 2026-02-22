import 'package:flutter_test/flutter_test.dart';
import 'package:koitai/domain/services/biorhythm_service.dart';

void main() {
  group('BiorhythmService', () {
    group('daysSinceBirth', () {
      test('same day returns 0', () {
        final date = DateTime(2000, 1, 1);
        expect(BiorhythmService.daysSinceBirth(date, date), 0);
      });

      test('one day later returns 1', () {
        final birth = DateTime(2000, 1, 1);
        final target = DateTime(2000, 1, 2);
        expect(BiorhythmService.daysSinceBirth(birth, target), 1);
      });

      test('leap year handling', () {
        final birth = DateTime(2000, 1, 1);
        final target = DateTime(2000, 3, 1); // 2000 is leap year: 31+29=60
        expect(BiorhythmService.daysSinceBirth(birth, target), 60);
      });
    });

    group('calculateBiorhythm', () {
      test('birth day returns all zeros', () {
        final birth = DateTime(1990, 5, 15);
        final bio = BiorhythmService.calculateBiorhythm(birth, birth);
        expect(bio.physical, closeTo(0.0, 1e-10));
        expect(bio.emotional, closeTo(0.0, 1e-10));
        expect(bio.intellectual, closeTo(0.0, 1e-10));
      });

      test('values are between -1 and 1', () {
        final birth = DateTime(1990, 5, 15);
        for (int i = 0; i < 100; i++) {
          final target = birth.add(Duration(days: i));
          final bio = BiorhythmService.calculateBiorhythm(birth, target);
          expect(bio.physical, greaterThanOrEqualTo(-1.0));
          expect(bio.physical, lessThanOrEqualTo(1.0));
          expect(bio.emotional, greaterThanOrEqualTo(-1.0));
          expect(bio.emotional, lessThanOrEqualTo(1.0));
          expect(bio.intellectual, greaterThanOrEqualTo(-1.0));
          expect(bio.intellectual, lessThanOrEqualTo(1.0));
        }
      });

      test('physical peaks at ~5.75 days (quarter of 23-day cycle)', () {
        final birth = DateTime(1990, 5, 15);
        final peakDay = birth.add(const Duration(days: 6)); // ~quarter cycle
        final bio = BiorhythmService.calculateBiorhythm(birth, peakDay);
        // sin(2*pi*6/23) should be close to peak
        expect(bio.physical, greaterThan(0.9));
      });

      test('emotional peaks at day 7 (quarter of 28-day cycle)', () {
        final birth = DateTime(1990, 5, 15);
        final peakDay = birth.add(const Duration(days: 7));
        final bio = BiorhythmService.calculateBiorhythm(birth, peakDay);
        expect(bio.emotional, closeTo(1.0, 0.01));
      });

      test('intellectual cycle is 33 days', () {
        final birth = DateTime(1990, 5, 15);
        final fullCycle = birth.add(const Duration(days: 33));
        final bio = BiorhythmService.calculateBiorhythm(birth, fullCycle);
        expect(bio.intellectual, closeTo(0.0, 1e-10));
      });
    });

    group('calculateLoveBiorhythmScore', () {
      test('score is between 0 and 100', () {
        final birth = DateTime(1995, 12, 25);
        for (int i = 0; i < 100; i++) {
          final target = DateTime(2026, 1, 1).add(Duration(days: i));
          final score = BiorhythmService.calculateLoveBiorhythmScore(
              birth, target);
          expect(score, greaterThanOrEqualTo(0));
          expect(score, lessThanOrEqualTo(100));
        }
      });

      test('birth date returns 50 (all zeros -> composite=0 -> (0+1)/2*100=50)', () {
        final birth = DateTime(1995, 12, 25);
        final score =
            BiorhythmService.calculateLoveBiorhythmScore(birth, birth);
        expect(score, 50);
      });

      test('emotional weight is dominant (55%)', () {
        final birth = DateTime(1990, 5, 15);
        // At day 7, emotional = 1.0, physical ~ sin(2pi*7/23), intel ~ sin(2pi*7/33)
        final target = birth.add(const Duration(days: 7));
        final score =
            BiorhythmService.calculateLoveBiorhythmScore(birth, target);
        // Should be high due to emotional peak
        expect(score, greaterThan(70));
      });
    });

    group('checkCriticalDay', () {
      test('birth day is triple critical (day 0)', () {
        final birth = DateTime(1990, 5, 15);
        final info = BiorhythmService.checkCriticalDay(birth, birth);
        expect(info.isPhysicalCritical, isTrue);
        expect(info.isEmotionalCritical, isTrue);
        expect(info.isIntellectualCritical, isTrue);
        expect(info.isLoveCritical, isTrue);
        expect(info.isDoubleCritical, isTrue);
        expect(info.isTripleCritical, isTrue);
      });

      test('day 23 is physical critical only', () {
        final birth = DateTime(1990, 5, 15);
        final target = birth.add(const Duration(days: 23));
        final info = BiorhythmService.checkCriticalDay(birth, target);
        expect(info.isPhysicalCritical, isTrue);
        expect(info.isEmotionalCritical, isFalse);
        expect(info.isIntellectualCritical, isFalse);
        expect(info.isDoubleCritical, isFalse);
      });

      test('day 28 is emotional/love critical', () {
        final birth = DateTime(1990, 5, 15);
        final target = birth.add(const Duration(days: 28));
        final info = BiorhythmService.checkCriticalDay(birth, target);
        expect(info.isPhysicalCritical, isFalse);
        expect(info.isEmotionalCritical, isTrue);
        expect(info.isLoveCritical, isTrue);
      });

      test('day 33 is intellectual critical only', () {
        final birth = DateTime(1990, 5, 15);
        final target = birth.add(const Duration(days: 33));
        final info = BiorhythmService.checkCriticalDay(birth, target);
        expect(info.isPhysicalCritical, isFalse);
        expect(info.isEmotionalCritical, isFalse);
        expect(info.isIntellectualCritical, isTrue);
      });

      test('double critical: day that is multiple of 23 and 28', () {
        // LCM(23,28) = 644
        final birth = DateTime(1990, 5, 15);
        final target = birth.add(const Duration(days: 644));
        final info = BiorhythmService.checkCriticalDay(birth, target);
        expect(info.isPhysicalCritical, isTrue);
        expect(info.isEmotionalCritical, isTrue);
        expect(info.isDoubleCritical, isTrue);
      });

      test('non-critical day', () {
        final birth = DateTime(1990, 5, 15);
        final target = birth.add(const Duration(days: 10));
        final info = BiorhythmService.checkCriticalDay(birth, target);
        expect(info.isPhysicalCritical, isFalse);
        expect(info.isEmotionalCritical, isFalse);
        expect(info.isIntellectualCritical, isFalse);
        expect(info.isLoveCritical, isFalse);
        expect(info.isDoubleCritical, isFalse);
        expect(info.isTripleCritical, isFalse);
      });
    });

    group('applyCriticalDayPenalty', () {
      test('triple critical subtracts 30', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: true,
          isEmotionalCritical: true,
          isIntellectualCritical: true,
          isLoveCritical: true,
          isDoubleCritical: true,
          isTripleCritical: true,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(80, info), 50);
      });

      test('double critical subtracts 20', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: true,
          isEmotionalCritical: true,
          isIntellectualCritical: false,
          isLoveCritical: true,
          isDoubleCritical: true,
          isTripleCritical: false,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(80, info), 60);
      });

      test('love critical subtracts 15', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: false,
          isEmotionalCritical: true,
          isIntellectualCritical: false,
          isLoveCritical: true,
          isDoubleCritical: false,
          isTripleCritical: false,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(80, info), 65);
      });

      test('physical-only critical subtracts 5', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: true,
          isEmotionalCritical: false,
          isIntellectualCritical: false,
          isLoveCritical: false,
          isDoubleCritical: false,
          isTripleCritical: false,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(80, info), 75);
      });

      test('no critical returns original score', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: false,
          isEmotionalCritical: false,
          isIntellectualCritical: false,
          isLoveCritical: false,
          isDoubleCritical: false,
          isTripleCritical: false,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(80, info), 80);
      });

      test('penalty does not go below 0', () {
        final info = CriticalDayInfo(
          isPhysicalCritical: true,
          isEmotionalCritical: true,
          isIntellectualCritical: true,
          isLoveCritical: true,
          isDoubleCritical: true,
          isTripleCritical: true,
        );
        expect(BiorhythmService.applyCriticalDayPenalty(10, info), 0);
      });
    });

    group('getBiorhythmPhase', () {
      test('high values return 高潮期', () {
        expect(BiorhythmService.getBiorhythmPhase(0.8), '高潮期');
        expect(BiorhythmService.getBiorhythmPhase(1.0), '高潮期');
      });

      test('moderate positive returns 上昇期', () {
        expect(BiorhythmService.getBiorhythmPhase(0.5), '上昇期');
      });

      test('near zero returns 変動期', () {
        expect(BiorhythmService.getBiorhythmPhase(0.0), '変動期');
        expect(BiorhythmService.getBiorhythmPhase(-0.2), '変動期');
      });

      test('moderate negative returns 下降期', () {
        expect(BiorhythmService.getBiorhythmPhase(-0.5), '下降期');
      });

      test('deep negative returns 低迷期', () {
        expect(BiorhythmService.getBiorhythmPhase(-0.8), '低迷期');
        expect(BiorhythmService.getBiorhythmPhase(-1.0), '低迷期');
      });
    });
  });
}
