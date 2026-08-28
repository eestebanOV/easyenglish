/// Constants used throughout the EasyEnglish app
class AppConstants {
  // App info
  static const String appName = 'EasyEnglish';
  static const String appVersion = '1.0.0';
  
  // SRS Algorithm constants
  // Sistema simplificado: Difícil / Normal / Fácil
  static const int maxQuality = 3;
  static const int minQuality = 1;
  
  // SRS intervals (in minutes)
  // Difícil = todos los días (24h)
  static const int intervalHard = 1440;
  // Normal = 1 día sí, 1 día no (48h)
  static const int intervalNormal = 2880;
  // Fácil = 1 vez por semana (7 días)
  static const int intervalEasy = 10080;
  
  // Daily goals
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];
  static const int defaultDailyGoal = 10;
  
  // Hive box names
  static const String cardProgressBox = 'card_progress';
  static const String userStatsBox = 'user_stats';
  static const String settingsBox = 'settings';
  static const String quizSuggestionsBox = 'quiz_suggestions';
  
  // Settings keys
  static const String keyDailyGoal = 'daily_goal';
  static const String keyDarkMode = 'dark_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyLanguage = 'language_code';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyNotificationHour = 'notification_hour';
  static const String keyNotificationMinute = 'notification_minute';
  static const String keyItemNotificationConfig = 'item_notification_config';
  static const String keyStreakDays = 'streak_days';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keyTotalReviews = 'total_reviews';
  static const String keyBestStreak = 'best_streak';
  static const String keyQuizSuggestions = 'quiz_suggestions_list';
  static const String keyQuizStats = 'quiz_stats';

  // Notification generation constants
  static const List<int> notificationIntervalOptions = [15, 30, 60, 120];
  static const int defaultNotificationInterval = 30; // minutes
  static const int notificationDefaultStartHour = 8;
  static const int notificationDefaultStartMinute = 0;
  static const int notificationDayEndHour = 23;
  static const int notificationDayEndMinute = 30;

  // Quiz size options
  static const List<int> quizSizeOptions = [5, 10, 15, 20];
  static const int defaultQuizSize = 10;
}
