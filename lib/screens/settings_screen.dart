import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final flashcardProvider = context.read<FlashcardProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Configuración'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'PREFERENCIAS DE ESTUDIO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
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
                leading: const Icon(Icons.track_changes_rounded, color: AppTheme.primaryLight),
                title: const Text('Meta diaria'),
                subtitle: Text('${settings.dailyGoal} palabras por día'),
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
                secondary: const Icon(Icons.volume_up_rounded, color: AppTheme.accent),
                title: const Text('Pronunciación automática'),
                subtitle: const Text('Audio por voz TTS nativo'),
                value: settings.soundEnabled,
                activeTrackColor: AppTheme.accent,
                onChanged: (val) => settings.toggleSound(val),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'LOCK SCREEN WIDGET (iOS)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),

            // Lock Screen Widget Card
            _LockScreenWidgetSettingsCard(),
            const SizedBox(height: 28),

            const Text(
              'DATOS Y ALMACENAMIENTO',
              style: TextStyle(
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
                leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                title: const Text(
                  'Reiniciar Progreso',
                  style: TextStyle(color: AppTheme.error),
                ),
                subtitle: const Text('Borrar historial y tarjetas aprendidas'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.darkCard,
                      title: const Text('¿Reiniciar todo el progreso?'),
                      content: const Text(
                        'Esta acción borrará tus rachas, estadísticas y nivel de dominio de todas las tarjetas.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await flashcardProvider.resetAllData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Progreso reiniciado correctamente'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Reiniciar',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'ACERCA DE',
              style: TextStyle(
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
                    'Algoritmo de repetición espaciada SM-2 con almacenamiento 100% local y offline.',
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

class _LockScreenWidgetSettingsCard extends StatefulWidget {
  @override
  State<_LockScreenWidgetSettingsCard> createState() => _LockScreenWidgetSettingsCardState();
}

class _LockScreenWidgetSettingsCardState extends State<_LockScreenWidgetSettingsCard> {
  final WidgetService _widgetService = WidgetService();
  Map<String, dynamic>? _widgetData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _widgetService.getActiveWidgetData();
    if (mounted) {
      setState(() {
        _widgetData = data;
        _isLoading = false;
      });
    }
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes min';
    if (minutes == 60) return '1 hora';
    return '${minutes ~/ 60} horas';
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

    final hasWord = _widgetData != null && (_widgetData!['wordEn'] as String).isNotEmpty;
    final wordEn = _widgetData?['wordEn'] ?? 'Ninguna palabra fijada';
    final wordEs = _widgetData?['wordEs'] ?? '';
    final interval = _widgetData?['interval'] as int? ?? 60;
    final List<String> examples = (_widgetData?['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.widgets_rounded, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasWord ? wordEn : 'Palabra del Día (Widget)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (hasWord && wordEs.isNotEmpty)
                      Text(
                        wordEs,
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      )
                    else if (!hasWord)
                      Text(
                        'Selecciona una palabra desde las categorías para mostrarla en tu iPhone',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                  ],
                ),
              ),
              if (hasWord)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 20),
                  tooltip: 'Quitar widget',
                  onPressed: () async {
                    await _widgetService.clearWidget();
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
                const Text('Cambio de ejemplo:', style: TextStyle(fontSize: 13, color: Colors.white70)),
                DropdownButton<int>(
                  value: interval,
                  underline: const SizedBox(),
                  dropdownColor: AppTheme.darkCard,
                  items: WidgetService.availableIntervals.map((mins) {
                    return DropdownMenuItem<int>(
                      value: mins,
                      child: Text(_formatInterval(mins)),
                    );
                  }).toList(),
                  onChanged: (newInterval) async {
                    if (newInterval != null) {
                      await _widgetService.updateInterval(newInterval);
                      await _loadData();
                    }
                  },
                ),
              ],
            ),

            if (examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${examples.length} ejemplos rotativos configurados',
                style: const TextStyle(fontSize: 11, color: AppTheme.accent),
              ),
            ],
          ],

          const SizedBox(height: 12),
          // How to add widget instruction note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 16, color: Colors.white54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para agregar: Mantén presionada la pantalla de bloqueo de tu iPhone > Personalizar > Agregar Widgets > EasyEnglish.',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
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

