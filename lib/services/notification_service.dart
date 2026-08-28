import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:app_settings/app_settings.dart';

import '../core/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _timeZoneName = 'UTC';
  String get timeZoneName => _timeZoneName;

  static const String channelIdReminders = 'daily_reminders_channel';
  static const String channelNameReminders = 'Daily Study Reminders';
  static const String channelDescReminders = 'Reminders to practice English daily';

  static const String channelIdInstant = 'instant_notifications_channel';
  static const String channelNameInstant = 'Instant Notifications';
  static const String channelDescInstant = 'Instant test and milestone notifications';

  /// Category identifier for iOS Notification Content Extension
  static const String categoryIdItemNotification = 'ITEM_NOTIFICATION_CATEGORY';

  /// Initializes timezone data, notification settings and requests permissions for iOS and Android
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize time zones
      tz_data.initializeTimeZones();
      try {
        _timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(_timeZoneName));
        debugPrint('[NotificationService] Local timezone detected: $_timeZoneName');
      } catch (e) {
        debugPrint('[NotificationService] Fallback to America/Toronto or UTC timezone: $e');
        try {
          _timeZoneName = 'America/Toronto';
          tz.setLocalLocation(tz.getLocation(_timeZoneName));
        } catch (_) {
          tz.setLocalLocation(tz.getLocation('UTC'));
          _timeZoneName = 'UTC';
        }
      }

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / Darwin Initialization Settings (registers categories for Content Extension)
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            categoryIdItemNotification,
            options: {
              DarwinNotificationCategoryOption.customDismissAction,
            },
          ),
        ],
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 4. Initialize plugin
      final bool? initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      debugPrint('[NotificationService] Initialized: $initialized');

      // 5. Explicit permission request for iOS and Android 13+
      await requestPermissions();

      _isInitialized = true;
    } catch (e, stack) {
      debugPrint('[NotificationService] Error initializing notifications: $e\n$stack');
    }
  }

  /// Request notification permissions explicitly
  Future<bool> requestPermissions() async {
    bool granted = false;
    try {
      // iOS permission request
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final bool? iosGranted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = iosGranted ?? false;
        debugPrint('[NotificationService] iOS Permissions granted: $granted');
      }

      // Android 13+ permission request
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final bool? androidGranted =
            await androidImplementation.requestNotificationsPermission();
        granted = androidGranted ?? granted;
        debugPrint('[NotificationService] Android Permissions granted: $granted');
      }
    } catch (e) {
      debugPrint('[NotificationService] Error requesting permissions: $e');
    }
    return granted;
  }

  /// Returns NotificationDetails configured for Android & iOS
  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    String? categoryIdentifier,
  }) {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      showWhen: true,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: categoryIdentifier,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Shows an instant notification immediately
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? categoryIdentifier,
  }) async {
    try {
      final details = _notificationDetails(
        channelId: channelIdInstant,
        channelName: channelNameInstant,
        channelDescription: channelDescInstant,
        categoryIdentifier: categoryIdentifier,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('[NotificationService] Instant notification sent (id: $id, title: $title)');
    } catch (e) {
      debugPrint('[NotificationService] Error showing instant notification: $e');
    }
  }

  /// Schedules a notification after a given delay (e.g. 3 seconds test)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(delay);

      final details = _notificationDetails(
        channelId: channelIdReminders,
        channelName: channelNameReminders,
        channelDescription: channelDescReminders,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint(
          '[NotificationService] Scheduled notification (id: $id, date: $scheduledDate)');
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling notification: $e');
    }
  }

  /// Schedules a recurring daily study reminder at a specific hour and minute
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final details = _notificationDetails(
        channelId: channelIdReminders,
        channelName: channelNameReminders,
        channelDescription: channelDescReminders,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint(
          '[NotificationService] Daily reminder set for $hour:${minute.toString().padLeft(2, '0')} daily (id: $id)');
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling daily reminder: $e');
    }
  }

  /// Schedules a reminder for specific days of the week (1 = Monday, 7 = Sunday)
  Future<void> scheduleWeeklyDayReminder({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1 to 7
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final details = _notificationDetails(
        channelId: channelIdReminders,
        channelName: channelNameReminders,
        channelDescription: channelDescReminders,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
      debugPrint(
          '[NotificationService] Day $weekday reminder scheduled at $hour:$minute (id: $id)');
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling weekly reminder: $e');
    }
  }

  /// Generates a list of TimeOfDay slots every [intervalMinutes] from [startTime] until [endHour]:[endMinute]
  static List<TimeOfDay> generateTimeSlots({
    required TimeOfDay startTime,
    required int intervalMinutes,
    int endHour = AppConstants.notificationDayEndHour,
    int endMinute = AppConstants.notificationDayEndMinute,
  }) {
    final List<TimeOfDay> result = [];
    int currentMinutes = startTime.hour * 60 + startTime.minute;
    final int limitMinutes = endHour * 60 + endMinute;

    final step = intervalMinutes > 0 ? intervalMinutes : 30;

    while (currentMinutes <= limitMinutes && result.length < 64) {
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      result.add(TimeOfDay(hour: hour, minute: minute));
      currentMinutes += step;
    }

    return result;
  }

  /// Schedules multiple daily notifications for a specific item, assigning a unique rotating example per slot
  Future<void> scheduleMultipleItemNotifications({
    required int baseId,
    required String wordEn,
    required String wordEs,
    String? grammarFormula,
    required List<String> examples,
    required List<TimeOfDay> times,
    int startExampleIndex = 0,
  }) async {
    if (times.isEmpty || examples.isEmpty) return;

    // Sort times chronologically for a clean daily schedule
    final sortedTimes = List<TimeOfDay>.from(times)
      ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < sortedTimes.length; i++) {
      final slotTime = sortedTimes[i];
      final int notificationId = baseId + i;
      final int exampleIndex = (startExampleIndex + i) % examples.length;
      final String exampleText = examples[exampleIndex];

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        slotTime.hour,
        slotTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final details = _notificationDetails(
        channelId: channelIdReminders,
        channelName: channelNameReminders,
        channelDescription: channelDescReminders,
        categoryIdentifier: categoryIdItemNotification,
      );

      final String title = '$wordEn ($wordEs)';
      final StringBuffer bodyBuffer = StringBuffer();
      if (grammarFormula != null && grammarFormula.trim().isNotEmpty) {
        bodyBuffer.writeln('Fórmula: $grammarFormula');
      }
      bodyBuffer.write('Ejemplo: "$exampleText"');
      final String body = bodyBuffer.toString();

      final String jsonPayload = jsonEncode({
        'wordEn': wordEn,
        'wordEs': wordEs,
        'example': exampleText,
        'grammarFormula': grammarFormula ?? '',
      });

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: jsonPayload,
      );

      debugPrint(
          '[NotificationService] Scheduled item slot $i (ID: $notificationId) at ${slotTime.hour}:${slotTime.minute.toString().padLeft(2, '0')} -> Formula: $grammarFormula | Example [$exampleIndex]: "$exampleText"');
    }
  }

  /// Cancels a range of notification IDs (for item notification slots)
  Future<void> cancelNotificationRange(int baseId, int count) async {
    for (int i = 0; i < count; i++) {
      await cancelNotification(baseId + i);
    }
  }

  /// Cancels a specific scheduled or active notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('[NotificationService] Cancelled notification id: $id');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling notification: $e');
    }
  }

  /// Cancels all pending notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('[NotificationService] All notifications cancelled');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling all notifications: $e');
    }
  }

  /// Returns list of all pending scheduled notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('[NotificationService] Error getting pending notifications: $e');
      return [];
    }
  }

  /// Opens the device settings for the user to grant notification permissions
  Future<void> openNotificationSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (e) {
      debugPrint('[NotificationService] Error opening app settings: $e');
    }
  }
}
