import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _isDarkMode = true;
  bool _soundEnabled = true;
  int _dailyGoal = AppConstants.defaultDailyGoal;
  bool _isOnboardingCompleted = false;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  int get dailyGoal => _dailyGoal;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  Future<void> init() async {
    try {
      await _storage.init();
      _isDarkMode = _storage.getBool(AppConstants.keyDarkMode, defaultValue: true);
      _soundEnabled = _storage.getBool(AppConstants.keySoundEnabled, defaultValue: true);
      _dailyGoal = _storage.getInt(AppConstants.keyDailyGoal, defaultValue: AppConstants.defaultDailyGoal);
      _isOnboardingCompleted = _storage.getBool(AppConstants.keyOnboardingComplete, defaultValue: false);
    } catch (e) {
      debugPrint('SettingsProvider init error: $e');
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _storage.setBool(AppConstants.keyDarkMode, value);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    await _storage.setBool(AppConstants.keySoundEnabled, value);
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    _dailyGoal = value;
    await _storage.setInt(AppConstants.keyDailyGoal, value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    await _storage.setBool(AppConstants.keyOnboardingComplete, true);
    notifyListeners();
  }
}
