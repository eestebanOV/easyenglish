import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../models/flashcard.dart';
import 'storage_service.dart';

/// Servicio de aprendizaje diario.
/// Histórico: originalmente gestionaba Live Activities (ActivityKit iOS), pero se
/// reemplazó completamente por un sistema de NOTIFICACIONES LOCALES (UNUserNotificationCenter)
/// porque Live Activities no se actualizan de forma confiable en background sin una
/// cuenta Apple Developer de pago con APNs/voip.
/// Mantiene el nombre "LiveActivityService" por compatibilidad con el código existente.
class LiveActivityService {
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  static const MethodChannel _channel = MethodChannel('com.easyenglish.app/live_activities');
  static const String appGroupId = 'group.com.easyenglish.app';
  static const String iOSWidgetName = 'EasyEnglishWidget';
  static const String androidWidgetName = 'EasyEnglishWidget';

  /// Intervalos disponibles entre notificaciones (en minutos).
  static const List<int> availableIntervals = [15, 30, 45, 60, 120];

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      _isInitialized = true;
    } catch (e) {
      debugPrint('DailyNotificationService init error: $e');
    }
  }

  /// Programa todas las notificaciones del día para una tarjeta (ítem fijo + ejemplos rotatorios).
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

      if (allExamples.length < 6) {
        allExamples.addAll(_generateContextualExamples(card, allExamples));
      }

      final wordType = _determineWordType(card);
      final examplesJson = jsonEncode(allExamples);

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
        HomeWidget.saveWidgetData<String>('live_activity_card_id', card.id),
      ]);

      await storage.setBool('live_activity_active', true);
      await storage.setString('live_activity_word_en', card.wordEn);
      await storage.setString('live_activity_word_es', card.wordEs);
      await storage.setString('live_activity_card_id', card.id);
      await storage.setInt('live_activity_interval', intervalMinutes);
      await storage.setInt('live_activity_start_hour', startHour);
      await storage.setInt('live_activity_end_hour', endHour);

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
        debugPrint('Native Notification startDayLearning result: $result');
      } on MissingPluginException {
        debugPrint('Native Notification method channel not available (simulator/web/android)');
      } catch (e) {
        debugPrint('Native Notification invoke error: $e');
      }

      await HomeWidget.updateWidget(
        name: iOSWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      return true;
    } catch (e) {
      debugPrint('Error starting day notifications: $e');
      return false;
    }
  }

  /// Dispara una notificación inmediata (para prueba o sesión manual).
  Future<bool> startSessionNow({int? exampleIndex}) async {
    try {
      await init();
      final result = await _channel.invokeMethod('startSessionNow', {
        'exampleIndex': exampleIndex,
      });
      return result?['success'] == true;
    } catch (e) {
      debugPrint('Error triggering immediate notification: $e');
      return false;
    }
  }

  /// (Alias legacy) Finaliza el aprendizaje diario y cancela todas las notificaciones.
  Future<void> endCurrentActivity() async {
    return stopDayLearning();
  }

  /// Cancela todas las notificaciones pendientes y limpia el estado del día.
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

  /// Obtén el estado actual (palabra del día, ejemplos, intervalo, etc.).
  Future<Map<String, dynamic>?> getActiveState() async {
    try {
      await init();
      try {
        final res = await _channel.invokeMapMethod<String, dynamic>('getActiveState');
        if (res != null && res['wordEn'] != null && (res['wordEn'] as String).isNotEmpty) {
          return res;
        }
      } catch (_) {}

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
      debugPrint('Error getting active notification state: $e');
      return null;
    }
  }

  String _determineWordType(Flashcard card) {
    if (card.isVerbWithForms) return 'IRREGULAR VERB';
    final cat = card.categoryId.toLowerCase();
    if (cat.contains('phrasal')) return 'PHRASAL VERB';
    if (cat.contains('phrase') || cat.contains('idiom') || cat.contains('conversation')) return 'PHRASE';
    if (cat.contains('verb')) return 'VERB';
    return 'VOCABULARY';
  }

  List<String> _generateContextualExamples(Flashcard card, List<String> existing) {
    final word = card.wordEn.trim();
    final List<String> generated = [];

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
