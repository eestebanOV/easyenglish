import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confidence_buttons.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/live_activity_pin_sheet.dart';

class FlashcardSessionScreen extends StatefulWidget {
  final String? categoryId;
  final String? title;

  const FlashcardSessionScreen({
    super.key,
    this.categoryId,
    this.title,
  });

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen> {
  List<Flashcard> _sessionCards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _cardsReviewedInSession = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FlashcardProvider>();
    _sessionCards = provider.getDueCards(
      categoryId: widget.categoryId,
      limit: 15,
    );
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _rateCard(int quality) async {
    final currentCard = _sessionCards[_currentIndex];
    final provider = context.read<FlashcardProvider>();

    await provider.recordCardReview(currentCard.id, quality);
    _cardsReviewedInSession++;

    if (_currentIndex < _sessionCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Sesión de Estudio'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  '¡Todo al día!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Has completado todas las tarjetas pendientes por ahora. ¡Vuelve más tarde para tu próxima sesión!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver al Inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isFinished) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Sesión Completada!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Repasaste $_cardsReviewedInSession tarjetas con éxito.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.darkBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentCard = _sessionCards[_currentIndex];
    final progressRatio = (_currentIndex + 1) / _sessionCards.length;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(widget.title ?? 'Sesión de Estudio'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded),
            tooltip: 'Live Activity del Día',
            onPressed: () {
              LiveActivityPinSheet.show(context, currentCard);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progressRatio,
            backgroundColor: AppTheme.darkBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarjeta ${_currentIndex + 1} de ${_sessionCards.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.title ?? 'General',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Center(
                  child: FlashcardWidget(
                    key: ValueKey(currentCard.id),
                    card: currentCard,
                    isFlipped: _isFlipped,
                    onFlip: _flipCard,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _isFlipped ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_isFlipped,
                child: ConfidenceButtons(
                  onRate: _rateCard,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
