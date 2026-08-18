import 'constants.dart';

/// Sistema de Repetición Simplificado EasyEnglish
///
/// 3 niveles directos sin complejidad:
///   1 = Difícil  -> todos los días (24h)
///   2 = Normal   -> 1 día sí, 1 día no (48h)
///   3 = Fácil    -> 1 vez por semana (7 días)
///
/// La tarjeta se repite con la misma frecuencia hasta que el usuario
/// cambie su calificación.
class SrsEngine {
  /// Calculate the next review date based on the user's rating.
  static SrsResult calculateNextReview({
    required int quality,
    required double easeFactor,
    required int interval,
    required int repetitions,
  }) {
    // Asegurar rango válido 1..3
    quality = quality.clamp(AppConstants.minQuality, AppConstants.maxQuality);

    int newInterval;
    int newRepetitions = repetitions + 1;

    switch (quality) {
      case 1:
        // Difícil: todos los días (24h / 1440 minutos)
        newInterval = AppConstants.intervalHard;
        break;
      case 2:
        // Normal: un día sí, otro no (48h / 2880 minutos)
        newInterval = AppConstants.intervalNormal;
        break;
      case 3:
      default:
        // Fácil: 1 vez a la semana (7 días / 10080 minutos)
        newInterval = AppConstants.intervalEasy;
        break;
    }

    // Cap intervalo en 180 días (259200 minutos)
    newInterval = newInterval.clamp(1, 259200);

    return SrsResult(
      interval: newInterval,
      easeFactor: 2.5, // Valor fijo para mantener compatibilidad
      repetitions: newRepetitions,
      nextReview: DateTime.now().add(Duration(minutes: newInterval)),
    );
  }

  /// Check if a card is due for review
  static bool isDue(DateTime? nextReview) {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview);
  }

  /// Porcentaje de dominio basado en repeticiones completadas
  static double getMasteryPercentage(int repetitions, double easeFactor) {
    // 8+ repeticiones = 100% de dominio
    return (repetitions / 8).clamp(0.0, 1.0) * 100;
  }
}

/// Result of an SRS calculation
class SrsResult {
  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReview;

  const SrsResult({
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReview,
  });
}
