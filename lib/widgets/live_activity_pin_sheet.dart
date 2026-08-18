import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/live_activity_service.dart';
import '../theme/app_theme.dart';

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
  final LiveActivityService _liveService = LiveActivityService();
  int _selectedInterval = 30; // 30 minutes default
  final int _startHour = 8; // 8:00 AM
  final int _endHour = 22; // 10:00 PM
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

  Future<void> _activateLiveActivity() async {
    setState(() => _isLoading = true);
    final success = await _liveService.startDayLearning(
      widget.card,
      startHour: _startHour,
      endHour: _endHour,
      intervalMinutes: _selectedInterval,
      durationMinutes: 5,
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
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Live Activity activada para "${widget.card.wordEn}"!',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Aparecerá cada 30 min por 5 min con un ejemplo nuevo.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
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
            // Drag handle
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
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
                        'Live Activities (iOS)',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'English Every Day • Pantalla de Bloqueo e Isla Dinámica',
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

            // Live Activity UI Preview
            const Text(
              'VISTA PREVIA DE LA LIVE ACTIVITY (iOS)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
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
                  // Top bar
                  Row(
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      const Text(
                        'English Every Day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          wordType,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ej. ${_previewExampleIndex + 1}/${_examples.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main learning item (NEVER CHANGES)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.card.wordEn,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (widget.card.pronunciation.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.card.pronunciation,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        widget.card.wordEs,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  // Irregular verb tenses row
                  if (widget.card.isVerbWithForms) ...[
                    const SizedBox(height: 10),
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
                  ],

                  const SizedBox(height: 12),

                  // Example container (CHANGES PER SESSION)
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
                        const Text(
                          'EXAMPLE (Cambia en cada sesión)',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppTheme.accent,
                          ),
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

                  // Footer: Live countdown & next session switcher
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, size: 14, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      const Text(
                        '04:59',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
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
                                'Ver siguiente ejemplo (${_previewExampleIndex + 1}/${_examples.length})',
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

            // Important Rules Info Card
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
                    '1. "${widget.card.wordEn}" será tu palabra de aprendizaje durante TODO el día (no cambia).\n'
                    '2. Cada 30 min se activa una Live Activity de 5 min con un ejemplo nuevo.\n'
                    '3. Al terminar los 5 min se cierra automáticamente hasta la próxima sesión.',
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

            // Interval Selector
            const Text(
              'FRECUENCIA DE LAS SESIONES',
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

            // Action Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _activateLiveActivity,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt_rounded, size: 22),
              label: Text(
                _isLoading ? 'Activando...' : 'Activar Live Activities de Hoy',
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
