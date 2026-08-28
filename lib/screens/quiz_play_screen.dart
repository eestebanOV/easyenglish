import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_summary_screen.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final flashcards = context.watch<FlashcardProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;
    final q = quiz.currentQuestion;

    if (quiz.isSessionFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const QuizSummaryScreen()),
          );
        }
      });
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (q == null || !quiz.isSessionActive) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const SizedBox.shrink(),
      );
    }

    final category = flashcards.getCategory(q.card.categoryId);
    final catColor = flashcards.getCategoryColor(q.card.categoryId);
    final double progress = quiz.totalQuestions > 0 ? (quiz.currentIndex + 1) / quiz.totalQuestions : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context, quiz, t);
        if (shouldPop && context.mounted) {
          quiz.exitQuiz();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: context.textPrimary),
            onPressed: () async {
              final shouldPop = await _showExitConfirmation(context, quiz, t);
              if (shouldPop && context.mounted) {
                quiz.exitQuiz();
                Navigator.of(context).pop();
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${t('quiz.questionCounter')} ${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimary),
              ),
              if (quiz.streak > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: AppTheme.accentAmber),
                      const SizedBox(width: 2),
                      Text(
                        '${quiz.streak}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(catColor),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badges: Question Type & Category Name & Timer
                      Row(
                        children: [
                          // 1. Question Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(q.type).withValues(alpha: context.isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getBadgeColor(q.type).withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  q.type.icon,
                                  size: 14,
                                  color: _getBadgeColor(q.type),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  q.type.displayNameEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: _getBadgeColor(q.type),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: context.isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: catColor.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category?.vectorIcon ?? Icons.folder_outlined,
                                  size: 14,
                                  color: catColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category?.name ?? q.card.categoryId,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: catColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // 3. Speed Timer (if applicable)
                          if (q.type == QuizQuestionType.speedQuiz)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: context.isDark ? 0.22 : 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_rounded, size: 14, color: AppTheme.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.timeRemaining}s',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Prompt text directly on scaffold background (no wrapping card)
                      Text(
                        q.prompt,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                      ),
                      if (q.subtitle != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.cardSecondary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: context.border),
                          ),
                          child: Text(
                            q.subtitle!,
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: context.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Question Interactive Body
                      if (q.type == QuizQuestionType.buildSentence)
                        _buildSentenceWidget(context, quiz, q, t)
                      else
                        _buildOptionsList(context, quiz, q),
                    ],
                  ),
                ),
              ),

              // Immediate Feedback Bottom Container
              if (quiz.isAnswered) _buildFeedbackContainer(context, quiz, q, t),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(QuizQuestionType type) {
    switch (type) {
      case QuizQuestionType.multipleChoice:
        return AppTheme.primary;
      case QuizQuestionType.buildSentence:
        return AppTheme.accent;
      case QuizQuestionType.speedQuiz:
        return AppTheme.accentAmber;
      case QuizQuestionType.situation:
        return AppTheme.accentPurple;
      case QuizQuestionType.findError:
        return AppTheme.accentPink;
    }
  }

  // --- Options List ---
  Widget _buildOptionsList(BuildContext context, QuizProvider quiz, QuizQuestion q) {
    return Column(
      children: q.options.map((option) {
        final bool isSelected = quiz.selectedAnswer == option;
        final bool isCorrect = option.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();

        Color bgColor = context.cardBg;
        Color borderColor = context.border;
        Widget? trailingIcon;

        if (quiz.isAnswered) {
          if (isCorrect) {
            bgColor = AppTheme.success.withValues(alpha: context.isDark ? 0.2 : 0.12);
            borderColor = AppTheme.success;
            trailingIcon = const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22);
          } else if (isSelected) {
            bgColor = AppTheme.error.withValues(alpha: context.isDark ? 0.2 : 0.12);
            borderColor = AppTheme.error;
            trailingIcon = const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 22);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: quiz.isAnswered ? null : () => quiz.submitAnswer(option),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (quiz.isAnswered && isCorrect) ? 1.8 : 1.0,
                ),
                boxShadow: isSelected ? null : context.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected || (quiz.isAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                        color: context.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  ?trailingIcon,
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Build Sentence Widget ---
  Widget _buildSentenceWidget(
    BuildContext context,
    QuizProvider quiz,
    QuizQuestion q,
    String Function(String) t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: quiz.isAnswered
                ? (quiz.isCorrect
                    ? AppTheme.success.withValues(alpha: context.isDark ? 0.15 : 0.1)
                    : AppTheme.error.withValues(alpha: context.isDark ? 0.15 : 0.1))
                : context.cardSecondary,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: quiz.isAnswered
                  ? (quiz.isCorrect ? AppTheme.success : AppTheme.error)
                  : AppTheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: quiz.builtSentence.isEmpty
              ? Center(
                  child: Text(
                    t('quiz.tapToOrder'),
                    style: TextStyle(color: context.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(quiz.builtSentence.length, (i) {
                    final word = quiz.builtSentence[i];
                    return ActionChip(
                      label: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      backgroundColor: AppTheme.primary,
                      side: BorderSide.none,
                      onPressed: quiz.isAnswered ? null : () => quiz.removeWordFromBuiltSentence(i),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 20),

        Text(
          t('quiz.availableWords'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(quiz.remainingScrambledWords.length, (i) {
            final word = quiz.remainingScrambledWords[i];
            return ActionChip(
              label: Text(
                word,
                style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary),
              ),
              backgroundColor: context.cardBg,
              side: BorderSide(color: context.border),
              onPressed: quiz.isAnswered ? null : () => quiz.addWordToBuiltSentence(i),
            );
          }),
        ),

        const SizedBox(height: 24),

        if (!quiz.isAnswered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: quiz.builtSentence.isNotEmpty ? () => quiz.submitBuiltSentence() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(t('quiz.checkSentence'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
      ],
    );
  }

  // --- Feedback Bottom Container ---
  Widget _buildFeedbackContainer(
    BuildContext context,
    QuizProvider quiz,
    QuizQuestion q,
    String Function(String) t,
  ) {
    final isCorrect = quiz.isCorrect;
    final color = isCorrect ? AppTheme.success : AppTheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.5), width: 2)),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                isCorrect ? t('quiz.correct') : t('quiz.incorrect'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => quiz.nextQuestion(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                quiz.currentIndex + 1 < quiz.totalQuestions
                    ? t('quiz.nextQuestion')
                    : t('quiz.viewResults'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(
    BuildContext context,
    QuizProvider quiz,
    String Function(String) t,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('quiz.exitTitle'), style: TextStyle(color: ctx.textPrimary)),
        content: Text(t('quiz.exitMessage'), style: TextStyle(color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('quiz.continue'), style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(t('quiz.exitButton')),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
