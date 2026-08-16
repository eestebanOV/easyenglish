import 'package:flutter_test/flutter_test.dart';
import 'package:easyenglish/core/srs_engine.dart';
import 'package:easyenglish/core/constants.dart';

void main() {
  group('SRS Engine (SM-2 Algorithm)', () {
    test('Quality 1 (Don\'t know) resets repetitions and sets 1-min interval', () {
      final result = SrsEngine.calculateNextReview(
        quality: 1,
        easeFactor: 2.5,
        interval: 1440,
        repetitions: 3,
      );

      expect(result.repetitions, 0);
      expect(result.interval, AppConstants.intervalAgain);
      expect(result.easeFactor, lessThan(2.5));
    });

    test('Quality 4 (Easy) increases interval and ease factor', () {
      final result = SrsEngine.calculateNextReview(
        quality: 4,
        easeFactor: 2.5,
        interval: 1440,
        repetitions: 2,
      );

      expect(result.repetitions, 3);
      expect(result.interval, greaterThan(1440));
      expect(result.easeFactor, greaterThan(2.5));
    });

    test('Mastery percentage increases with repetitions', () {
      final lowMastery = SrsEngine.getMasteryPercentage(1, 2.5);
      final highMastery = SrsEngine.getMasteryPercentage(5, 3.0);

      expect(highMastery, greaterThan(lowMastery));
    });
  });
}
