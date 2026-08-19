import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../models/flashcard.dart';
import 'storage_service.dart';

class LiveActivityService {
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  static const MethodChannel _channel = MethodChannel('com.easyenglish.app/live_activities');
  static const String appGroupId = 'group.com.easyenglish.app';
  static const String iOSWidgetName = 'EasyEnglishWidget';
  static const String androidWidgetName = 'EasyEnglishWidget';

  // Available intervals in minutes
  static const List<int> availableIntervals = [15, 30, 45, 60, 120];

  bool _isInitialized = false;

  /// Initialize HomeWidget and channels
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      _isInitialized = true;
    } catch (e) {
      debugPrint('LiveActivityService init error: $e');
    }
  }

  /// Sets a Flashcard as the active Daily Learning Item for Live Activities
  Future<bool> startDayLearning(
    Flashcard card, {
    int startHour = 8,
    int endHour = 22,
    int intervalMinutes = 30,
    int durationMinutes = 5,
    List<String>? customExamples,
  }) async {
    try {
      await init();
      final storage = StorageService();

      // Collect all available examples from card and generate diverse ones if needed
      final List<String> allExamples = [];
      if (customExamples != null && customExamples.isNotEmpty) {
        allExamples.addAll(customExamples);
      } else {
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
      }

      // Ensure we have plenty of distinct, contextual examples for a full day (at least 6-8)
      if (allExamples.length < 6) {
        allExamples.addAll(_generateContextualExamples(card, allExamples));
      }

      final wordType = _determineWordType(card);
      final examplesJson = jsonEncode(allExamples);

      // Save to shared UserDefaults (App Group) via HomeWidget for WidgetKit fallback
      await Future.wait([
        HomeWidget.saveWidgetData<String>('live_activity_word_en', card.wordEn),
        HomeWidget.saveWidgetData<String>('live_activity_word_es', card.wordEs),
        HomeWidget.saveWidgetData<String>('live_activity_pronunciation', card.pronunciation),
        HomeWidget.saveWidgetData<String>('live_activity_type', wordType),
        HomeWidget.saveWidgetData<String>('live_activity_category', card.categoryId),
        HomeWidget.saveWidgetData<String>('live_activity_examples_json', examplesJson),
        HomeWidget.saveWidgetData<int>('live_activity_start_hour', startHour),
        HomeWidget.saveWidgetData<int>('live_activity_end_hour', endHour),
        HomeWidget.saveWidgetData<int>('live_activity_interval_minutes', intervalMinutes),
        HomeWidget.saveWidgetData<int>('live_activity_duration_minutes', durationMinutes),
        HomeWidget.saveWidgetData<String>('live_activity_card_id', card.id),
      ]);

      // Save locally to Hive for quick app state
      await storage.setBool('live_activity_active', true);
      await storage.setString('live_activity_word_en', card.wordEn);
      await storage.setString('live_activity_word_es', card.wordEs);
      await storage.setString('live_activity_card_id', card.id);
      await storage.setInt('live_activity_interval', intervalMinutes);
      await storage.setInt('live_activity_start_hour', startHour);
      await storage.setInt('live_activity_end_hour', endHour);

      // Invoke native iOS ActivityKit via MethodChannel
      try {
        final Map<String, dynamic> params = {
          'learningItem': card.wordEn,
          'type': wordType,
          'translation': card.wordEs,
          'phonetic': card.pronunciation,
          'examples': allExamples,
          'verbPresent': card.present,
          'verbPast': card.past,
          'verbParticiple': card.participle,
          'categoryName': card.categoryId,
          'startHour': startHour,
          'endHour': endHour,
          'intervalMinutes': intervalMinutes,
          'durationMinutes': durationMinutes,
          'cardId': card.id,
        };

        final result = await _channel.invokeMethod('startDayLearning', params);
        debugPrint('Native LiveActivity startDayLearning result: $result');
      } on MissingPluginException {
        debugPrint('Native LiveActivity method channel not available (running on simulator/web/android)');
      } catch (e) {
        debugPrint('Native LiveActivity invoke error: $e');
      }

      // Also trigger widget timeline update
      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      return true;
    } catch (e) {
      debugPrint('Error starting day live activity: $e');
      return false;
    }
  }

  /// Triggers an immediate 5-minute Live Activity session
  Future<bool> startSessionNow({int? exampleIndex}) async {
    try {
      await init();
      final result = await _channel.invokeMethod('startSessionNow', {
        'exampleIndex': exampleIndex,
      });
      return result?['success'] == true;
    } catch (e) {
      debugPrint('Error starting immediate Live Activity session: $e');
      return false;
    }
  }

  /// Ends the currently active Live Activity banner
  Future<void> endCurrentActivity() async {
    try {
      await init();
      await _channel.invokeMethod('endCurrentActivity');
    } catch (e) {
      debugPrint('Error ending Live Activity: $e');
    }
  }

  /// Cancels all Live Activities for the day and clears schedule
  Future<void> stopDayLearning() async {
    try {
      await init();
      await _channel.invokeMethod('stopDayLearning');
    } catch (_) {}

    final storage = StorageService();
    await storage.setBool('live_activity_active', false);
    await storage.setString('live_activity_word_en', '');
    await storage.setString('live_activity_card_id', '');

    await Future.wait([
      HomeWidget.saveWidgetData<String>('live_activity_word_en', ''),
      HomeWidget.saveWidgetData<String>('live_activity_word_es', ''),
      HomeWidget.saveWidgetData<String>('live_activity_pronunciation', ''),
      HomeWidget.saveWidgetData<String>('live_activity_examples_json', '[]'),
      HomeWidget.saveWidgetData<String>('live_activity_card_id', ''),
    ]);

    await HomeWidget.updateWidget(
      name: iOSWidgetName,
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }

  /// Retrieves active Live Activity information
  Future<Map<String, dynamic>?> getActiveState() async {
    try {
      await init();
      try {
        final res = await _channel.invokeMapMethod<String, dynamic>('getActiveState');
        if (res != null && res['wordEn'] != null && (res['wordEn'] as String).isNotEmpty) {
          return res;
        }
      } catch (_) {}

      // Fallback from UserDefaults / Storage
      final wordEn = await HomeWidget.getWidgetData<String>('live_activity_word_en');
      if (wordEn == null || wordEn.isEmpty) return null;

      final wordEs = await HomeWidget.getWidgetData<String>('live_activity_word_es') ?? '';
      final phonetic = await HomeWidget.getWidgetData<String>('live_activity_pronunciation') ?? '';
      final type = await HomeWidget.getWidgetData<String>('live_activity_type') ?? 'PHRASE';
      final category = await HomeWidget.getWidgetData<String>('live_activity_category') ?? '';
      final examplesJson = await HomeWidget.getWidgetData<String>('live_activity_examples_json') ?? '[]';
      final interval = await HomeWidget.getWidgetData<int>('live_activity_interval_minutes') ?? 30;
      final startHour = await HomeWidget.getWidgetData<int>('live_activity_start_hour') ?? 8;
      final endHour = await HomeWidget.getWidgetData<int>('live_activity_end_hour') ?? 22;
      final cardId = await HomeWidget.getWidgetData<String>('live_activity_card_id') ?? '';

      List<String> examples = [];
      try {
        final decoded = jsonDecode(examplesJson);
        if (decoded is List) {
          examples = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}

      return {
        'isActive': true,
        'isCurrentlyLive': false,
        'wordEn': wordEn,
        'wordEs': wordEs,
        'phonetic': phonetic,
        'type': type,
        'category': category,
        'examples': examples,
        'intervalMinutes': interval,
        'startHour': startHour,
        'endHour': endHour,
        'cardId': cardId,
      };
    } catch (e) {
      debugPrint('Error getting active Live Activity state: $e');
      return null;
    }
  }

  /// Determines human readable word type
  String _determineWordType(Flashcard card) {
    if (card.isVerbWithForms) return 'IRREGULAR VERB';
    final cat = card.categoryId.toLowerCase();
    if (cat.contains('phrasal')) return 'PHRASAL VERB';
    if (cat.contains('phrase') || cat.contains('idiom') || cat.contains('conversation')) return 'PHRASE';
    if (cat.contains('verb')) return 'VERB';
    return 'VOCABULARY';
  }

  /// Generates contextual, natural English sentences for the learning item
  List<String> _generateContextualExamples(Flashcard card, List<String> existing) {
    final word = card.wordEn.trim();
    final List<String> generated = [];

    // Varied natural structures
    final templates = [
      'Take time to practice using "$word" naturally in conversation.',
      'Remember the meaning of "$word" and try making your own sentence.',
      'Everyday focus: "$word". Say it out loud three times.',
      'Notice how native speakers use "$word" in daily contexts.',
      'Keep improving your fluency with "$word".',
    ];

    for (var t in templates) {
      if (!existing.contains(t) && !generated.contains(t)) {
        generated.add(t);
      }
    }
    return generated;
  }
}
