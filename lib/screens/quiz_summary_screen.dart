import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';
import 'suggestions_screen.dart';

class QuizSummaryScreen extends StatelessWidget {
  const QuizSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final flashcards = context.read<FlashcardProvider>();

    final int total = quiz.totalQuestions;
    final int correct = quiz.correctCount;
    final int incorrect = total - correct;
    final double percentage = total > 0 ? (correct / total) * 100 : 0;

    Color resultColor = AppTheme.primaryLight;
    String resultTitle = '¡Buen Trabajo!';
    String resultEmoji = '🎉';

    if (percentage >= 80) {
      resultColor = Colors.greenAccent;
      resultTitle = '¡Excelente Dominio!';
      resultEmoji = '🏆';
    } else if (percentage < 50) {
      resultColor = Colors.orangeAccent;
      resultTitle = '¡Sigue Practicando!';
      resultEmoji = '💪';
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Trophy / Medal Graphic
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: resultColor.withValues(alpha: 0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    resultEmoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                resultTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Has completado el quiz de ${quiz.totalQuestions} preguntas',
                style: const TextStyle(fontSize: 14, color: Colors.white60),
              ),

              const SizedBox(height: 30),

              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('PUNTUACIÓN', '${quiz.score}', Colors.amber, Icons.stars_rounded),
                    Container(width: 1, height: 40, color: Colors.white12),
                    _buildStatItem('PRECISIÓN', '${percentage.toStringAsFixed(0)}%', resultColor, Icons.percent_rounded),
                    Container(width: 1, height: 40, color: Colors.white12),
                    _buildStatItem('MEJOR RACHA', '${quiz.bestStreakInSession}', Colors.orangeAccent, Icons.local_fire_department_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                          const SizedBox(width: 8),
                          Text('$correct correctas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text('$incorrect falladas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (incorrect > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$incorrect ítems agregados a tus "Sugerencias" para repasar.',
                          style: const TextStyle(fontSize: 12, color: Colors.amberAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    quiz.startQuiz(allCards: flashcards.allCards);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Repetir Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (quiz.suggestions.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
                      );
                    },
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors.amberAccent),
                    label: Text(
                      'Ver Sugerencias (${quiz.pendingSuggestions.length} pendientes)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  quiz.exitQuiz();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Volver al Inicio', style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.white38),
        ),
      ],
    );
  }
}
