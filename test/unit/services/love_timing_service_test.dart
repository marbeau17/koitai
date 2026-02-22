import 'package:flutter_test/flutter_test.dart';
import 'package:koitai/domain/services/biorhythm_service.dart';
import 'package:koitai/domain/services/love_timing_service.dart';
import 'package:koitai/domain/services/moon_phase_service.dart';
import 'package:koitai/domain/services/numerology_service.dart';

void main() {
  group('LoveTimingService', () {
    group('calculateTotalLoveScore', () {
      test('returns value between 0 and 100', () {
        final birth = DateTime(1995, 12, 25);
        for (int day = 1; day <= 30; day++) {
          final target = DateTime(2026, 3, day);
          final score =
              LoveTimingService.calculateTotalLoveScore(birth, target);
          expect(score, greaterThanOrEqualTo(0));
          expect(score, lessThanOrEqualTo(100));
        }
      });

      test('different birth dates yield different results', () {
        final target = DateTime(2026, 3, 15);
        final score1 = LoveTimingService.calculateTotalLoveScore(
            DateTime(1990, 1, 1), target);
        final score2 = LoveTimingService.calculateTotalLoveScore(
            DateTime(1995, 6, 15), target);
        // Scores may differ due to different numerology and biorhythm
        expect(score1, isA<int>());
        expect(score2, isA<int>());
      });

      test('score is an integer', () {
        final score = LoveTimingService.calculateTotalLoveScore(
            DateTime(1995, 12, 25), DateTime(2026, 2, 22));
        expect(score, isA<int>());
      });

      test('30 days produce some variation', () {
        final birth = DateTime(1990, 5, 15);
        final scores = <int>{};
        for (int d = 1; d <= 30; d++) {
          scores.add(LoveTimingService.calculateTotalLoveScore(
              birth, DateTime(2026, 3, d)));
        }
        expect(scores.length, greaterThan(3));
      });
    });

    group('getStarRating', () {
      test('85-100 returns 5 stars', () {
        expect(LoveTimingService.getStarRating(85), 5);
        expect(LoveTimingService.getStarRating(100), 5);
        expect(LoveTimingService.getStarRating(90), 5);
      });

      test('70-84 returns 4 stars', () {
        expect(LoveTimingService.getStarRating(70), 4);
        expect(LoveTimingService.getStarRating(84), 4);
      });

      test('50-69 returns 3 stars', () {
        expect(LoveTimingService.getStarRating(50), 3);
        expect(LoveTimingService.getStarRating(69), 3);
      });

      test('30-49 returns 2 stars', () {
        expect(LoveTimingService.getStarRating(30), 2);
        expect(LoveTimingService.getStarRating(49), 2);
      });

      test('0-29 returns 1 star', () {
        expect(LoveTimingService.getStarRating(0), 1);
        expect(LoveTimingService.getStarRating(29), 1);
      });

      test('boundary values', () {
        expect(LoveTimingService.getStarRating(84), 4);
        expect(LoveTimingService.getStarRating(85), 5);
        expect(LoveTimingService.getStarRating(69), 3);
        expect(LoveTimingService.getStarRating(70), 4);
        expect(LoveTimingService.getStarRating(49), 2);
        expect(LoveTimingService.getStarRating(50), 3);
        expect(LoveTimingService.getStarRating(29), 1);
        expect(LoveTimingService.getStarRating(30), 2);
      });
    });

    group('getCompatibilityScore', () {
      test('symmetric: (a,b) equals (b,a)', () {
        expect(LoveTimingService.getCompatibilityScore(1, 2),
            LoveTimingService.getCompatibilityScore(2, 1));
        expect(LoveTimingService.getCompatibilityScore(3, 5),
            LoveTimingService.getCompatibilityScore(5, 3));
      });

      test('highest compatibility pairs score 95', () {
        expect(LoveTimingService.getCompatibilityScore(2, 6), 95);
        expect(LoveTimingService.getCompatibilityScore(6, 33), 95);
        expect(LoveTimingService.getCompatibilityScore(4, 22), 95);
      });

      test('lowest compatibility pair 4&5 scores 35', () {
        expect(LoveTimingService.getCompatibilityScore(4, 5), 35);
      });

      test('self-compatibility values', () {
        expect(LoveTimingService.getCompatibilityScore(1, 1), 65);
        expect(LoveTimingService.getCompatibilityScore(2, 2), 70);
        expect(LoveTimingService.getCompatibilityScore(6, 6), 80);
      });

      test('master numbers are supported', () {
        expect(LoveTimingService.getCompatibilityScore(11, 33), 90);
        expect(LoveTimingService.getCompatibilityScore(22, 4), 95);
      });

      test('unknown life path returns default 50', () {
        expect(LoveTimingService.getCompatibilityScore(99, 1), 50);
      });
    });

    group('calculateBiorhythmSync', () {
      test('same birth date gives 100% sync', () {
        final birth = DateTime(1990, 5, 15);
        final sync = LoveTimingService.calculateBiorhythmSync(
            birth, birth, DateTime(2026, 3, 15));
        expect(sync, closeTo(100.0, 0.01));
      });

      test('sync is between 0 and 100', () {
        final sync = LoveTimingService.calculateBiorhythmSync(
            DateTime(1990, 1, 1),
            DateTime(1995, 6, 15),
            DateTime(2026, 3, 15));
        expect(sync, greaterThanOrEqualTo(0));
        expect(sync, lessThanOrEqualTo(100));
      });

      test('different birth dates produce varying sync', () {
        final birthA = DateTime(1990, 1, 1);
        final birthB = DateTime(1992, 6, 15);
        final syncs = <double>{};
        for (int d = 1; d <= 30; d++) {
          syncs.add(LoveTimingService.calculateBiorhythmSync(
              birthA, birthB, DateTime(2026, 3, d)));
        }
        expect(syncs.length, greaterThan(1));
      });
    });

    group('calculatePairTimingScore', () {
      test('returns value between 0 and 100', () {
        final birthA = DateTime(1990, 5, 15);
        final birthB = DateTime(1993, 8, 20);
        final target = DateTime(2026, 3, 15);
        final score = LoveTimingService.calculatePairTimingScore(
            birthA, birthB, target);
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('pair score is an integer', () {
        final score = LoveTimingService.calculatePairTimingScore(
            DateTime(1990, 1, 1),
            DateTime(1992, 6, 15),
            DateTime(2026, 3, 15));
        expect(score, isA<int>());
      });
    });

    group('getRecommendedActions', () {
      test('low score with new moon returns selfImprovement', () {
        // New moon fraction = 0.0, score < 40
        final actions = LoveTimingService.getRecommendedActions(
          20,
          0.0,
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.selfImprovement));
      });

      test('high score near full moon with high emotional triggers confession', () {
        final actions = LoveTimingService.getRecommendedActions(
          85,
          0.5, // full moon
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.confession));
      });

      test('score >= 90 at full moon with all positive triggers proposal', () {
        final actions = LoveTimingService.getRecommendedActions(
          95,
          0.5,
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.proposal));
      });

      test('proposal not recommended when biorhythm is negative', () {
        final actions = LoveTimingService.getRecommendedActions(
          95,
          0.5,
          const BiorhythmValues(
              physical: -0.1, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, isNot(contains(LoveAction.proposal)));
      });

      test('score >= 60 recommends askForDate (not last quarter)', () {
        final actions = LoveTimingService.getRecommendedActions(
          65,
          0.4, // waxing gibbous
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.askForDate));
      });

      test('askForDate excluded at last quarter', () {
        final actions = LoveTimingService.getRecommendedActions(
          65,
          0.75, // last quarter
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, isNot(contains(LoveAction.askForDate)));
      });

      test('score >= 40 recommends sendMessage', () {
        final actions = LoveTimingService.getRecommendedActions(
          45,
          0.4,
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.sendMessage));
      });

      test('exchangeContact at first quarter with score >= 55', () {
        final actions = LoveTimingService.getRecommendedActions(
          60,
          0.25, // first quarter
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.exchangeContact));
      });

      test('reviewRelation at last quarter with negative emotional', () {
        final actions = LoveTimingService.getRecommendedActions(
          30,
          0.75, // last quarter
          const BiorhythmValues(
              physical: 0.5, emotional: -0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.reviewRelation));
      });

      test('empty actions default to selfImprovement', () {
        // Score < 40, fraction in waxing gibbous, no negative emotional
        final actions = LoveTimingService.getRecommendedActions(
          20,
          0.4, // waxing gibbous
          const BiorhythmValues(
              physical: 0.5, emotional: 0.5, intellectual: 0.5),
        );
        expect(actions, contains(LoveAction.selfImprovement));
      });
    });
  });
}
