import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/flashcard.dart';
import 'storage_service.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// The iOS App Group ID.
  /// Needs to match the App Group configured in Apple Developer Portal and Xcode.
  static const String appGroupId = 'group.com.easyenglish.app';
  static const String iOSWidgetName = 'EasyEnglishWidget';
  static const String androidWidgetName = 'EasyEnglishWidget';

  // Storage keys
  static const String keyWordEn = 'widget_word_en';
  static const String keyWordEs = 'widget_word_es';
  static const String keyPronunciation = 'widget_pronunciation';
  static const String keyCategory = 'widget_category';
  static const String keyExamplesJson = 'widget_examples_json';
  static const String keyIntervalMinutes = 'widget_interval_minutes';
  static const String keyLastUpdated = 'widget_last_updated';
  static const String keyCardId = 'widget_active_card_id';

  // Available intervals in minutes
  static const List<int> availableIntervals = [30, 60, 120, 180]; // 30m, 1h, 2h, 3h

  bool _isInitialized = false;

  /// Initialize HomeWidget with the App Group ID
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      _isInitialized = true;
    } catch (e) {
      debugPrint('WidgetService init error: $e');
    }
  }

  /// Sets a Flashcard as the active Lock Screen / Home Screen widget item
  Future<bool> setDailyWord(
    Flashcard card, {
    int? intervalMinutes,
    List<String>? extraExamples,
  }) async {
    try {
      await init();

      final storage = StorageService();
      final effectiveInterval = intervalMinutes ?? storage.getInt('widget_interval', defaultValue: 60);

      // Collect all examples
      final List<String> allExamples = [];
      if (card.example.trim().isNotEmpty) {
        allExamples.add(card.example.trim());
      }
      if (card.extraExamples != null) {
        for (var ex in card.extraExamples!) {
          if (ex.trim().isNotEmpty && !allExamples.contains(ex.trim())) {
            allExamples.add(ex.trim());
          }
        }
      }
      if (extraExamples != null) {
        for (var ex in extraExamples) {
          if (ex.trim().isNotEmpty && !allExamples.contains(ex.trim())) {
            allExamples.add(ex.trim());
          }
        }
      }

      // If we only have 1 example, generate contextual sentence variants so timeline rotates nicely
      if (allExamples.length < 4) {
        allExamples.addAll(_generateContextualExamples(card, allExamples));
      }

      final examplesJson = jsonEncode(allExamples);
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Save to shared UserDefaults (App Group)
      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyWordEn, card.wordEn),
        HomeWidget.saveWidgetData<String>(keyWordEs, card.wordEs),
        HomeWidget.saveWidgetData<String>(keyPronunciation, card.pronunciation),
        HomeWidget.saveWidgetData<String>(keyCategory, card.categoryId),
        HomeWidget.saveWidgetData<String>(keyExamplesJson, examplesJson),
        HomeWidget.saveWidgetData<int>(keyIntervalMinutes, effectiveInterval),
        HomeWidget.saveWidgetData<int>(keyLastUpdated, nowTimestamp),
        HomeWidget.saveWidgetData<String>(keyCardId, card.id),
      ]);

      // Save locally to Hive for quick UI state
      await storage.setInt('widget_interval', effectiveInterval);
      await storage.setBool('widget_active', true);

      // Request iOS WidgetKit / Android to reload timeline
      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      debugPrint('Widget updated successfully with word: ${card.wordEn}, examples: ${allExamples.length}, interval: ${effectiveInterval}m');
      return true;
    } catch (e) {
      debugPrint('Error setting daily widget word: $e');
      return false;
    }
  }

  /// Updates only the rotation interval for the existing widget
  Future<bool> updateInterval(int minutes) async {
    try {
      await init();
      final storage = StorageService();
      await storage.setInt('widget_interval', minutes);
      await HomeWidget.saveWidgetData<int>(keyIntervalMinutes, minutes);

      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating widget interval: $e');
      return false;
    }
  }

  /// Retrieves the currently active widget data from UserDefaults
  Future<Map<String, dynamic>?> getActiveWidgetData() async {
    try {
      await init();
      final wordEn = await HomeWidget.getWidgetData<String>(keyWordEn);
      if (wordEn == null || wordEn.isEmpty) return null;

      final wordEs = await HomeWidget.getWidgetData<String>(keyWordEs) ?? '';
      final pronunciation = await HomeWidget.getWidgetData<String>(keyPronunciation) ?? '';
      final category = await HomeWidget.getWidgetData<String>(keyCategory) ?? '';
      final examplesJson = await HomeWidget.getWidgetData<String>(keyExamplesJson) ?? '[]';
      final interval = await HomeWidget.getWidgetData<int>(keyIntervalMinutes) ?? 60;
      final lastUpdated = await HomeWidget.getWidgetData<int>(keyLastUpdated) ?? 0;
      final cardId = await HomeWidget.getWidgetData<String>(keyCardId) ?? '';

      List<String> examples = [];
      try {
        final decoded = jsonDecode(examplesJson);
        if (decoded is List) {
          examples = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}

      return {
        'wordEn': wordEn,
        'wordEs': wordEs,
        'pronunciation': pronunciation,
        'category': category,
        'examples': examples,
        'interval': interval,
        'lastUpdated': lastUpdated,
        'cardId': cardId,
      };
    } catch (e) {
      debugPrint('Error getting widget data: $e');
      return null;
    }
  }

  /// Clears the widget data
  Future<void> clearWidget() async {
    try {
      await init();
      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyWordEn, ''),
        HomeWidget.saveWidgetData<String>(keyWordEs, ''),
        HomeWidget.saveWidgetData<String>(keyPronunciation, ''),
        HomeWidget.saveWidgetData<String>(keyCategory, ''),
        HomeWidget.saveWidgetData<String>(keyExamplesJson, '[]'),
        HomeWidget.saveWidgetData<String>(keyCardId, ''),
      ]);
      await StorageService().setBool('widget_active', false);
      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error clearing widget: $e');
    }
  }

  /// Helper to generate natural example sentences if the word only has 1 example
  List<String> _generateContextualExamples(Flashcard card, List<String> existing) {
    final word = card.wordEn.trim();
    final List<String> generated = [];

    // Varied sentence structures for the flashcard
    final templates = [
      'Practice saying: "$word" in your daily conversations.',
      'Remember how to use "$word" properly when speaking.',
      'Try creating your own sentence with "$word".',
      'Today\'s focus word: "$word".',
    ];

    for (var t in templates) {
      if (!existing.contains(t) && !generated.contains(t)) {
        generated.add(t);
      }
    }
    return generated;
  }
}
