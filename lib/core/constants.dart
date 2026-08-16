/// Constants used throughout the EasyEnglish app
class AppConstants {
  // App info
  static const String appName = 'EasyEnglish';
  static const String appVersion = '1.0.0';
  
  // SRS Algorithm constants (SM-2 based)
  static const double defaultEaseFactor = 2.5;
  static const double minEaseFactor = 1.3;
  static const int maxQuality = 4;
  static const int minQuality = 1;
  
  // SRS intervals (in minutes)
  static const int intervalAgain = 1;        // "Don't know" - 1 minute
  static const int intervalHard = 10;        // "Hard" - 10 minutes
  static const int intervalGood = 1440;      // "Good" - 1 day (in minutes)
  static const int intervalEasy = 4320;      // "Easy" - 3 days (in minutes)
  
  // Daily goals
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];
  static const int defaultDailyGoal = 10;
  
  // Hive box names
  static const String cardProgressBox = 'card_progress';
  static const String userStatsBox = 'user_stats';
  static const String settingsBox = 'settings';
  
  // Settings keys
  static const String keyDailyGoal = 'daily_goal';
  static const String keyDarkMode = 'dark_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyStreakDays = 'streak_days';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keyTotalCardsLearned = 'total_cards_learned';
  static const String keyTotalReviews = 'total_reviews';
  static const String keyBestStreak = 'best_streak';
}
