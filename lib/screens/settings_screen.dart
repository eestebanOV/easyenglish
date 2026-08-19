import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/live_activity_service.dart';
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

            Text(
              t('settings.widgetGroup'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            // Live Activities Card
            _LiveActivitiesSettingsCard(t: t),
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
                    'Algoritmo de repetición espaciada SM-2 y Notificaciones Locales para iOS.',
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

class _LiveActivitiesSettingsCard extends StatefulWidget {
  final String Function(String) t;
  const _LiveActivitiesSettingsCard({required this.t});

  @override
  State<_LiveActivitiesSettingsCard> createState() =>
      _LiveActivitiesSettingsCardState();
}

class _LiveActivitiesSettingsCardState
    extends State<_LiveActivitiesSettingsCard> {
  final LiveActivityService _liveService = LiveActivityService();
  Map<String, dynamic>? _liveData;
  bool _isLoading = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _liveService.getActiveState();
    if (mounted) {
      setState(() {
        _liveData = data;
        _isLoading = false;
      });
    }
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes ${widget.t('widget.interval.min')}';
    if (minutes == 60) return '1 ${widget.t('widget.interval.hour')}';
    return '${minutes ~/ 60} ${widget.t('widget.interval.hours')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final hasWord =
        _liveData != null && (_liveData!['wordEn'] as String).isNotEmpty;
    final wordEn = _liveData?['wordEn'] ?? widget.t('widget.noWord.title');
    final wordEs = _liveData?['wordEs'] ?? '';
    final type = _liveData?['type'] ?? 'PHRASE';
    final interval = _liveData?['intervalMinutes'] as int? ?? 30;
    final List<String> examples =
        (_liveData?['examples'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: hasWord
              ? AppTheme.accent.withValues(alpha: 0.35)
              : AppTheme.darkBorder,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppTheme.accent,
                  size: 22,
                ),
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
                            hasWord ? wordEn : widget.t('widget.noWord.title'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasWord) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasWord && wordEs.isNotEmpty)
                      Text(
                        wordEs,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      )
                    else if (!hasWord)
                      Text(
                        widget.t('widget.noWord.hint'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              if (hasWord)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  tooltip: widget.t('widget.delete.hint'),
                  onPressed: () async {
                    await _liveService.stopDayLearning();
                    await _loadData();
                  },
                ),
            ],
          ),
          if (hasWord) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 14),

            // Interval Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.t('widget.interval'),
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                DropdownButton<int>(
                  value: interval,
                  underline: const SizedBox(),
                  dropdownColor: AppTheme.darkCard,
                  items: LiveActivityService.availableIntervals.map((mins) {
                    return DropdownMenuItem<int>(
                      value: mins,
                      child: Text(_formatInterval(mins)),
                    );
                  }).toList(),
                  onChanged: (newInterval) async {
                    if (newInterval != null) {
                      // Update interval setting
                      await _loadData();
                    }
                  },
                ),
              ],
            ),

            if (examples.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${examples.length} ${widget.t('widget.examplesRotary')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Test session button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting
                    ? null
                    : () async {
                        setState(() => _isTesting = true);
                        await _liveService.startSessionNow();
                        setState(() => _isTesting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: const Text(
                                '🔔 Notificación de prueba enviada inmediatamente.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(widget.t('widget.testSession')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  side: const BorderSide(color: AppTheme.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          // How it works note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.white54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.t('widget.tutorial'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
