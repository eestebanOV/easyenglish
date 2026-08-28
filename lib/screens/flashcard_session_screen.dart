import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confidence_buttons.dart';
import '../widgets/flashcard_widget.dart';

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
    final t = context.watch<SettingsProvider>().translate;

    if (_sessionCards.isEmpty) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: Text(widget.title ?? t('srs.title')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: context.isDark ? 0.15 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, size: 44, color: AppTheme.success),
                ),
                const SizedBox(height: 18),
                Text(
                  t('home.reviews.empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t('srs.finished.back')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isFinished) {
      return Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: context.isDark ? 0.15 : 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.emoji_events_rounded, size: 44, color: AppTheme.accent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('srs.finished.title'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t('srs.finished.subtitle')} ($_cardsReviewedInSession)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: context.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: Text(
                      t('srs.finished.back'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(widget.title ?? t('srs.title')),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progressRatio,
            backgroundColor: context.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
                    '${t('srs.steps')} ${_currentIndex + 1} / ${_sessionCards.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: context.isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.title ?? 'General',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
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
