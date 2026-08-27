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

            // Item-Specific Notifications Section
            Text(
              t('settings.itemNotif.group'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t('settings.itemNotif.desc'),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 12),

            _buildItemNotificationCard(context, settings, flashcardProvider),
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

  Widget _buildItemNotificationCard(
    BuildContext context,
    SettingsProvider settings,
    FlashcardProvider flashcardProvider,
  ) {
    final t = settings.translate;
    final config = settings.itemNotificationConfig;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: config != null ? AppTheme.primaryLight.withValues(alpha: 0.5) : AppTheme.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: selected card info + toggle
          if (config == null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.push_pin_outlined,
                    color: Colors.white38,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('settings.itemNotif.noCard'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '→ Abre cualquier tarjeta y usa el botón 📌',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryLight.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            // Card pinned header
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryLight, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 20),
              ),
              title: Text(
                config.wordEn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '${config.wordEs}  •  ${config.examples.length} ${t('settings.itemNotif.examplesCount')}',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              trailing: Switch(
                value: config.isEnabled,
                activeThumbColor: AppTheme.primaryLight,
                onChanged: (val) => settings.toggleItemNotifications(val),
              ),
            ),

            if (config.isEnabled) ...[
              const Divider(color: AppTheme.darkBorder, height: 1),

              // Examples preview
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.rotate_right_rounded, size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    const Text(
                      'ROTACIÓN DE EJEMPLOS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: config.examples.length,
                itemBuilder: (ctx, i) {
                  final isCurrent = i == config.currentExampleIndex % config.examples.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.primaryLight.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? AppTheme.primaryLight.withValues(alpha: 0.4)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? AppTheme.primaryLight : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              config.examples[i],
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrent ? Colors.white : Colors.white70,
                                fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(Icons.notifications_active, size: 14, color: AppTheme.primaryLight),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              const Divider(color: AppTheme.darkBorder, height: 1),

              // Times section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: Colors.white38),
                        const SizedBox(width: 6),
                        const Text(
                          'HORARIOS DEL DÍA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppTheme.primaryLight,
                                onPrimary: Colors.white,
                                surface: AppTheme.darkCard,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          await settings.addItemNotificationTime(picked);
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(t('settings.itemNotif.addTime')),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryLight,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              config.times.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Sin horarios. Agrega al menos uno.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: config.times.length,
                      itemBuilder: (ctx, i) {
                        final slotTime = config.times[i];
                        final exampleIndex = (config.currentExampleIndex + i) % config.examples.length;
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.alarm_rounded, size: 18, color: AppTheme.accent),
                          ),
                          title: Text(
                            slotTime.format(context),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Ejemplo ${exampleIndex + 1}/${config.examples.length}: "${config.examples[exampleIndex].length > 50 ? '${config.examples[exampleIndex].substring(0, 50)}…' : config.examples[exampleIndex]}"',
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppTheme.error, size: 20),
                            onPressed: () => settings.removeItemNotificationTime(i),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 8),

              const Divider(color: AppTheme.darkBorder, height: 1),

              // Test button
              ListTile(
                leading: const Icon(Icons.science_rounded, color: Colors.purpleAccent),
                title: Text(t('settings.itemNotif.testNow')),
                subtitle: Text(
                  'Prueba el ejemplo #${(config.currentExampleIndex % config.examples.length) + 1} ahora mismo',
                ),
                trailing: const Icon(Icons.play_arrow_rounded, color: Colors.purpleAccent),
                onTap: () async {
                  await settings.sendTestItemNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📬 ${t('settings.notif.sentInstant')}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}
