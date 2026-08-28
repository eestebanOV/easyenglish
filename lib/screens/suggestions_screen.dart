import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/quiz_suggestion.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flashcard_widget.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  String _filter = 'pending'; // 'pending', 'all', 'resolved'
  final TtsService _ttsService = TtsService();

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final flashcards = context.watch<FlashcardProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;

    List<QuizSuggestion> displayed = quiz.suggestions;
    if (_filter == 'pending') {
      displayed = quiz.pendingSuggestions;
    } else if (_filter == 'resolved') {
      displayed = quiz.resolvedSuggestions;
    }

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: AppTheme.accentAmber, size: 22),
            const SizedBox(width: 8),
            Text(
              t('suggestions.title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          if (quiz.suggestions.isNotEmpty)
            IconButton(
              tooltip: t('suggestions.clearAll.title'),
              icon: Icon(Icons.delete_sweep_outlined, color: context.textSecondary),
              onPressed: () => _confirmClearAll(context, quiz, t),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: context.surface,
              child: Row(
                children: [
                  _buildFilterChip('${t('suggestions.filter.pending')} (${quiz.pendingSuggestions.length})', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('${t('suggestions.filter.all')} (${quiz.suggestions.length})', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('${t('suggestions.filter.resolved')} (${quiz.resolvedSuggestions.length})', 'resolved'),
                ],
              ),
            ),

            // Suggestions List or Empty State
            Expanded(
              child: displayed.isEmpty
                  ? _buildEmptyState(context, t)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayed.length,
                      itemBuilder: (ctx, i) {
                        final item = displayed[i];
                        final card = flashcards.allCards.firstWhere(
                          (c) => c.id == item.cardId,
                          orElse: () => Flashcard(
                            id: item.cardId,
                            wordEn: item.wordEn,
                            wordEs: item.wordEs,
                            pronunciation: '',
                            example: item.example,
                            exampleEs: item.exampleEs,
                            categoryId: item.categoryId,
                            structure: item.grammarFormula,
                          ),
                        );
                        return _buildSuggestionCard(context, quiz, item, card, t);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _filter == value;
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
      backgroundColor: context.cardBg,
      side: BorderSide(color: isSelected ? AppTheme.primary : context.border),
      onSelected: (sel) {
        if (sel) {
          setState(() {
            _filter = value;
          });
        }
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    QuizProvider quiz,
    QuizSuggestion item,
    Flashcard card,
    String Function(String) t,
  ) {
    final category = context
        .read<FlashcardProvider>()
        .categories
        .firstWhere((c) => c.id == item.categoryId, orElse: () => context.read<FlashcardProvider>().categories.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: item.isResolved
              ? AppTheme.success.withValues(alpha: 0.4)
              : context.border,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.wordEn,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.primary),
                            onPressed: () => _ttsService.speak(item.wordEn),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        item.wordEs,
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Fail count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.failCount > 1
                        ? AppTheme.error.withValues(alpha: context.isDark ? 0.2 : 0.1)
                        : AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.failCount > 1
                          ? AppTheme.error.withValues(alpha: 0.4)
                          : AppTheme.accentAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: item.failCount > 1 ? AppTheme.error : AppTheme.accentAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${t('suggestions.failedTimes')} ${item.failCount}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.failCount > 1 ? AppTheme.error : AppTheme.accentAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Example Box
          if (item.example.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${item.example}”',
                      style: TextStyle(fontSize: 13, color: context.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    if (item.exampleEs.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.exampleEs,
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Grammar Formula Badge if present
          if (item.grammarFormula != null && item.grammarFormula!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: context.isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.architecture_rounded, size: 14, color: AppTheme.accentPurple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${t('suggestions.formula')}: ${item.grammarFormula}',
                        style: TextStyle(fontSize: 11, color: context.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Divider(color: context.border, height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Review Flashcard Button
                TextButton.icon(
                  onPressed: () => _openCardModal(context, card, category),
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: Text(t('suggestions.reviewCard'), style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),

                Row(
                  children: [
                    // Mark as Resolved
                    IconButton(
                      tooltip: item.isResolved ? t('suggestions.markPending') : t('suggestions.markResolved'),
                      icon: Icon(
                        item.isResolved ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                        color: item.isResolved ? AppTheme.success : context.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => quiz.toggleSuggestionResolved(item.cardId),
                    ),
                    // Delete
                    IconButton(
                      tooltip: t('suggestions.delete'),
                      icon: Icon(Icons.close_rounded, color: context.textSecondary, size: 20),
                      onPressed: () => quiz.removeSuggestion(item.cardId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCardModal(BuildContext context, Flashcard card, dynamic category) {
    bool isFlipped = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: context.border),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.nameEs,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: category.color,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FlashcardWidget(
                        card: card,
                        isFlipped: isFlipped,
                        onFlip: () {
                          setModalState(() {
                            isFlipped = !isFlipped;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String Function(String) t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.12 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, size: 36, color: AppTheme.accentAmber),
            ),
            const SizedBox(height: 18),
            Text(
              t('suggestions.empty.title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              t('suggestions.empty.body'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, QuizProvider quiz, String Function(String) t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(t('suggestions.clearAll.title'), style: TextStyle(color: context.textPrimary)),
        content: Text(t('suggestions.clearAll.body'), style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('suggestions.clearAll.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('suggestions.clearAll.confirm'), style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await quiz.clearAllSuggestions();
    }
  }
}
