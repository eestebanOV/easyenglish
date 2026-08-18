import 'package:flutter_test/flutter_test.dart';
import 'package:easyenglish/core/srs_engine.dart';
import 'package:easyenglish/core/constants.dart';

void main() {
  group('SRS Engine (Sistema Simplificado EasyEnglish)', () {
    test('Quality 1 (Difícil) = todos los días (1440 min)', () {
      final result = SrsEngine.calculateNextReview(
        quality: 1,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
      );

      expect(result.repetitions, 1);
      expect(result.interval, AppConstants.intervalHard);
      expect(result.interval, 1440);
    });

    test('Quality 2 (Normal) = 1 día sí, 1 día no (2880 min = 48h)', () {
      final result = SrsEngine.calculateNextReview(
        quality: 2,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 2,
      );

      expect(result.repetitions, 3);
      expect(result.interval, AppConstants.intervalNormal);
      expect(result.interval, 2880);
    });

    test('Quality 3 (Fácil) = 1 vez por semana (10080 min = 7 días)', () {
      final result = SrsEngine.calculateNextReview(
        quality: 3,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 5,
      );

      expect(result.repetitions, 6);
      expect(result.interval, AppConstants.intervalEasy);
      expect(result.interval, 10080);
    });

    test('nextReview fecha futura para cada nivel', () {
      final now = DateTime.now();
      final resDificil = SrsEngine.calculateNextReview(
        quality: 1, easeFactor: 2.5, interval: 0, repetitions: 0,
      );
      final resNormal = SrsEngine.calculateNextReview(
        quality: 2, easeFactor: 2.5, interval: 0, repetitions: 0,
      );
      final resFacil = SrsEngine.calculateNextReview(
        quality: 3, easeFactor: 2.5, interval: 0, repetitions: 0,
      );

      expect(resDificil.nextReview.isAfter(now), true);
      expect(resNormal.nextReview.isAfter(resDificil.nextReview), true);
      expect(resFacil.nextReview.isAfter(resNormal.nextReview), true);
    });

    test('Porcentaje de dominio crece con las repeticiones', () {
      final lowMastery = SrsEngine.getMasteryPercentage(0, 2.5);
      final midMastery = SrsEngine.getMasteryPercentage(4, 2.5);
      final highMastery = SrsEngine.getMasteryPercentage(8, 2.5);

      expect(lowMastery, 0.0);
      expect(midMastery, 50.0);
      expect(highMastery, 100.0);
    });
  });
}
