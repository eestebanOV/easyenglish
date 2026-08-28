import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_summary_screen.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final q = quiz.currentQuestion;

    if (quiz.isSessionFinished || q == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const QuizSummaryScreen()),
        );
      });
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryLight)),
      );
    }

    final double progress = (quiz.currentIndex + 1) / quiz.totalQuestions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context, quiz);
        if (shouldPop && context.mounted) {
          quiz.exitQuiz();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AppTheme.darkSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () async {
              if (await _showExitConfirmation(context, quiz)) {
                if (context.mounted) {
                  quiz.exitQuiz();
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pregunta ${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (quiz.streak > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orangeAccent),
                      const SizedBox(width: 2),
                      Text(
                        '${quiz.streak}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.score}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  minHeight: 4,
                ),
                if (q.type == QuizQuestionType.speedQuiz)
                  LinearProgressIndicator(
                    value: quiz.timeRemaining / q.timeLimitSeconds,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      quiz.timeRemaining <= 2 ? Colors.redAccent : Colors.orangeAccent,
                    ),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(q.type).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getBadgeColor(q.type).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  q.type.badgeLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: _getBadgeColor(q.type),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (q.type == QuizQuestionType.speedQuiz)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_rounded, size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.timeRemaining}s',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Prompt text
                      Text(
                        q.prompt,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      if (q.subtitle != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.darkBorder),
                          ),
                          child: Text(
                            q.subtitle!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Question Interactive Body
                      if (q.type == QuizQuestionType.buildSentence)
                        _buildSentenceWidget(context, quiz, q)
                      else
                        _buildOptionsList(context, quiz, q),
                    ],
                  ),
                ),
              ),

              // Immediate Feedback Bottom Sheet / Container
              if (quiz.isAnswered) _buildFeedbackContainer(context, quiz, q),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(QuizQuestionType type) {
    switch (type) {
      case QuizQuestionType.multipleChoice:
        return AppTheme.primaryLight;
      case QuizQuestionType.buildSentence:
        return AppTheme.accent;
      case QuizQuestionType.speedQuiz:
        return Colors.orangeAccent;
      case QuizQuestionType.situation:
        return Colors.purpleAccent;
      case QuizQuestionType.findError:
        return Colors.tealAccent;
    }
  }

  // --- Options List (Multiple Choice, Speed, Situation, Find Error) ---
  Widget _buildOptionsList(BuildContext context, QuizProvider quiz, QuizQuestion q) {
    return Column(
      children: q.options.map((option) {
        final bool isSelected = quiz.selectedAnswer == option;
        final bool isCorrect = option.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();

        Color bgColor = AppTheme.darkCard;
        Color borderColor = AppTheme.darkBorder;
        Widget? trailingIcon;

        if (quiz.isAnswered) {
          if (isCorrect) {
            bgColor = Colors.green.withValues(alpha: 0.2);
            borderColor = Colors.greenAccent;
            trailingIcon = const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22);
          } else if (isSelected) {
            bgColor = Colors.red.withValues(alpha: 0.2);
            borderColor = Colors.redAccent;
            trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 22);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: quiz.isAnswered ? null : () => quiz.submitAnswer(option),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: isSelected || (quiz.isAnswered && isCorrect) ? 1.8 : 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected || (quiz.isAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                        color: Colors.white,
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
  Widget _buildSentenceWidget(BuildContext context, QuizProvider quiz, QuizQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target Area (words placed so far)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: quiz.isAnswered
                ? (quiz.isCorrect ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15))
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: quiz.isAnswered
                  ? (quiz.isCorrect ? Colors.greenAccent : Colors.redAccent)
                  : AppTheme.primaryLight.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: quiz.builtSentence.isEmpty
              ? const Center(
                  child: Text(
                    'Toca las palabras abajo para ordenarlas aquí',
                    style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(quiz.builtSentence.length, (i) {
                    final word = quiz.builtSentence[i];
                    return ActionChip(
                      label: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      backgroundColor: AppTheme.primaryLight,
                      side: BorderSide.none,
                      onPressed: quiz.isAnswered ? null : () => quiz.removeWordFromBuiltSentence(i),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 20),

        // Word Bank
        const Text(
          'PALABRAS DISPONIBLES:',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white38),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(quiz.remainingScrambledWords.length, (i) {
            final word = quiz.remainingScrambledWords[i];
            return ActionChip(
              label: Text(word, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              backgroundColor: AppTheme.darkCard,
              side: const BorderSide(color: AppTheme.darkBorder),
              onPressed: quiz.isAnswered ? null : () => quiz.addWordToBuiltSentence(i),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Submit Button (only when sentence has words and not yet answered)
        if (!quiz.isAnswered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: quiz.builtSentence.isNotEmpty ? () => quiz.submitBuiltSentence() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Comprobar Oración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
      ],
    );
  }

  // --- Feedback Bottom Container ---
  Widget _buildFeedbackContainer(BuildContext context, QuizProvider quiz, QuizQuestion q) {
    final isCorrect = quiz.isCorrect;
    final color = isCorrect ? Colors.greenAccent : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.5), width: 2)),
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
                isCorrect ? '¡Excelente! Respuesta Correcta' : 'Respuesta Incorrecta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.35),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Text(
              '💡 Guardado en "Sugerencias" para que puedas repasarlo.',
              style: TextStyle(fontSize: 12, color: Colors.amberAccent.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => quiz.nextQuestion(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                quiz.currentIndex + 1 < quiz.totalQuestions ? 'Siguiente Pregunta ➔' : 'Ver Resultados 🏁',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context, QuizProvider quiz) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('¿Salir del Quiz?'),
        content: const Text('Si sales ahora, se perderá el progreso de esta sesión.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Continuar Quiz')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
