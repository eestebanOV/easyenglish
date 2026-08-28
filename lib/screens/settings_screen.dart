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
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(t('settings.title')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // --- APPEARANCE & THEME GROUP ---
            Text(
              t('settings.themeGroup'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        t('settings.theme.title'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3-way Theme Mode Segmented Selector
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeModeOption(
                          context: context,
                          label: t('settings.theme.light'),
                          icon: Icons.light_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () => settings.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeModeOption(
                          context: context,
                          label: t('settings.theme.dark'),
                          icon: Icons.dark_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () => settings.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeModeOption(
                          context: context,
                          label: t('settings.theme.system'),
                          icon: Icons.brightness_auto_rounded,
                          isSelected: settings.themeMode == ThemeMode.system,
                          onTap: () => settings.setThemeMode(ThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- STUDY PREFERENCES GROUP ---
            Text(
              t('settings.studyGroup'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Language Selector
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.translate_rounded,
                  color: AppTheme.primary,
                ),
                title: Text(
                  t('settings.language.title'),
                  style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  t('settings.language.subtitle'),
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                trailing: DropdownButton<String>(
                  value: settings.languageCode,
                  underline: const SizedBox(),
                  dropdownColor: context.cardBg,
                  style: TextStyle(color: context.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'es',
                      child: Text('Español'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text('English'),
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
            const SizedBox(height: 10),

            // Daily Goal Selector
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.track_changes_rounded,
                  color: AppTheme.primary,
                ),
                title: Text(
                  t('settings.dailyGoal'),
                  style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  '${settings.dailyGoal} ${t('settings.dailyGoal.subtitle')}',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                trailing: DropdownButton<int>(
                  value: settings.dailyGoal,
                  underline: const SizedBox(),
                  dropdownColor: context.cardBg,
                  style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 10),

            // Audio Pronunciation Toggle
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.volume_up_rounded,
                  color: AppTheme.accent,
                ),
                title: Text(
                  t('settings.sound.title'),
                  style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  t('settings.sound.subtitle'),
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                value: settings.soundEnabled,
                activeTrackColor: AppTheme.accent,
                onChanged: (val) => settings.toggleSound(val),
              ),
            ),
            const SizedBox(height: 24),

            // --- NOTIFICATIONS GROUP ---
            Text(
              t('settings.notifGroup'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Daily Reminder Switch
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      t('settings.notif.title'),
                      style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      t('settings.notif.subtitle'),
                      style: TextStyle(color: context.textSecondary, fontSize: 12),
                    ),
                    value: settings.notificationsEnabled,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (val) => settings.toggleNotifications(val),
                  ),
                  if (settings.notificationsEnabled) ...[
                    Divider(color: context.border, height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.access_time_rounded,
                        color: AppTheme.accent,
                      ),
                      title: Text(
                        t('settings.notif.time'),
                        style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        settings.reminderTime.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: context.textSecondary,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: settings.reminderTime,
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
            const SizedBox(height: 24),

            // --- PINNED ITEM NOTIFICATIONS GROUP ---
            Text(
              t('settings.itemNotif.group'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t('settings.itemNotif.desc'),
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            _buildItemNotificationCard(context, settings, flashcardProvider),
            const SizedBox(height: 24),

            // --- DATA GROUP ---
            Text(
              t('settings.dataGroup'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Reset Data
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error,
                ),
                title: Text(
                  t('settings.reset.title'),
                  style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(t('settings.reset.subtitle'), style: TextStyle(color: context.textSecondary, fontSize: 12)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.cardBg,
                      title: Text(t('settings.reset.dialog.title'), style: TextStyle(color: context.textPrimary)),
                      content: Text(t('settings.reset.dialog.body'), style: TextStyle(color: context.textSecondary)),
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
            const SizedBox(height: 24),

            // --- ABOUT GROUP ---
            Text(
              t('settings.aboutGroup'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: context.border),
                boxShadow: context.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EasyEnglish v1.0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aprende inglés con repetición espaciada inteligente y pronunciación nativa.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
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

  Widget _buildThemeModeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : context.cardSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : context.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          color: context.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: context.border),
          boxShadow: context.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.push_pin_outlined,
                  color: context.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('settings.itemNotif.noCard'),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final catColor = widget.flashcardProvider.getCategoryColor(config.categoryId);

    return Container(
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: context.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: config.isEnabled
              ? catColor.withValues(alpha: context.isDark ? 0.40 : 0.25)
              : context.border,
          width: 1.2,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Summary Row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: config.isEnabled
                          ? AppTheme.primary.withValues(alpha: context.isDark ? 0.2 : 0.1)
                          : context.cardSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.push_pin_rounded,
                      color: config.isEnabled ? AppTheme.primary : context.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.wordEn,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${config.wordEs} • ${config.times.length} ${t('settings.itemNotif.slotsSummary')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: config.isEnabled,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (val) => settings.toggleItemNotificationEnabled(val),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded && config.isEnabled) ...[
            Divider(color: context.border, height: 1),

            // Grammar Formula Section
            if (config.hasGrammarFormula) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: context.isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.architecture_rounded, size: 15, color: AppTheme.accentPurple),
                          SizedBox(width: 6),
                          Text(
                            'ESTRUCTURA / GRAMMAR FORMULA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        config.grammarFormula!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: context.border, height: 1),
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
                          Icon(Icons.auto_mode_rounded, size: 14, color: context.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            t('settings.itemNotif.autoGenerate').toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: context.textSecondary,
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
                          );
                          if (picked != null) {
                            await settings.updateItemNotificationStartTime(picked);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Horarios generados cada ${config.intervalMinutes} min desde ${picked.format(context)}',
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
                          foregroundColor: AppTheme.primary,
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
                            color: isSelected ? Colors.white : context.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: context.cardSecondary,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : context.border,
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

            Divider(color: context.border, height: 1),

            // Time slots header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HORARIOS ACTIVOS (${config.times.length})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: context.textSecondary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 12, minute: 0),
                      );
                      if (picked != null) {
                        await settings.addItemNotificationTime(picked);
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(t('settings.itemNotif.addTime')),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

            config.times.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Sin horarios. Agrega al menos uno o regenera automáticamente.',
                      style: TextStyle(fontSize: 12, color: AppTheme.accentAmber),
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: context.isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.alarm_rounded, size: 18, color: AppTheme.accent),
                        ),
                        title: Text(
                          slotTime.format(context),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimary),
                        ),
                        subtitle: Text(
                          'Ejemplo ${exampleIndex + 1}/${config.examples.length}: "${config.examples[exampleIndex].length > 40 ? '${config.examples[exampleIndex].substring(0, 40)}…' : config.examples[exampleIndex]}"',
                          style: TextStyle(fontSize: 11, color: context.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: t('settings.itemNotif.editTime'),
                              icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 18),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: slotTime,
                                );
                                if (picked != null) {
                                  await settings.updateItemNotificationTimeSlot(i, picked);
                                }
                              },
                            ),
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

            Divider(color: context.border, height: 1),

            // Test button
            ListTile(
              leading: const Icon(Icons.science_rounded, color: AppTheme.accentPurple),
              title: Text(
                t('settings.itemNotif.testNow'),
                style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                'Prueba el ejemplo #${(config.currentExampleIndex % config.examples.length) + 1}',
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.play_arrow_rounded, color: AppTheme.accentPurple),
              onTap: () async {
                await settings.sendTestItemNotification();
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
          ],
        ],
      ),
    );
  }
}
