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

  ThemeMode _themeMode = ThemeMode.dark;
  bool _soundEnabled = true;
  int _dailyGoal = AppConstants.defaultDailyGoal;
  bool _isOnboardingCompleted = false;
  String _languageCode = 'es';
  bool _notificationsEnabled = true;
  int _reminderHour = 20;
  int _reminderMinute = 0;
  ItemNotificationConfig? _itemNotificationConfig;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

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
      // App & Navigation
      'app.title': 'EasyEnglish',
      'nav.home': 'Inicio',
      'nav.categories': 'Categorías',
      'nav.quiz': 'Quiz',
      'nav.suggestions': 'Sugerencias',
      'nav.study': 'Estudiar',
      'nav.progress': 'Progreso',
      'nav.settings': 'Ajustes',

      // Home
      'home.greeting': '¡Hola!',
      'home.learnToday': 'Aprende hoy',
      'home.dailyGoal': 'Meta Diaria',
      'home.dueCards': 'tarjetas pendientes para hoy',
      'home.goalDone': 'Meta diaria completada con éxito',
      'home.startReview': 'Comenzar Repaso',
      'home.practiceMore': 'Practicar Más',
      'home.categoriesTitle': 'Categorías de Vocabulario',
      'home.viewAll': 'Ver todas',
      'home.learned': 'Aprendidas',
      'home.mastered': 'Dominadas',
      'home.totalCards': 'Total',
      'home.streak': 'Días seguidos',
      'home.quizChallenge.title': 'Desafío de Quiz',
      'home.quizChallenge.desc': 'Pon a prueba tu vocabulario con 5 tipos de preguntas dinámicas.',
      'home.welcome.title': 'Bienvenido a EasyEnglish',
      'home.welcome.subtitle': 'Aprende vocabulario y verbos en inglés con repetición espaciada.',
      'home.dominio': 'Dominio',
      'home.studyNow': 'Estudiar ahora',
      'home.reviews.empty': '¡Todo al día!',

      // Categories
      'cats.title': 'Categorías de Vocabulario',
      'catcount.words': 'palabras',
      'catcount.phrases': 'frases',
      'cat.learned.checked': 'APRENDIDO',
      'cat.search': 'Buscar palabra o frase...',
      'cat.pinForNotif': 'Fijar para Notificaciones',
      'cat.pinnedSuccess': 'Palabra fijada para notificaciones del día',

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

      // SRS Review
      'srs.title': 'Repaso Espaciado',
      'srs.hard': 'Difícil',
      'srs.normal': 'Normal',
      'srs.easy': 'Fácil',
      'srs.finished.title': '¡Sesión completada!',
      'srs.finished.subtitle': 'Excelente trabajo. Todas las tarjetas programadas han sido revisadas.',
      'srs.finished.back': 'Volver al inicio',
      'srs.steps': 'Tarjeta',

      // Stats
      'stats.title': 'Mi Progreso',
      'stats.totalReviews': 'Repasos Totales',
      'stats.bestStreak': 'Mejor Racha',
      'stats.days': 'días',
      'stats.distribution': 'Distribución de Vocabulario',
      'stats.noData': 'Sin datos aún',
      'stats.legendMastered': 'Dominadas',
      'stats.legendLearning': 'En aprendizaje',
      'stats.legendNew': 'Nuevas',
      'stats.catProgress': 'Progreso por Categoría',

      // Quiz Setup
      'quiz.title': 'Quiz & Desafíos',
      'quiz.categories': '1. CATEGORÍAS (MULTI-SELECCIÓN)',
      'quiz.selectAll': 'Todas',
      'quiz.deselect': 'Desmarcar',
      'quiz.typeHeader': '2. TIPO DE DESAFÍO',
      'quiz.sizeHeader': '3. CANTIDAD DE PREGUNTAS',
      'quiz.questionsUnit': 'preguntas',
      'quiz.start': 'Iniciar Quiz',
      'quiz.type.mixed': 'Mezcla Aleatoria',
      'quiz.type.mixedDesc': 'Combina los 5 formatos en una sesión dinámica (Recomendado)',
      'quiz.type.multipleChoice': 'Opción Múltiple',
      'quiz.type.multipleChoiceDesc': 'Traducción y completar espacios en blanco con 4 opciones',
      'quiz.type.buildSentence': 'Construir Oración',
      'quiz.type.buildSentenceDesc': 'Ordena palabras y fragmentos desordenados',
      'quiz.type.speedQuiz': 'Speed Quiz',
      'quiz.type.speedQuizDesc': 'Contrarreloj veloz (7 segundos por pregunta)',
      'quiz.type.situation': 'Situacional',
      'quiz.type.situationDesc': 'Elige la frase o tiempo adecuado según el contexto',
      'quiz.type.findError': 'Encuentra el Error',
      'quiz.type.findErrorDesc': 'Detecta y corrige el fallo gramatical en la oración',
      'quiz.infoNote': 'Las preguntas que falles aparecerán en tu pestaña ',

      // Quiz Play & Feedback
      'quiz.questionCounter': 'Pregunta',
      'quiz.checkSentence': 'Comprobar Oración',
      'quiz.availableWords': 'PALABRAS DISPONIBLES',
      'quiz.tapToOrder': 'Toca las palabras abajo para ordenarlas aquí',
      'quiz.correct': '¡Excelente! Respuesta Correcta',
      'quiz.incorrect': 'Respuesta Incorrecta',
      'quiz.savedToSuggestions': 'Guardado en Sugerencias para repasar.',
      'quiz.nextQuestion': 'Siguiente Pregunta',
      'quiz.viewResults': 'Ver Resultados',
      'quiz.exitDialog.title': '¿Salir del Quiz?',
      'quiz.exitDialog.body': 'Si sales ahora, se perderá el progreso de esta sesión.',
      'quiz.exitDialog.cancel': 'Continuar',
      'quiz.exitDialog.confirm': 'Salir',

      // Quiz Summary
      'quiz.results.great': '¡Excelente Dominio!',
      'quiz.results.good': '¡Buen Trabajo!',
      'quiz.results.practice': '¡Sigue Practicando!',
      'quiz.results.subtitle': 'Has completado el quiz de',
      'quiz.results.score': 'PUNTUACIÓN',
      'quiz.results.accuracy': 'PRECISIÓN',
      'quiz.results.bestStreak': 'MEJOR RACHA',
      'quiz.results.correctCount': 'correctas',
      'quiz.results.incorrectCount': 'falladas',
      'quiz.results.itemsSaved': 'ítems agregados a tus Sugerencias para repasar.',
      'quiz.results.retry': 'Repetir Quiz',
      'quiz.results.viewSuggestions': 'Ver Sugerencias',
      'quiz.results.backHome': 'Volver al Inicio',

      // Suggestions
      'suggestions.title': 'Sugerencias de Repaso',
      'suggestions.filter.pending': 'Pendientes',
      'suggestions.filter.all': 'Todas',
      'suggestions.filter.resolved': 'Dominadas',
      'suggestions.failedTimes': 'Fallado',
      'suggestions.formula': 'Fórmula',
      'suggestions.reviewCard': 'Repasar Tarjeta',
      'suggestions.markResolved': 'Marcar como dominado',
      'suggestions.markPending': 'Marcar como pendiente',
      'suggestions.delete': 'Eliminar sugerencia',
      'suggestions.empty.title': '¡Sin sugerencias pendientes!',
      'suggestions.empty.body': 'Cuando falles preguntas en los Quizzes, aparecerán aquí para que puedas repasarlas y dominarlas.',
      'suggestions.clearAll.title': '¿Limpiar todas las sugerencias?',
      'suggestions.clearAll.body': 'Se borrará la lista de ítems recomendados para repasar.',
      'suggestions.clearAll.cancel': 'Cancelar',
      'suggestions.clearAll.confirm': 'Limpiar',

      // Settings
      'settings.title': 'Configuración',
      'settings.themeGroup': 'APARIENCIA Y TEMA',
      'settings.theme.title': 'Tema visual',
      'settings.theme.light': 'Claro',
      'settings.theme.dark': 'Oscuro',
      'settings.theme.system': 'Automático',
      'settings.theme.systemDesc': 'Se adapta automáticamente al tema del sistema',
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
      'settings.notif.instantTitle': 'Momento de practicar inglés',
      'settings.notif.instantBody': 'Tu meta diaria te espera. Vamos a aprender unas palabras.',
      'settings.notif.scheduledTitle': 'Recordatorio programado',
      'settings.notif.scheduledBody': 'Las notificaciones programadas funcionan correctamente.',
      'settings.notif.dailyTitle': 'Hora de tu sesión de EasyEnglish',
      'settings.notif.dailyBody': 'Dedica unos minutos hoy para mantener activa tu racha de aprendizaje.',
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
      'settings.language.title': 'Idioma de la interfaz',
      'settings.language.subtitle': 'Elige el idioma de los menús y botones',
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
      'onb.page2.sub': 'Sistema de 3 opciones (Difícil / Normal / Fácil) que programa cada tarjeta en el momento ideal.',
      'onb.page3.title': 'Tu Meta Diaria',
      'onb.page3.sub': 'Elige cuántas palabras nuevas deseas dominar cada día.',

      // Splash
      'splash.loading': 'Cargando EasyEnglish...',
    },
    'en': {
      // App & Navigation
      'app.title': 'EasyEnglish',
      'nav.home': 'Home',
      'nav.categories': 'Categories',
      'nav.quiz': 'Quiz',
      'nav.suggestions': 'Suggestions',
      'nav.study': 'Study',
      'nav.progress': 'Progress',
      'nav.settings': 'Settings',

      // Home
      'home.greeting': 'Hi there!',
      'home.learnToday': 'Learn today',
      'home.dailyGoal': 'Daily Goal',
      'home.dueCards': 'cards due today',
      'home.goalDone': 'Daily goal completed successfully',
      'home.startReview': 'Start Review',
      'home.practiceMore': 'Practice More',
      'home.categoriesTitle': 'Vocabulary Categories',
      'home.viewAll': 'View all',
      'home.learned': 'Learned',
      'home.mastered': 'Mastered',
      'home.totalCards': 'Total',
      'home.streak': 'Day streak',
      'home.quizChallenge.title': 'Quiz Challenge',
      'home.quizChallenge.desc': 'Test your vocabulary with 5 dynamic question formats.',
      'home.welcome.title': 'Welcome to EasyEnglish',
      'home.welcome.subtitle': 'Learn English vocabulary and verbs with spaced repetition.',
      'home.dominio': 'Mastery',
      'home.studyNow': 'Study now',
      'home.reviews.empty': 'All caught up!',

      // Categories
      'cats.title': 'Vocabulary Categories',
      'catcount.words': 'words',
      'catcount.phrases': 'phrases',
      'cat.learned.checked': 'LEARNED',
      'cat.search': 'Search word or phrase...',
      'cat.pinForNotif': 'Pin for Notifications',
      'cat.pinnedSuccess': 'Word pinned for daily notifications',

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

      // SRS Review
      'srs.title': 'Spaced Review',
      'srs.hard': 'Hard',
      'srs.normal': 'Good',
      'srs.easy': 'Easy',
      'srs.finished.title': 'Session complete!',
      'srs.finished.subtitle': 'Great job. All scheduled cards have been reviewed.',
      'srs.finished.back': 'Back to home',
      'srs.steps': 'Card',

      // Stats
      'stats.title': 'My Progress',
      'stats.totalReviews': 'Total Reviews',
      'stats.bestStreak': 'Best Streak',
      'stats.days': 'days',
      'stats.distribution': 'Vocabulary Distribution',
      'stats.noData': 'No data yet',
      'stats.legendMastered': 'Mastered',
      'stats.legendLearning': 'In progress',
      'stats.legendNew': 'New',
      'stats.catProgress': 'Progress by Category',

      // Quiz Setup
      'quiz.title': 'Quiz & Challenges',
      'quiz.categories': '1. CATEGORIES (MULTI-SELECT)',
      'quiz.selectAll': 'All',
      'quiz.deselect': 'Deselect',
      'quiz.typeHeader': '2. CHALLENGE TYPE',
      'quiz.sizeHeader': '3. QUESTION COUNT',
      'quiz.questionsUnit': 'questions',
      'quiz.start': 'Start Quiz',
      'quiz.type.mixed': 'Mixed Challenge',
      'quiz.type.mixedDesc': 'Combines all 5 formats dynamically (Recommended)',
      'quiz.type.multipleChoice': 'Multiple Choice',
      'quiz.type.multipleChoiceDesc': 'Translation and fill-in-the-blank with 4 options',
      'quiz.type.buildSentence': 'Build Sentence',
      'quiz.type.buildSentenceDesc': 'Order scrambled words and fragments',
      'quiz.type.speedQuiz': 'Speed Quiz',
      'quiz.type.speedQuizDesc': 'Fast-paced countdown (7 seconds per question)',
      'quiz.type.situation': 'Situational',
      'quiz.type.situationDesc': 'Pick the right phrase or tense based on context',
      'quiz.type.findError': 'Find Error',
      'quiz.type.findErrorDesc': 'Identify and correct the grammatical mistake',
      'quiz.infoNote': 'Questions you miss will be saved in your ',

      // Quiz Play & Feedback
      'quiz.questionCounter': 'Question',
      'quiz.checkSentence': 'Check Sentence',
      'quiz.availableWords': 'AVAILABLE WORDS',
      'quiz.tapToOrder': 'Tap words below to arrange them here',
      'quiz.correct': 'Great! Correct Answer',
      'quiz.incorrect': 'Incorrect Answer',
      'quiz.savedToSuggestions': 'Saved to Suggestions for review.',
      'quiz.nextQuestion': 'Next Question',
      'quiz.viewResults': 'View Results',
      'quiz.exitDialog.title': 'Exit Quiz?',
      'quiz.exitDialog.body': 'If you exit now, progress in this session will be lost.',
      'quiz.exitDialog.cancel': 'Continue',
      'quiz.exitDialog.confirm': 'Exit',

      // Quiz Summary
      'quiz.results.great': 'Great Mastery!',
      'quiz.results.good': 'Good Job!',
      'quiz.results.practice': 'Keep Practicing!',
      'quiz.results.subtitle': 'You completed the quiz of',
      'quiz.results.score': 'SCORE',
      'quiz.results.accuracy': 'ACCURACY',
      'quiz.results.bestStreak': 'BEST STREAK',
      'quiz.results.correctCount': 'correct',
      'quiz.results.incorrectCount': 'missed',
      'quiz.results.itemsSaved': 'items saved in your Suggestions for review.',
      'quiz.results.retry': 'Retry Quiz',
      'quiz.results.viewSuggestions': 'View Suggestions',
      'quiz.results.backHome': 'Back to Home',

      // Suggestions
      'suggestions.title': 'Review Suggestions',
      'suggestions.filter.pending': 'Pending',
      'suggestions.filter.all': 'All',
      'suggestions.filter.resolved': 'Mastered',
      'suggestions.failedTimes': 'Missed',
      'suggestions.formula': 'Formula',
      'suggestions.reviewCard': 'Review Card',
      'suggestions.markResolved': 'Mark as mastered',
      'suggestions.markPending': 'Mark as pending',
      'suggestions.delete': 'Delete suggestion',
      'suggestions.empty.title': 'No pending suggestions!',
      'suggestions.empty.body': 'Questions you miss during quizzes will appear here so you can review and master them.',
      'suggestions.clearAll.title': 'Clear all suggestions?',
      'suggestions.clearAll.body': 'The list of recommended review items will be cleared.',
      'suggestions.clearAll.cancel': 'Cancel',
      'suggestions.clearAll.confirm': 'Clear',

      // Settings
      'settings.title': 'Settings',
      'settings.themeGroup': 'APPEARANCE & THEME',
      'settings.theme.title': 'Visual theme',
      'settings.theme.light': 'Light',
      'settings.theme.dark': 'Dark',
      'settings.theme.system': 'System',
      'settings.theme.systemDesc': 'Automatically matches device system theme',
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
      'settings.notif.instantTitle': 'Time to practice English',
      'settings.notif.instantBody': 'Your daily goal is waiting. Let\'s learn some words.',
      'settings.notif.scheduledTitle': 'Scheduled reminder',
      'settings.notif.scheduledBody': 'Scheduled notifications are working properly.',
      'settings.notif.dailyTitle': 'Time for your EasyEnglish session',
      'settings.notif.dailyBody': 'Spend a few minutes today to keep your learning streak going.',
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
      'settings.language.title': 'Interface language',
      'settings.language.subtitle': 'Choose menu and button language',
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
      'onb.page2.sub': '3-option system (Hard / Good / Easy) that schedules each card at the ideal time.',
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
      
      // Load theme mode preference ('light', 'dark', 'system')
      final String storedTheme = _storage.getString(AppConstants.keyThemeMode, defaultValue: '');
      if (storedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (storedTheme == 'system') {
        _themeMode = ThemeMode.system;
      } else if (storedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        // Fallback to legacy bool
        final bool legacyDark = _storage.getBool(AppConstants.keyDarkMode, defaultValue: true);
        _themeMode = legacyDark ? ThemeMode.dark : ThemeMode.light;
      }

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
        if (card.past != null && card.past!.isNotEmpty) {
          allExamples.add('I ${card.past} yesterday.');
        }
        if (card.participle != null && card.participle!.isNotEmpty) {
          allExamples.add('I have ${card.participle} many times.');
        }
      }
      if (allExamples.length < 3) {
        allExamples.add('Always practice ${card.wordEn} in your daily routine.');
      }
    }

    final int interval = intervalMinutes ??
        _itemNotificationConfig?.intervalMinutes ??
        AppConstants.defaultNotificationInterval;

    final TimeOfDay start = startTime ??
        (_itemNotificationConfig != null && _itemNotificationConfig!.times.isNotEmpty
            ? _itemNotificationConfig!.times.first
            : const TimeOfDay(
                hour: AppConstants.notificationDefaultStartHour,
                minute: AppConstants.notificationDefaultStartMinute,
              ));

    final generatedTimes = generateDailyTimes(
      startHour: start.hour,
      startMinute: start.minute,
      intervalMinutes: interval,
    );

    _itemNotificationConfig = ItemNotificationConfig(
      cardId: card.id,
      categoryId: card.categoryId,
      wordEn: card.wordEn,
      wordEs: card.wordEs,
      grammarFormula: card.hasStructure ? card.structure : null,
      examples: allExamples,
      times: generatedTimes,
      currentExampleIndex: 0,
      isEnabled: true,
      intervalMinutes: interval,
    );

    await _storage.setMap(
      AppConstants.keyItemNotificationConfig,
      _itemNotificationConfig!.toMap(),
    );

    await _syncItemNotifications();
    notifyListeners();
  }

  /// Generates chronological list of TimeOfDay from start time to 23:30 based on intervalMinutes
  List<TimeOfDay> generateDailyTimes({
    required int startHour,
    required int startMinute,
    required int intervalMinutes,
  }) {
    final List<TimeOfDay> slots = [];
    int currentMinutes = startHour * 60 + startMinute;
    final int endMinutes = AppConstants.notificationDayEndHour * 60 + AppConstants.notificationDayEndMinute;

    while (currentMinutes <= endMinutes) {
      final int h = currentMinutes ~/ 60;
      final int m = currentMinutes % 60;
      slots.add(TimeOfDay(hour: h, minute: m));
      currentMinutes += intervalMinutes;
    }

    if (slots.isEmpty) {
      slots.add(TimeOfDay(hour: startHour, minute: startMinute));
    }

    return slots;
  }

  /// Updates notification interval and regenerates schedule using current first slot
  Future<void> updateItemNotificationInterval(int intervalMinutes) async {
    if (_itemNotificationConfig == null) return;
    final TimeOfDay startTime = _itemNotificationConfig!.times.isNotEmpty
        ? _itemNotificationConfig!.times.first
        : const TimeOfDay(hour: 8, minute: 0);

    final generatedTimes = generateDailyTimes(
      startHour: startTime.hour,
      startMinute: startTime.minute,
      intervalMinutes: intervalMinutes,
    );

    _itemNotificationConfig = _itemNotificationConfig!.copyWith(
      times: generatedTimes,
      intervalMinutes: intervalMinutes,
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

  /// Updates start time and regenerates schedule using current interval
  Future<void> updateItemNotificationStartTime(TimeOfDay newStartTime) async {
    if (_itemNotificationConfig == null) return;
    final int interval = _itemNotificationConfig!.intervalMinutes;

    final generatedTimes = generateDailyTimes(
      startHour: newStartTime.hour,
      startMinute: newStartTime.minute,
      intervalMinutes: interval,
    );

    _itemNotificationConfig = _itemNotificationConfig!.copyWith(
      times: generatedTimes,
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

  /// Updates a specific time slot without resetting the rotation index
  Future<void> updateItemNotificationTimeSlot(int index, TimeOfDay newTime) async {
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

  /// Adds a custom daily time slot for the pinned item
  Future<void> addItemNotificationTime(TimeOfDay time) async {
    if (_itemNotificationConfig == null) return;
    final currentTimes = List<TimeOfDay>.from(_itemNotificationConfig!.times);
    final exists = currentTimes.any((t) => t.hour == time.hour && t.minute == time.minute);
    if (!exists) {
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

  /// Toggles enabled state for pinned item notifications
  Future<void> toggleItemNotificationEnabled(bool value) async {
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
      bodyBuffer.writeln('Fórmula: ${_itemNotificationConfig!.grammarFormula}');
    }
    bodyBuffer.write('Ejemplo: "$example"');

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

  /// Sets ThemeMode (Light, Dark, System)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';

    await _storage.setString(AppConstants.keyThemeMode, modeString);
    await _storage.setBool(AppConstants.keyDarkMode, mode != ThemeMode.light);
    notifyListeners();
  }

  /// Legacy toggle for Dark/Light
  Future<void> toggleDarkMode(bool value) async {
    await setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
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

  Future<void> resetAllData() async {
    await _storage.clearAllProgress();
    _itemNotificationConfig = null;
    await _storage.setMap(AppConstants.keyItemNotificationConfig, {});
    await _notificationService.cancelNotification(1001);
    await _notificationService.cancelNotificationRange(2000, 64);
    notifyListeners();
  }

  bool isCategoryFirstVisit(String categoryId) {
    return !_storage.getBool('cat_visited_$categoryId', defaultValue: false);
  }

  Future<void> markCategoryVisited(String categoryId) async {
    await _storage.setBool('cat_visited_$categoryId', true);
    notifyListeners();
  }
}
