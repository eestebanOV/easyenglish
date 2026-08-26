import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final flashcardProvider = context.read<FlashcardProvider>();
    final t = settings.translate;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(t('settings.title')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text(
              t('settings.studyGroup'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            // Language Selector
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.translate_rounded,
                  color: AppTheme.primaryLight,
                ),
                title: Text(t('settings.language.title')),
                subtitle: Text(t('settings.language.subtitle')),
                trailing: DropdownButton<String>(
                  value: settings.languageCode,
                  underline: const SizedBox(),
                  dropdownColor: AppTheme.darkCard,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'es',
                      child: Text('🇪🇸  Español'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text('🇺🇸  English'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      settings.setLanguage(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daily Goal Selector
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.track_changes_rounded,
                  color: AppTheme.primaryLight,
                ),
                title: Text(t('settings.dailyGoal')),
                subtitle: Text(
                  '${settings.dailyGoal} ${t('settings.dailyGoal.subtitle')}',
                ),
                trailing: DropdownButton<int>(
                  value: settings.dailyGoal,
                  underline: const SizedBox(),
                  dropdownColor: AppTheme.darkCard,
                  items: AppConstants.dailyGoalOptions.map((goal) {
                    return DropdownMenuItem<int>(
                      value: goal,
                      child: Text('$goal'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      settings.setDailyGoal(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Audio Pronunciation Toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.volume_up_rounded,
                  color: AppTheme.accent,
                ),
                title: Text(t('settings.sound.title')),
                subtitle: Text(t('settings.sound.subtitle')),
                value: settings.soundEnabled,
                activeTrackColor: AppTheme.accent,
                onChanged: (val) => settings.toggleSound(val),
              ),
            ),
            const SizedBox(height: 28),

            // Notifications Group
            Text(
              t('settings.notifGroup'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            // Notification Daily Reminder Switch
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppTheme.primaryLight,
                    ),
                    title: Text(t('settings.notif.title')),
                    subtitle: Text(t('settings.notif.subtitle')),
                    value: settings.notificationsEnabled,
                    activeTrackColor: AppTheme.primaryLight,
                    onChanged: (val) => settings.toggleNotifications(val),
                  ),
                  if (settings.notificationsEnabled) ...[
                    const Divider(color: AppTheme.darkBorder, height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.access_time_rounded,
                        color: AppTheme.accent,
                      ),
                      title: Text(t('settings.notif.time')),
                      subtitle: Text(
                        settings.reminderTime.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white38,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: settings.reminderTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.primaryLight,
                                  onPrimary: Colors.white,
                                  surface: AppTheme.darkCard,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          await settings.setReminderTime(picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notification Testing Cards
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(t('settings.notif.testInstant')),
                    subtitle: const Text('Dispara una notificación ahora mismo'),
                    trailing: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.amber,
                    ),
                    onTap: () async {
                      await settings.sendTestInstantNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('settings.notif.sentInstant')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.timer_outlined,
                      color: Colors.cyanAccent,
                    ),
                    title: Text(t('settings.notif.testScheduled')),
                    subtitle: const Text('Lanza notificación en 3, 2, 1...'),
                    trailing: const Icon(
                      Icons.schedule_rounded,
                      color: Colors.cyanAccent,
                    ),
                    onTap: () async {
                      await settings.sendTestScheduledNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('settings.notif.scheduledSent')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_suggest_rounded,
                      color: Colors.white70,
                    ),
                    title: Text(t('settings.notif.openSettings')),
                    subtitle: const Text('Abrir ajustes del sistema si fue rechazada'),
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white38,
                    ),
                    onTap: () async {
                      await settings.openNotificationSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              t('settings.dataGroup'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            // Reset Data
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error,
                ),
                title: Text(
                  t('settings.reset.title'),
                  style: const TextStyle(color: AppTheme.error),
                ),
                subtitle: Text(t('settings.reset.subtitle')),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.darkCard,
                      title: Text(t('settings.reset.dialog.title')),
                      content: Text(t('settings.reset.dialog.body')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(t('settings.reset.dialog.cancel')),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await flashcardProvider.resetAllData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t('settings.reset.success')),
                                ),
                              );
                            }
                          },
                          child: Text(
                            t('settings.reset.dialog.confirm'),
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            Text(
              t('settings.aboutGroup'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'EasyEnglish v1.0.0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aprende inglés con repetición espaciada inteligente y pronunciación nativa.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
