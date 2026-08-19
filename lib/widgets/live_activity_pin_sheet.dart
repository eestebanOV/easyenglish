import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/live_activity_service.dart';
import '../theme/app_theme.dart';

/// Bottom sheet para configurar las NOTIFICACIONES LOCALES DIARIAS.
/// Histórico: originalmente gestionaba Live Activities, se renombró internamente la UI
/// pero se mantuvo el nombre de la clase/archivo por compatibilidad con el resto del código.
class LiveActivityPinSheet extends StatefulWidget {
  final Flashcard card;

  const LiveActivityPinSheet({
    super.key,
    required this.card,
  });

  static Future<bool?> show(BuildContext context, Flashcard card) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiveActivityPinSheet(card: card),
    );
  }

  @override
  State<LiveActivityPinSheet> createState() => _LiveActivityPinSheetState();
}

class _LiveActivityPinSheetState extends State<LiveActivityPinSheet> {
  final LiveActivityService _service = LiveActivityService();
  int _selectedInterval = 30;
  final int _startHour = 8;
  final int _endHour = 22;
  int _previewExampleIndex = 0;
  bool _isLoading = false;
  late List<String> _examples;

  @override
  void initState() {
    super.initState();
    _examples = widget.card.allExamples;
    if (_examples.length < 6) {
      _examples = [
        ..._examples,
        'Take time to practice using "${widget.card.wordEn}" naturally.',
        'Remember the meaning of "${widget.card.wordEn}" when speaking.',
        'Everyday focus: "${widget.card.wordEn}". Say it out loud.',
        'Try creating your own sentence with "${widget.card.wordEn}".',
      ];
    }
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 hora';
    } else {
      return '${minutes ~/ 60} horas';
    }
  }

  String _determineWordType() {
    if (widget.card.isVerbWithForms) return 'IRREGULAR VERB';
    final cat = widget.card.categoryId.toLowerCase();
    if (cat.contains('phrasal')) return 'PHRASAL VERB';
    if (cat.contains('phrase') || cat.contains('idiom') || cat.contains('conversation')) return 'PHRASE';
    if (cat.contains('verb')) return 'VERB';
    return 'VOCABULARY';
  }

  int get _estimatedNotificationsPerDay {
    final windowMinutes = (_endHour - _startHour) * 60;
    return (windowMinutes / _selectedInterval).floor() + 1;
  }

  Future<void> _activateNotifications() async {
    setState(() => _isLoading = true);
    final success = await _service.startDayLearning(
      widget.card,
      startHour: _startHour,
      endHour: _endHour,
      intervalMinutes: _selectedInterval,
      durationMinutes: 0,
      customExamples: _examples,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop(success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Notificaciones activadas para "${widget.card.wordEn}"!',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '~$_estimatedNotificationsPerDay notificaciones cada ${_formatInterval(_selectedInterval)} con ejemplos distintos.',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeExample = _examples[_previewExampleIndex % _examples.length];
    final wordType = _determineWordType();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppTheme.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificaciones Locales (iOS)',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'English Every Day • Aprendizaje espaciado sin cuenta Developer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'VISTA PREVIA DE LA NOTIFICACIÓN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF131B2A),
                    Color(0xFF0C101A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.35),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.accent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.card.wordEn,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${widget.card.wordEs}${widget.card.pronunciation.isNotEmpty ? '  ${widget.card.pronunciation}' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          wordType,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (widget.card.isVerbWithForms) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTensePill('PRESENT', widget.card.present ?? '', AppTheme.accent)),
                          const SizedBox(width: 6),
                          Expanded(child: _buildTensePill('PAST', widget.card.past ?? '', AppTheme.primaryLight)),
                          const SizedBox(width: 6),
                          Expanded(child: _buildTensePill('PARTICIPLE', widget.card.participle ?? '', AppTheme.accentOrange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'NOTIFICACIÓN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppTheme.accent,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Ej. ${_previewExampleIndex + 1}/${_examples.length}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.format_quote_rounded, size: 14, color: AppTheme.accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  activeExample,
                                  key: ValueKey(activeExample),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Cada ${_formatInterval(_selectedInterval)} • ~$_estimatedNotificationsPerDay/día',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _previewExampleIndex = (_previewExampleIndex + 1) % _examples.length;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                'Ver siguiente (${_previewExampleIndex + 1}/${_examples.length})',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Colors.lightBlueAccent),
                      SizedBox(width: 8),
                      Text(
                        '¿CÓMO FUNCIONA ESTE MÉTODO?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1. "${widget.card.wordEn}" será tu palabra de aprendizaje durante TODO el día (ítem fijo).\n'
                    '2. Cada ${_formatInterval(_selectedInterval)} recibirás una notificación LOCAL con un ejemplo NUEVO.\n'
                    '3. Los ejemplos rotan automáticamente por toda la lista hasta que termine el día.\n'
                    '4. Ventana: ${_startHour.toString().padLeft(2, '0')}:00 a ${_endHour.toString().padLeft(2, '0')}:00. No necesitas cuenta de pago ni push/APNs.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'FRECUENCIA DE LAS NOTIFICACIONES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: LiveActivityService.availableIntervals.map((mins) {
                final isSelected = _selectedInterval == mins;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedInterval = mins),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accent.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.accent : Colors.white12,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _formatInterval(mins),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                            if (mins == 30) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Estándar',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.accent : Colors.white38,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _activateNotifications,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.notifications_active_rounded, size: 22),
              label: Text(
                _isLoading ? 'Programando...' : 'Activar Notificaciones de Hoy',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTensePill(String tense, String value, Color color) {
    return Column(
      children: [
        Text(
          tense,
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
