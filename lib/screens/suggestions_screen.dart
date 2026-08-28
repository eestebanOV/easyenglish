import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/quiz_suggestion.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
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

    List<QuizSuggestion> displayed = quiz.suggestions;
    if (_filter == 'pending') {
      displayed = quiz.pendingSuggestions;
    } else if (_filter == 'resolved') {
      displayed = quiz.resolvedSuggestions;
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'Sugerencias de Repaso',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          if (quiz.suggestions.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar todo el historial',
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white60),
              onPressed: () => _confirmClearAll(context, quiz),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.darkSurface,
              child: Row(
                children: [
                  _buildFilterChip('Pendientes (${quiz.pendingSuggestions.length})', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Todas (${quiz.suggestions.length})', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dominadas (${quiz.resolvedSuggestions.length})', 'resolved'),
                ],
              ),
            ),

            // Suggestions List or Empty State
            Expanded(
              child: displayed.isEmpty
                  ? _buildEmptyState()
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
                        return _buildSuggestionCard(context, quiz, item, card);
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
          color: isSelected ? Colors.white : Colors.white60,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryLight,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      side: BorderSide(color: isSelected ? AppTheme.primaryLight : Colors.white12),
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
  ) {
    final category = context
        .read<FlashcardProvider>()
        .categories
        .firstWhere((c) => c.id == item.categoryId, orElse: () => context.read<FlashcardProvider>().categories.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isResolved
              ? Colors.greenAccent.withValues(alpha: 0.3)
              : AppTheme.primaryLight.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
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
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.accent),
                            onPressed: () => _ttsService.speak(item.wordEn),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        item.wordEs,
                        style: const TextStyle(fontSize: 13, color: Colors.white60),
                      ),
                    ],
                  ),
                ),

                // Fail count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.failCount > 1
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.failCount > 1
                          ? Colors.redAccent.withValues(alpha: 0.5)
                          : Colors.orangeAccent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: item.failCount > 1 ? Colors.redAccent : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Fallado ${item.failCount}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.failCount > 1 ? Colors.redAccent : Colors.orangeAccent,
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
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${item.example}”',
                      style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    if (item.exampleEs.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.exampleEs,
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
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
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.architecture_rounded, size: 14, color: Colors.purpleAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Fórmula: ${item.grammarFormula}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(color: AppTheme.darkBorder, height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Review Flashcard Button
                TextButton.icon(
                  onPressed: () => _openCardModal(context, card, category),
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text('Repasar Tarjeta', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),

                Row(
                  children: [
                    // Mark as Resolved
                    IconButton(
                      tooltip: item.isResolved ? 'Marcar como pendiente' : 'Marcar como dominado',
                      icon: Icon(
                        item.isResolved ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                        color: item.isResolved ? Colors.greenAccent : Colors.white38,
                        size: 20,
                      ),
                      onPressed: () => quiz.toggleSuggestionResolved(item.cardId),
                    ),
                    // Delete
                    IconButton(
                      tooltip: 'Eliminar sugerencia',
                      icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
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
                decoration: const BoxDecoration(
                  color: AppTheme.darkBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          color: Colors.white24,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, size: 40, color: Colors.amberAccent),
            ),
            const SizedBox(height: 18),
            const Text(
              '¡Sin sugerencias pendientes!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando falles preguntas en los Quizzes, aparecerán aquí para que puedas repasarlas y dominarlas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, QuizProvider quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('¿Limpiar todas las sugerencias?'),
        content: const Text('Se borrará la lista de ítems recomendados para repasar.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpiar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await quiz.clearAllSuggestions();
    }
  }
}
