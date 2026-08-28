import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/quiz_question.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';

class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcards = context.watch<FlashcardProvider>();
    final quiz = context.watch<QuizProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;

    final allCategories = flashcards.categories;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.quiz_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              t('quiz.title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Category Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('quiz.categories'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: context.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (quiz.selectedCategoryIds.length == allCategories.length) {
                        quiz.toggleCategory(allCategories.first.id);
                      } else {
                        quiz.selectAllCategories(allCategories.map((c) => c.id).toList());
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      quiz.selectedCategoryIds.length == allCategories.length
                          ? t('quiz.deselect')
                          : t('quiz.selectAll'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allCategories.map((cat) {
                  final bool isSelected = quiz.selectedCategoryIds.contains(cat.id);
                  final cardCount = flashcards.allCards.where((c) => c.categoryId == cat.id).length;

                  return FilterChip(
                    label: Text(
                      '${cat.nameEs} ($cardCount)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : context.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: context.cardBg,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : context.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    avatar: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    onSelected: (val) {
                      quiz.toggleCategory(cat.id);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 2. Question Types
              Text(
                t('quiz.typeHeader'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              _buildTypeSelector(context, quiz, t),

              const SizedBox(height: 24),

              // 3. Quiz Size / Length
              Text(
                t('quiz.sizeHeader'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: AppConstants.quizSizeOptions.map((size) {
                  final isSelected = quiz.selectedQuizSize == size;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => quiz.setQuizSize(size),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : context.cardBg,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : context.border,
                            ),
                            boxShadow: isSelected ? null : context.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$size',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t('quiz.questionsUnit'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Launch Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    quiz.startQuiz(allCards: flashcards.allCards);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text(
                    '${t('quiz.start')} (${quiz.selectedQuizSize} ${t('quiz.questionsUnit')})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info note linking to suggestions tab
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppTheme.accentAmber),
                  const SizedBox(width: 6),
                  Text(
                    t('quiz.infoNote'),
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                  Text(
                    t('nav.suggestions'),
                    style: const TextStyle(fontSize: 11, color: AppTheme.accentAmber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, QuizProvider quiz, String Function(String) t) {
    final List<Map<String, dynamic>> types = [
      {
        'type': null,
        'icon': Icons.shuffle_rounded,
        'title': t('quiz.type.mixed'),
        'subtitle': t('quiz.type.mixedDesc'),
      },
      {
        'type': QuizQuestionType.multipleChoice,
        'icon': Icons.radio_button_checked_rounded,
        'title': t('quiz.type.multipleChoice'),
        'subtitle': t('quiz.type.multipleChoiceDesc'),
      },
      {
        'type': QuizQuestionType.buildSentence,
        'icon': Icons.sort_rounded,
        'title': t('quiz.type.buildSentence'),
        'subtitle': t('quiz.type.buildSentenceDesc'),
      },
      {
        'type': QuizQuestionType.speedQuiz,
        'icon': Icons.bolt_rounded,
        'title': t('quiz.type.speedQuiz'),
        'subtitle': t('quiz.type.speedQuizDesc'),
      },
      {
        'type': QuizQuestionType.situation,
        'icon': Icons.chat_bubble_outline_rounded,
        'title': t('quiz.type.situation'),
        'subtitle': t('quiz.type.situationDesc'),
      },
      {
        'type': QuizQuestionType.findError,
        'icon': Icons.find_replace_rounded,
        'title': t('quiz.type.findError'),
        'subtitle': t('quiz.type.findErrorDesc'),
      },
    ];

    return Column(
      children: types.map((item) {
        final QuizQuestionType? type = item['type'] as QuizQuestionType?;
        final IconData icon = item['icon'] as IconData;
        final isSelected = quiz.selectedQuestionType == type;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => quiz.setQuestionType(type),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: context.isDark ? 0.15 : 0.08)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : context.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected ? null : context.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : context.cardSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected ? AppTheme.primary : context.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(fontSize: 11, color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : context.textSecondary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
