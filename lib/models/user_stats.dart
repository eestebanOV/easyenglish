/// Model representing user learning stats and streak
class UserStats {
  int totalCardsLearned;
  int streakDays;
  int bestStreak;
  int totalReviews;
  DateTime? lastStudyDate;
  int dailyGoal;
  int reviewsToday;

  UserStats({
    this.totalCardsLearned = 0,
    this.streakDays = 0,
    this.bestStreak = 0,
    this.totalReviews = 0,
    this.lastStudyDate,
    this.dailyGoal = 10,
    this.reviewsToday = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalCardsLearned': totalCardsLearned,
      'streakDays': streakDays,
      'bestStreak': bestStreak,
      'totalReviews': totalReviews,
      'lastStudyDate': lastStudyDate?.millisecondsSinceEpoch,
      'dailyGoal': dailyGoal,
      'reviewsToday': reviewsToday,
    };
  }

  factory UserStats.fromMap(Map<dynamic, dynamic> map) {
    return UserStats(
      totalCardsLearned: (map['totalCardsLearned'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      lastStudyDate: map['lastStudyDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastStudyDate'] as int)
          : null,
      dailyGoal: (map['dailyGoal'] as num?)?.toInt() ?? 10,
      reviewsToday: (map['reviewsToday'] as num?)?.toInt() ?? 0,
    );
  }
}
