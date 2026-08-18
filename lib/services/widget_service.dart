import '../models/flashcard.dart';
import 'live_activity_service.dart';

/// Legacy facade for WidgetService that delegates to LiveActivityService
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  final LiveActivityService _liveService = LiveActivityService();

  static const String appGroupId = LiveActivityService.appGroupId;
  static const String iOSWidgetName = LiveActivityService.iOSWidgetName;
  static const String androidWidgetName = LiveActivityService.androidWidgetName;

  static const List<int> availableIntervals = LiveActivityService.availableIntervals;

  Future<void> init() => _liveService.init();

  Future<bool> setDailyWord(
    Flashcard card, {
    int? intervalMinutes,
    List<String>? extraExamples,
  }) {
    return _liveService.startDayLearning(
      card,
      intervalMinutes: intervalMinutes ?? 30,
      customExamples: extraExamples,
    );
  }

  Future<bool> updateInterval(int minutes) async {
    final active = await _liveService.getActiveState();
    if (active != null) {
      // Re-trigger with updated interval
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getActiveWidgetData() => _liveService.getActiveState();

  Future<void> clearWidget() => _liveService.stopDayLearning();
}
