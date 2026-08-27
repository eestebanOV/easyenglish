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
    return _ItemNotificationAccordion(
      settings: settings,
      flashcardProvider: flashcardProvider,
    );
  }
}

class _ItemNotificationAccordion extends StatefulWidget {
  final SettingsProvider settings;
  final FlashcardProvider flashcardProvider;

  const _ItemNotificationAccordion({
    required this.settings,
    required this.flashcardProvider,
  });

  @override
  State<_ItemNotificationAccordion> createState() => _ItemNotificationAccordionState();
}

class _ItemNotificationAccordionState extends State<_ItemNotificationAccordion> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final t = settings.translate;
    final config = settings.itemNotificationConfig;

    if (config == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 10),
            Text(
              '→ Abre cualquier tarjeta de cualquier categoría y usa el botón 📌',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryLight.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: config.isEnabled ? AppTheme.primaryLight.withValues(alpha: 0.5) : AppTheme.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsible Header (Accordion)
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                config.wordEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (config.hasGrammarFormula) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.architecture_rounded, size: 11, color: Colors.purpleAccent),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fórmula',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purpleAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${config.wordEs}  •  ${config.times.length} ${t('settings.itemNotif.slotsSummary')}',
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: config.isEnabled,
                    activeThumbColor: AppTheme.primaryLight,
                    onChanged: (val) => settings.toggleItemNotifications(val),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded && config.isEnabled) ...[
            const Divider(color: AppTheme.darkBorder, height: 1),

            // Grammar Formula Section (Conditional for Tiempos Verbales)
            if (config.hasGrammarFormula) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.architecture_rounded, size: 15, color: Colors.purpleAccent),
                          SizedBox(width: 6),
                          Text(
                            'ESTRUCTURA / GRAMMAR FORMULA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        config.grammarFormula!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '✓ Se incluirá automáticamente en todas las notificaciones de este ítem.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppTheme.darkBorder, height: 1),
            ],

            // Auto-Generation & Interval Selector Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_mode_rounded, size: 14, color: Colors.white38),
                          const SizedBox(width: 6),
                          Text(
                            t('settings.itemNotif.autoGenerate').toUpperCase(),
                            style: const TextStyle(
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
                          final initialTime = config.times.isNotEmpty
                              ? config.times.first
                              : const TimeOfDay(
                                  hour: AppConstants.notificationDefaultStartHour,
                                  minute: AppConstants.notificationDefaultStartMinute,
                                );
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
                            helpText: 'HORA DE INICIO DEL DÍA',
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
                            await settings.generateAutoTimes(
                              startTime: picked,
                              intervalMinutes: config.intervalMinutes,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '⏰ Horarios generados cada ${config.intervalMinutes} min desde ${picked.format(context)}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: Text(
                          t('settings.itemNotif.regenerate'),
                          style: const TextStyle(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryLight,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Interval selection chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: AppConstants.notificationIntervalOptions.map((interval) {
                      final isSelected = config.intervalMinutes == interval;
                      final label = interval >= 60 ? '${interval ~/ 60} h' : '$interval min';
                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryLight,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryLight : Colors.white12,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            settings.updateItemNotificationInterval(interval);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

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
                      Text(
                        'HORARIOS DEL DÍA (${config.times.length})',
                        style: const TextStyle(
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
                      'Sin horarios. Agrega al menos uno o regenera automáticamente.',
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
                          'Ejemplo ${exampleIndex + 1}/${config.examples.length}: "${config.examples[exampleIndex].length > 45 ? '${config.examples[exampleIndex].substring(0, 45)}…' : config.examples[exampleIndex]}"',
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit time slot button
                            IconButton(
                              tooltip: t('settings.itemNotif.editTime'),
                              icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryLight, size: 18),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: slotTime,
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
                                  await settings.updateItemNotificationTime(i, picked);
                                }
                              },
                            ),
                            // Delete time slot button
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.close_rounded, color: AppTheme.error, size: 18),
                              onPressed: () => settings.removeItemNotificationTime(i),
                            ),
                          ],
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
                config.hasGrammarFormula
                    ? 'Prueba la fórmula + ejemplo #${(config.currentExampleIndex % config.examples.length) + 1}'
                    : 'Prueba el ejemplo #${(config.currentExampleIndex % config.examples.length) + 1}',
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
      ),
    );
  }
}
