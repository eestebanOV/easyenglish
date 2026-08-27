import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/card_progress.dart';
import '../models/user_stats.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box? _cardProgressBox;
  Box? _userStatsBox;
  Box? _settingsBox;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      _cardProgressBox = await Hive.openBox(AppConstants.cardProgressBox);
      _userStatsBox = await Hive.openBox(AppConstants.userStatsBox);
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);
      _isInitialized = true;
    } catch (e) {
      // Fallback if already open or in test environment
      _cardProgressBox = Hive.isBoxOpen(AppConstants.cardProgressBox) 
          ? Hive.box(AppConstants.cardProgressBox) 
          : await Hive.openBox(AppConstants.cardProgressBox);
      _userStatsBox = Hive.isBoxOpen(AppConstants.userStatsBox) 
          ? Hive.box(AppConstants.userStatsBox) 
          : await Hive.openBox(AppConstants.userStatsBox);
      _settingsBox = Hive.isBoxOpen(AppConstants.settingsBox) 
          ? Hive.box(AppConstants.settingsBox) 
          : await Hive.openBox(AppConstants.settingsBox);
      _isInitialized = true;
    }
  }

  // --- Card Progress ---
  Map<String, CardProgress> getAllCardProgress() {
    final Map<String, CardProgress> progressMap = {};
    if (_cardProgressBox == null) return progressMap;
    for (var key in _cardProgressBox!.keys) {
      final data = _cardProgressBox!.get(key);
      if (data != null && data is Map) {
        progressMap[key.toString()] = CardProgress.fromMap(data);
      }
    }
    return progressMap;
  }

  Future<void> saveCardProgress(CardProgress progress) async {
    await _cardProgressBox?.put(progress.cardId, progress.toMap());
  }

  Future<void> clearAllProgress() async {
    await _cardProgressBox?.clear();
    await _userStatsBox?.clear();
  }

  // --- User Stats ---
  UserStats getUserStats() {
    final data = _userStatsBox?.get('stats');
    if (data != null && data is Map) {
      return UserStats.fromMap(data);
    }
    return UserStats();
  }

  Future<void> saveUserStats(UserStats stats) async {
    await _userStatsBox?.put('stats', stats.toMap());
  }

  // --- Settings ---
  bool getBool(String key, {bool defaultValue = false}) {
    if (_settingsBox == null) return defaultValue;
    return _settingsBox!.get(key, defaultValue: defaultValue) as bool;
  }

  Future<void> setBool(String key, bool value) async {
    await _settingsBox?.put(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    if (_settingsBox == null) return defaultValue;
    return _settingsBox!.get(key, defaultValue: defaultValue) as int;
  }

  Future<void> setInt(String key, int value) async {
    await _settingsBox?.put(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    if (_settingsBox == null) return defaultValue;
    return _settingsBox!.get(key, defaultValue: defaultValue) as String? ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _settingsBox?.put(key, value);
  }

  Map<dynamic, dynamic>? getMap(String key) {
    if (_settingsBox == null) return null;
    final data = _settingsBox!.get(key);
    if (data is Map) {
      return data;
    }
    return null;
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _settingsBox?.put(key, value);
  }
}
