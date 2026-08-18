/// Model representing the learning progress of a single flashcard
class CardProgress {
  final String cardId;
  double easeFactor;
  int interval; // in minutes
  int repetitions;
  DateTime? nextReview;
  DateTime? lastReview;

  CardProgress({
    required this.cardId,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReview,
    this.lastReview,
  });

  /// Whether this card has never been studied
  bool get isNew => lastReview == null;

  /// Whether this card is due for review
  bool get isDue {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!);
  }

  /// Convert to map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'nextReview': nextReview?.millisecondsSinceEpoch,
      'lastReview': lastReview?.millisecondsSinceEpoch,
    };
  }

  /// Create from Hive storage map
  factory CardProgress.fromMap(Map<dynamic, dynamic> map) {
    return CardProgress(
      cardId: map['cardId'] as String,
      easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (map['interval'] as num?)?.toInt() ?? 0,
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 0,
      nextReview: map['nextReview'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextReview'] as int)
          : null,
      lastReview: map['lastReview'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReview'] as int)
          : null,
    );
  }
}
