import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

import '../models/item_notification_config.dart';
import '../models/flashcard.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notificationService = NotificationService();

  bool _isDarkMode = true;
  bool _soundEnabled = true;
  int _dailyGoal = AppConstants.defaultDailyGoal;
  bool _isOnboardingCompleted = false;
  String _languageCode = 'es';
  bool _notificationsEnabled = true;
  int _reminderHour = 20;
  int _reminderMinute = 0;
  ItemNotificationConfig? _itemNotificationConfig;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  int get dailyGoal => _dailyGoal;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get reminderTime => TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
  ItemNotificationConfig? get itemNotificationConfig => _itemNotificationConfig;

  Locale get locale => Locale(_languageCode);

  List<LocalizationsDelegate> get localizationsDelegates => const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  List<Locale> get supportedLocales => const [Locale('es'), Locale('en')];

  static const Map<String, Map<String, String>> _strings = {
    'es': {
      // App
      'app.title': 'EasyEnglish',
      'nav.categories': 'Categorías',
      'nav.study': 'Estudiar',
      'nav.progress': 'Progreso',
      'nav.settings': 'Ajustes',

      // Home / Categorías
      'nav.home': 'Inicio',
      'home.categories': 'CATEGORÍAS',
      'home.dominio': 'Dominio',
      'home.today.title': 'HOY',
      'home.streak': 'Días seguidos',
      'home.reviews': 'Revisiones',
      'home.reviews.empty': '¡Todo al día! No hay tarjetas para repasar.',
      'home.studyNow': 'Estudiar ahora',
      'home.startOnboarding': 'Comenzar',
      'home.welcome.title': 'Bienvenido a EasyEnglish',
      'home.welcome.subtitle':
          'Aprende vocabulario y verbos en inglés con repetición espaciada.',
      'home.greeting': '¡Hola!',
      'home.learnToday': 'Aprende hoy',
      'home.dailyGoal': 'Meta Diaria',
      'home.dueCards': 'tarjetas pendientes para hoy',
      'home.goalDone': '¡Felicidades! Meta completada por hoy 🎉',
      'home.startReview': 'Comenzar Repaso',
      'home.practiceMore': 'Practicar Más',
      'home.categoriesTitle': 'Categorías',
      'home.viewAll': 'Ver todas',
      'home.learned': 'Aprendidas',
      'home.mastered': 'Dominadas',
      'home.totalCards': 'Total',

      // Stats
      'stats.title': 'Mi Progreso',
      'stats.totalReviews': 'Repasos Totales',
      'stats.bestStreak': 'Mejor Racha',
      'stats.days': 'días',
      'stats.distribution': 'Distribución de Vocabulario',
      'stats.noData': 'Sin datos',
      'stats.legendMastered': 'Dominadas',
      'stats.legendLearning': 'En aprendizaje',
      'stats.legendNew': 'Nuevas',
      'stats.catProgress': 'Progreso por Categoría',

      // Categories
      'cats.title': 'Categorías de Vocabulario',

      // Category card labels
      'cardcount.words': 'palabras',
      'cardcount.phrases': 'frases',

      // SRS
      'srs.title': 'Repaso',
      'srs.hard': 'Difícil',
      'srs.normal': 'Normal',
      'srs.easy': 'Fácil',
      'srs.finished.title': '¡Sesión completada!',
      'srs.finished.subtitle': 'Excelente trabajo. Todas las tarjetas programadas han sido revisadas.',
      'srs.finished.back': 'Volver al inicio',
      'srs.steps': 'Tarjeta',

      // Category detail
      'cat.learned.checked': 'APRENDIDO',
      'cat.search': 'Buscar...',

      // Flashcard
      'card.frontTag': 'PALABRA & TRADUCCIÓN',
      'card.tense.present': 'PRESENT',
      'card.tense.past': 'PAST',
      'card.tense.participle': 'PARTICIPLE',
      'card.structureLabel': 'STRUCTURE',
      'card.grammarFormula': 'GRAMMAR FORMULA',
      'card.backTag': 'EJEMPLO & USO',
      'card.tapToFlip': 'Toca para ver ejemplos de uso',
      'card.extra.title': 'MÁS EJEMPLOS',
      'card.backHint': 'Toca para volver al frente',

      // Settings
      'settings.title': 'Configuración',
      'settings.studyGroup': 'PREFERENCIAS DE ESTUDIO',
      'settings.dailyGoal': 'Meta diaria',
      'settings.dailyGoal.subtitle': 'palabras por día',
      'settings.sound.title': 'Pronunciación automática',
      'settings.sound.subtitle': 'Audio por voz TTS nativo',

      // Notifications
      'settings.notifGroup': 'RECORDATORIOS Y NOTIFICACIONES',
      'settings.notif.title': 'Recordatorio diario de estudio',
      'settings.notif.subtitle': 'Recibe un aviso para mantener tu racha',
      'settings.notif.time': 'Hora del recordatorio',
      'settings.notif.testInstant': 'Notificación instantánea (Prueba)',
      'settings.notif.testScheduled': 'Notificación programada en 3s (Prueba)',
      'settings.notif.instantTitle': '¡Momento de practicar inglés! 🚀',
      'settings.notif.instantBody': 'Tu meta diaria te espera. ¡Vamos a aprender unas palabras!',
      'settings.notif.scheduledTitle': 'Recordatorio en 3 segundos ⏰',
      'settings.notif.scheduledBody': '¡Excelente! Las notificaciones programadas funcionan a la perfección.',
      'settings.notif.dailyTitle': 'Hora de tu sesión de EasyEnglish 📚',
      'settings.notif.dailyBody': 'Dedica 5 minutos hoy para mantener activa tu racha de aprendizaje.',
      'settings.notif.openSettings': 'Configurar permisos de notificación',
      'settings.notif.sentInstant': '¡Notificación enviada!',
      'settings.notif.scheduledSent': '¡Notificación programada en 3 segundos!',

      // Item Specific Notifications
      'settings.itemNotif.group': 'PALABRA FIJADA PARA NOTIFICACIONES',
      'settings.itemNotif.desc': 'Recibe múltiples avisos al día de un ítem elegido con ejemplos rotativos sin repetir.',
      'settings.itemNotif.noCard': 'Ningún ítem seleccionado. Entra a una categoría y pulsa "Fijar para Notificaciones" o selecciona uno aquí.',
      'settings.itemNotif.selectedCard': 'Ítem fijado:',
      'settings.itemNotif.selectCard': 'Seleccionar Ítem',
      'settings.itemNotif.changeCard': 'Cambiar',
      'settings.itemNotif.times': 'Horarios del día (rotará un ejemplo en cada horario):',
      'settings.itemNotif.addTime': 'Agregar Horario',
      'settings.itemNotif.editTime': 'Editar Horario',
      'settings.itemNotif.autoGenerate': 'Generar cada',
      'settings.itemNotif.interval': 'Intervalo',
      'settings.itemNotif.startTime': 'Hora de inicio',
      'settings.itemNotif.regenerate': 'Regenerar horarios del día',
      'settings.itemNotif.grammarFormula': 'Fórmula Gramatical',
      'settings.itemNotif.examplesCount': 'ejemplos disponibles en rotación round-robin',
      'settings.itemNotif.enabled': 'Activar notificaciones de esta palabra',
      'settings.itemNotif.saved': '¡Horarios y palabra guardados en el sistema de notificaciones!',
      'settings.itemNotif.testNow': 'Probar ejemplo actual (Notificación)',
      'settings.itemNotif.tapToExpand': 'Toca para ver u ocultar horarios programados',
      'settings.itemNotif.slotsSummary': 'notificaciones programadas',

      'settings.dataGroup': 'DATOS Y ALMACENAMIENTO',
      'settings.language.title': 'Idioma de la app',
      'settings.language.subtitle': 'Elige el idioma de la interfaz',
      'settings.reset.title': 'Reiniciar Progreso',
      'settings.reset.subtitle': 'Borrar historial y tarjetas aprendidas',
      'settings.reset.dialog.title': '¿Reiniciar todo el progreso?',
      'settings.reset.dialog.body': 'Esta acción borrará tus rachas, estadísticas y nivel de dominio de todas las tarjetas.',
      'settings.reset.dialog.cancel': 'Cancelar',
      'settings.reset.dialog.confirm': 'Reiniciar',
      'settings.aboutGroup': 'ACERCA DE',
      'settings.reset.success': 'Progreso reiniciado correctamente',

      // Onboarding
      'onb.back': 'Atrás',
      'onb.skip': 'Omitir',
      'onb.next': 'Siguiente',
      'onb.finish': 'Comenzar',
      'onb.page1.title': 'Aprende inglés sin esfuerzo',
      'onb.page1.sub': 'Vocabulario, frases útiles y verbos irregulares con tarjetas interactivas y audio de pronunciación.',
      'onb.page2.title': 'Repetición espaciada inteligente',
      'onb.page2.sub': 'Sistema de 3 botones (Difícil / Normal / Fácil) que programa cada tarjeta en el momento ideal para que no olvides nada.',
      'onb.page3.title': 'Tu Meta Diaria',
      'onb.page3.sub': 'Elige cuántas palabras nuevas deseas dominar cada día.',

      // Splash
      'splash.loading': 'Cargando EasyEnglish...',
    },
    'en': {
      // App
      'app.title': 'EasyEnglish',
      'nav.categories': 'Categories',
      'nav.study': 'Study',
      'nav.progress': 'Progress',
      'nav.settings': 'Settings',

      // Home / Categorías
      'nav.home': 'Home',
      'home.categories': 'CATEGORIES',
      'home.dominio': 'Mastery',
      'home.today.title': 'TODAY',
      'home.streak': 'Day streak',
      'home.reviews': 'Reviews due',
      'home.reviews.empty': 'All caught up! No cards scheduled today.',
      'home.studyNow': 'Study now',
      'home.startOnboarding': 'Get started',
      'home.welcome.title': 'Welcome to EasyEnglish',
      'home.welcome.subtitle':
          'Learn English vocabulary and verbs with spaced repetition.',
      'home.greeting': 'Hi there!',
      'home.learnToday': 'Learn today',
      'home.dailyGoal': 'Daily Goal',
      'home.dueCards': 'cards due today',
      'home.goalDone': 'Congrats! Daily goal complete 🎉',
      'home.startReview': 'Start Review',
      'home.practiceMore': 'Practice More',
      'home.categoriesTitle': 'Categories',
      'home.viewAll': 'View all',
      'home.learned': 'Learned',
      'home.mastered': 'Mastered',
      'home.totalCards': 'Total',

      // Stats
      'stats.title': 'My Progress',
      'stats.totalReviews': 'Total Reviews',
      'stats.bestStreak': 'Best Streak',
      'stats.days': 'days',
      'stats.distribution': 'Vocabulary Distribution',
      'stats.noData': 'No data',
      'stats.legendMastered': 'Mastered',
      'stats.legendLearning': 'In progress',
      'stats.legendNew': 'New',
      'stats.catProgress': 'Progress by Category',

      // Categories
      'cats.title': 'Vocabulary Categories',

      // Category card labels
      'cardcount.words': 'words',
      'cardcount.phrases': 'phrases',

      // SRS
      'srs.title': 'Review',
      'srs.hard': 'Hard',
      'srs.normal': 'Good',
      'srs.easy': 'Easy',
      'srs.finished.title': 'Session complete!',
      'srs.finished.subtitle':
          'Great job. All scheduled cards have been reviewed.',
      'srs.finished.back': 'Back to home',
      'srs.steps': 'Card',

      // Category detail
      'cat.learned.checked': 'LEARNED',
      'cat.search': 'Search...',

      // Flashcard
      'card.frontTag': 'WORD & TRANSLATION',
      'card.tense.present': 'PRESENT',
      'card.tense.past': 'PAST',
      'card.tense.participle': 'PARTICIPLE',
      'card.structureLabel': 'STRUCTURE',
      'card.grammarFormula': 'GRAMMAR FORMULA',
      'card.backTag': 'EXAMPLE & USAGE',
      'card.tapToFlip': 'Tap to see usage examples',
      'card.extra.title': 'MORE EXAMPLES',
      'card.backHint': 'Tap to flip back',

      // Settings
      'settings.title': 'Settings',
      'settings.studyGroup': 'STUDY PREFERENCES',
      'settings.dailyGoal': 'Daily goal',
      'settings.dailyGoal.subtitle': 'words per day',
      'settings.sound.title': 'Auto pronunciation',
      'settings.sound.subtitle': 'Native TTS voice audio',

      // Notifications
      'settings.notifGroup': 'REMINDERS & NOTIFICATIONS',
      'settings.notif.title': 'Daily study reminder',
      'settings.notif.subtitle': 'Get a reminder to keep your streak active',
      'settings.notif.time': 'Reminder time',
      'settings.notif.testInstant': 'Instant notification (Test)',
      'settings.notif.testScheduled': 'Scheduled notification in 3s (Test)',
      'settings.notif.instantTitle': 'Time to practice English! 🚀',
      'settings.notif.instantBody': 'Your daily goal is waiting. Let\'s learn some words!',
      'settings.notif.scheduledTitle': 'Reminder in 3 seconds ⏰',
      'settings.notif.scheduledBody': 'Great! Scheduled notifications are working perfectly.',
      'settings.notif.dailyTitle': 'Time for your EasyEnglish session 📚',
      'settings.notif.dailyBody': 'Spend 5 minutes today to keep your learning streak going.',
      'settings.notif.openSettings': 'Manage notification permissions',
      'settings.notif.sentInstant': 'Notification sent!',
      'settings.notif.scheduledSent': 'Notification scheduled in 3 seconds!',

      // Item Specific Notifications
      'settings.itemNotif.group': 'PINNED ITEM FOR NOTIFICATIONS',
      'settings.itemNotif.desc': 'Get multiple reminders throughout the day for a chosen item with non-repeating rotating examples.',
      'settings.itemNotif.noCard': 'No item pinned. Go to any category and tap "Pin for Notifications" or select one here.',
      'settings.itemNotif.selectedCard': 'Pinned item:',
      'settings.itemNotif.selectCard': 'Select Item',
      'settings.itemNotif.changeCard': 'Change',
      'settings.itemNotif.times': 'Daily notification times (each slot gets a unique rotating example):',
      'settings.itemNotif.addTime': 'Add Time',
      'settings.itemNotif.editTime': 'Edit Time',
      'settings.itemNotif.autoGenerate': 'Generate every',
      'settings.itemNotif.interval': 'Interval',
      'settings.itemNotif.startTime': 'Start time',
      'settings.itemNotif.regenerate': 'Regenerate daily schedule',
      'settings.itemNotif.grammarFormula': 'Grammar Formula',
      'settings.itemNotif.examplesCount': 'examples available in round-robin cycle',
      'settings.itemNotif.enabled': 'Enable notifications for this item',
      'settings.itemNotif.saved': 'Times and item scheduled in notification system!',
      'settings.itemNotif.testNow': 'Test current example (Notification)',
      'settings.itemNotif.tapToExpand': 'Tap to view or hide scheduled times',
      'settings.itemNotif.slotsSummary': 'scheduled notifications',

      'settings.dataGroup': 'DATA & STORAGE',
      'settings.language.title': 'App language',
      'settings.language.subtitle': 'Choose the interface language',
      'settings.reset.title': 'Reset progress',
      'settings.reset.subtitle': 'Clear history and learned cards',
      'settings.reset.dialog.title': 'Reset all progress?',
      'settings.reset.dialog.body': 'This will clear your streaks, statistics and mastery level for every card.',
      'settings.reset.dialog.cancel': 'Cancel',
      'settings.reset.dialog.confirm': 'Reset',
      'settings.aboutGroup': 'ABOUT',
      'settings.reset.success': 'Progress reset successfully',

      // Onboarding
      'onb.back': 'Back',
      'onb.skip': 'Skip',
      'onb.next': 'Next',
      'onb.finish': 'Start',
      'onb.page1.title': 'Learn English effortlessly',
      'onb.page1.sub': 'Vocabulary, useful phrases and irregular verbs with interactive cards and pronunciation audio.',
      'onb.page2.title': 'Smart spaced repetition',
      'onb.page2.sub': '3-button system (Hard / Good / Easy) that schedules each card at the perfect time so you never forget.',
      'onb.page3.title': 'Your Daily Goal',
      'onb.page3.sub': 'Choose how many new words you want to master every day.',

      // Splash
      'splash.loading': 'Loading EasyEnglish...',
    },
  };

  String translate(String key) {
    final map = _strings[_languageCode] ?? _strings['es']!;
    return map[key] ?? key;
  }

  Future<void> init() async {
    try {
      await _storage.init();
      _isDarkMode = _storage.getBool(
        AppConstants.keyDarkMode,
        defaultValue: true,
      );
      _soundEnabled = _storage.getBool(
        AppConstants.keySoundEnabled,
        defaultValue: true,
      );
      _dailyGoal = _storage.getInt(
        AppConstants.keyDailyGoal,
        defaultValue: AppConstants.defaultDailyGoal,
      );
      _isOnboardingCompleted = _storage.getBool(
        AppConstants.keyOnboardingComplete,
        defaultValue: false,
      );
      _languageCode = _storage.getString(
        AppConstants.keyLanguage,
        defaultValue: 'es',
      );
      _notificationsEnabled = _storage.getBool(
        AppConstants.keyNotificationsEnabled,
        defaultValue: true,
      );
      _reminderHour = _storage.getInt(
        AppConstants.keyNotificationHour,
        defaultValue: 20,
      );
      _reminderMinute = _storage.getInt(
        AppConstants.keyNotificationMinute,
        defaultValue: 0,
      );

      // Load item notification config if present
      final itemMap = _storage.getMap(AppConstants.keyItemNotificationConfig);
      if (itemMap != null) {
        _itemNotificationConfig = ItemNotificationConfig.fromMap(itemMap);
      }

      // Setup scheduled daily reminder if enabled
      if (_notificationsEnabled) {
        _syncDailyReminder();
      }

      // Setup scheduled item notifications if enabled
      if (_itemNotificationConfig != null && _itemNotificationConfig!.isEnabled) {
        _syncItemNotifications();
      }
    } catch (e) {
      debugPrint('SettingsProvider init error: $e');
    }
    notifyListeners();
  }

  Future<void> _syncDailyReminder() async {
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(
        id: 1001,
        title: translate('settings.notif.dailyTitle'),
        body: translate('settings.notif.dailyBody'),
        hour: _reminderHour,
        minute: _reminderMinute,
      );
    } else {
      await _notificationService.cancelNotification(1001);
    }
  }

  Future<void> _syncItemNotifications() async {
    // Base ID 2000 for item slots (cancels up to 64 slots)
    await _notificationService.cancelNotificationRange(2000, 64);

    if (_itemNotificationConfig != null &&
        _itemNotificationConfig!.isEnabled &&
        _itemNotificationConfig!.times.isNotEmpty &&
        _itemNotificationConfig!.examples.isNotEmpty) {
      await _notificationService.scheduleMultipleItemNotifications(
        baseId: 2000,
        wordEn: _itemNotificationConfig!.wordEn,
        wordEs: _itemNotificationConfig!.wordEs,
        grammarFormula: _itemNotificationConfig!.grammarFormula,
        examples: _itemNotificationConfig!.examples,
        times: _itemNotificationConfig!.times,
        startExampleIndex: _itemNotificationConfig!.currentExampleIndex,
      );
    }
  }

  /// Sets a specific flashcard as the pinned item for multiple daily notifications
  Future<void> setItemForNotifications(
    Flashcard card, {
    TimeOfDay? startTime,
    int? intervalMinutes,
  }) async {
    List<String> allExamples = List<String>.from(card.allExamples);
    // Ensure there are at least 3 distinct examples for rotation
    if (allExamples.length < 3) {
      if (card.isVerbWithForms) {
        allExamples.add('Present: ${card.present} | Past: ${card.past} | Participle: ${card.participle}');
      }
      if (card.hasStructure) {
        allExamples.add('Estructura: ${card.structure}');
      }
      if (card.exampleEs.isNotEmpty && !allExamples.contains(card.exampleEs)) {
        allExamples.add('Traducción: "${card.exampleEs}"');
      }
    }

    final selectedInterval = intervalMinutes ??
        _itemNotificationConfig?.intervalMinutes ??
        AppConstants.defaultNotificationInterval;

    final selectedStart = startTime ??
        (_itemNotificationConfig?.times.isNotEmpty == true
            ? _itemNotificationConfig!.times.first
            : const TimeOfDay(
                hour: AppConstants.notificationDefaultStartHour,
                minute: AppConstants.notificationDefaultStartMinute,
              ));

    // Automatically generate scheduled times from selected start time to end of day
    final autoTimes = NotificationService.generateTimeSlots(
      startTime: selectedStart,
      intervalMinutes: selectedInterval,
    );

    _itemNotificationConfig = ItemNotificationConfig(
      cardId: card.id,
      categoryId: card.categoryId,
      wordEn: card.wordEn,
      wordEs: card.wordEs,
      grammarFormula: card.hasStructure ? card.structure : null,
      examples: allExamples,
      times: autoTimes,
      intervalMinutes: selectedInterval,
      currentExampleIndex: 0,
      isEnabled: true,
    );

    await _storage.setMap(
      AppConstants.keyItemNotificationConfig,
      _itemNotificationConfig!.toMap(),
    );

    await _notificationService.requestPermissions();
    await _syncItemNotifications();
    notifyListeners();
  }

  /// Regenerates the daily time slots using the given [startTime] and [intervalMinutes]
  Future<void> generateAutoTimes({
    TimeOfDay? startTime,
    int? intervalMinutes,
  }) async {
    if (_itemNotificationConfig == null) return;
    final selectedInterval = intervalMinutes ?? _itemNotificationConfig!.intervalMinutes;
    final selectedStart = startTime ??
        (_itemNotificationConfig!.times.isNotEmpty
            ? _itemNotificationConfig!.times.first
            : const TimeOfDay(
                hour: AppConstants.notificationDefaultStartHour,
                minute: AppConstants.notificationDefaultStartMinute,
              ));

    final generatedTimes = NotificationService.generateTimeSlots(
      startTime: selectedStart,
      intervalMinutes: selectedInterval,
    );

    _itemNotificationConfig = _itemNotificationConfig!.copyWith(
      times: generatedTimes,
      intervalMinutes: selectedInterval,
    );

    await _storage.setMap(
      AppConstants.keyItemNotificationConfig,
      _itemNotificationConfig!.toMap(),
    );

    if (_itemNotificationConfig!.isEnabled) {
      await _syncItemNotifications();
    }
    notifyListeners();
  }

  /// Updates the interval and regenerates schedule
  Future<void> updateItemNotificationInterval(int newIntervalMinutes) async {
    await generateAutoTimes(intervalMinutes: newIntervalMinutes);
  }

  /// Toggles whether notifications for the pinned item are active
  Future<void> toggleItemNotifications(bool value) async {
    if (_itemNotificationConfig == null) return;
    _itemNotificationConfig = _itemNotificationConfig!.copyWith(isEnabled: value);
    await _storage.setMap(
      AppConstants.keyItemNotificationConfig,
      _itemNotificationConfig!.toMap(),
    );

    if (value) {
      await _notificationService.requestPermissions();
      await _syncItemNotifications();
    } else {
      await _notificationService.cancelNotificationRange(2000, 64);
    }
    notifyListeners();
  }

  /// Updates a specific time slot without resetting the rotation index
  Future<void> updateItemNotificationTime(int index, TimeOfDay newTime) async {
    if (_itemNotificationConfig == null) return;
    final currentTimes = List<TimeOfDay>.from(_itemNotificationConfig!.times);
    if (index >= 0 && index < currentTimes.length) {
      currentTimes[index] = newTime;
      currentTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      _itemNotificationConfig = _itemNotificationConfig!.copyWith(times: currentTimes);
      await _storage.setMap(
        AppConstants.keyItemNotificationConfig,
        _itemNotificationConfig!.toMap(),
      );
      if (_itemNotificationConfig!.isEnabled) {
        await _syncItemNotifications();
      }
      notifyListeners();
    }
  }

  /// Adds a new daily time slot for the pinned item
  Future<void> addItemNotificationTime(TimeOfDay time) async {
    if (_itemNotificationConfig == null) return;
    final currentTimes = List<TimeOfDay>.from(_itemNotificationConfig!.times);
    // Avoid exact duplicate time
    if (!currentTimes.any((t) => t.hour == time.hour && t.minute == time.minute)) {
      currentTimes.add(time);
      currentTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      _itemNotificationConfig = _itemNotificationConfig!.copyWith(times: currentTimes);
      await _storage.setMap(
        AppConstants.keyItemNotificationConfig,
        _itemNotificationConfig!.toMap(),
      );
      if (_itemNotificationConfig!.isEnabled) {
        await _syncItemNotifications();
      }
      notifyListeners();
    }
  }

  /// Removes a daily time slot for the pinned item by index
  Future<void> removeItemNotificationTime(int index) async {
    if (_itemNotificationConfig == null) return;
    final currentTimes = List<TimeOfDay>.from(_itemNotificationConfig!.times);
    if (index >= 0 && index < currentTimes.length) {
      currentTimes.removeAt(index);
      _itemNotificationConfig = _itemNotificationConfig!.copyWith(times: currentTimes);
      await _storage.setMap(
        AppConstants.keyItemNotificationConfig,
        _itemNotificationConfig!.toMap(),
      );
      if (_itemNotificationConfig!.isEnabled) {
        await _syncItemNotifications();
      }
      notifyListeners();
    }
  }

  /// Advances rotation pointer (round-robin)
  Future<void> advanceItemExampleRotation() async {
    if (_itemNotificationConfig == null || _itemNotificationConfig!.examples.isEmpty) return;
    final nextIndex = (_itemNotificationConfig!.currentExampleIndex + 1) %
        _itemNotificationConfig!.examples.length;
    _itemNotificationConfig = _itemNotificationConfig!.copyWith(
      currentExampleIndex: nextIndex,
    );
    await _storage.setMap(
      AppConstants.keyItemNotificationConfig,
      _itemNotificationConfig!.toMap(),
    );
    if (_itemNotificationConfig!.isEnabled) {
      await _syncItemNotifications();
    }
    notifyListeners();
  }

  /// Sends an immediate test notification with the current rotating example of the pinned item
  Future<void> sendTestItemNotification() async {
    if (_itemNotificationConfig == null || _itemNotificationConfig!.examples.isEmpty) return;
    final example = _itemNotificationConfig!.examples[
        _itemNotificationConfig!.currentExampleIndex %
            _itemNotificationConfig!.examples.length];
    final StringBuffer bodyBuffer = StringBuffer();
    if (_itemNotificationConfig!.hasGrammarFormula) {
      bodyBuffer.writeln('📐 Fórmula: ${_itemNotificationConfig!.grammarFormula}');
    }
    bodyBuffer.write('💡 Ejemplo: "$example"');

    final String jsonPayload = jsonEncode({
      'wordEn': _itemNotificationConfig!.wordEn,
      'wordEs': _itemNotificationConfig!.wordEs,
      'example': example,
      'grammarFormula': _itemNotificationConfig!.grammarFormula ?? '',
    });

    await _notificationService.showInstantNotification(
      id: 2999,
      title: '${_itemNotificationConfig!.wordEn} (${_itemNotificationConfig!.wordEs})',
      body: bodyBuffer.toString(),
      payload: jsonPayload,
      categoryIdentifier: NotificationService.categoryIdItemNotification,
    );
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _storage.setBool(AppConstants.keyNotificationsEnabled, value);
    if (value) {
      await _notificationService.requestPermissions();
      await _syncDailyReminder();
    } else {
      await _notificationService.cancelNotification(1001);
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    await _storage.setInt(AppConstants.keyNotificationHour, time.hour);
    await _storage.setInt(AppConstants.keyNotificationMinute, time.minute);
    if (_notificationsEnabled) {
      await _syncDailyReminder();
    }
    notifyListeners();
  }

  Future<void> sendTestInstantNotification() async {
    await _notificationService.showInstantNotification(
      id: 0,
      title: translate('settings.notif.instantTitle'),
      body: translate('settings.notif.instantBody'),
    );
  }

  Future<void> sendTestScheduledNotification() async {
    await _notificationService.scheduleNotification(
      id: 999,
      title: translate('settings.notif.scheduledTitle'),
      body: translate('settings.notif.scheduledBody'),
      delay: const Duration(seconds: 3),
    );
  }

  Future<void> openNotificationSettings() async {
    await _notificationService.openNotificationSettings();
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

  Future<void> setLanguage(String code) async {
    if (code != 'es' && code != 'en') return;
    if (code == _languageCode) return;
    _languageCode = code;
    await _storage.setString(AppConstants.keyLanguage, code);
    if (_notificationsEnabled) {
      await _syncDailyReminder();
    }
    if (_itemNotificationConfig != null && _itemNotificationConfig!.isEnabled) {
      await _syncItemNotifications();
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    await _storage.setBool(AppConstants.keyOnboardingComplete, true);
    notifyListeners();
  }
}

