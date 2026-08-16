import 'constants.dart';

/// SM-2 based Spaced Repetition System engine.
/// 
/// Calculates the next review date for a flashcard based on the user's
/// self-assessed quality of recall.
class SrsEngine {
  /// Quality ratings:
  /// 1 = "Don't know" (Again)
  /// 2 = "Hard" (Remembered with difficulty)
  /// 3 = "Good" (Remembered correctly)
  /// 4 = "Easy" (Remembered instantly)
  
  /// Calculate the next review interval and updated ease factor.
  /// Returns a [SrsResult] with the new interval, ease factor, and repetition count.
  static SrsResult calculateNextReview({
    required int quality,
    required double easeFactor,
    required int interval,
    required int repetitions,
  }) {
    // Clamp quality to valid range
    quality = quality.clamp(AppConstants.minQuality, AppConstants.maxQuality);
    
    double newEaseFactor = easeFactor;
    int newInterval;
    int newRepetitions;
    
    if (quality < 3) {
      // Failed recall - reset repetitions and use short interval
      newRepetitions = 0;
      if (quality == 1) {
        newInterval = AppConstants.intervalAgain; // 1 minute
      } else {
        newInterval = AppConstants.intervalHard; // 10 minutes
      }
      // Decrease ease factor slightly
      newEaseFactor = easeFactor - 0.2;
    } else {
      // Successful recall
      newRepetitions = repetitions + 1;
      
      if (repetitions == 0) {
        newInterval = AppConstants.intervalGood; // 1 day
      } else if (repetitions == 1) {
        newInterval = AppConstants.intervalEasy; // 3 days
      } else {
        // Calculate next interval using ease factor
        newInterval = (interval * easeFactor).round();
      }
      
      // Adjust ease factor based on quality
      if (quality == 4) {
        newEaseFactor = easeFactor + 0.15;
      } else if (quality == 3) {
        // Keep ease factor the same
        newEaseFactor = easeFactor;
      }
    }
    
    // Ensure ease factor doesn't go below minimum
    newEaseFactor = newEaseFactor.clamp(AppConstants.minEaseFactor, 3.5);
    
    // Cap interval at 180 days (259200 minutes)
    newInterval = newInterval.clamp(1, 259200);
    
    return SrsResult(
      interval: newInterval,
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      nextReview: DateTime.now().add(Duration(minutes: newInterval)),
    );
  }
  
  /// Check if a card is due for review
  static bool isDue(DateTime? nextReview) {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview);
  }
  
  /// Get the percentage of mastery based on repetitions and ease factor
  static double getMasteryPercentage(int repetitions, double easeFactor) {
    // A card is considered "mastered" after 5+ successful reviews with high ease
    double repScore = (repetitions / 5).clamp(0.0, 1.0);
    double easeScore = ((easeFactor - AppConstants.minEaseFactor) / 
        (3.5 - AppConstants.minEaseFactor)).clamp(0.0, 1.0);
    return (repScore * 0.7 + easeScore * 0.3) * 100;
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
