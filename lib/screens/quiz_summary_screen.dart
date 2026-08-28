import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';
import 'suggestions_screen.dart';

class QuizSummaryScreen extends StatelessWidget {
  const QuizSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final flashcards = context.read<FlashcardProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;

    final int total = quiz.totalQuestions;
    final int correct = quiz.correctCount;
    final int incorrect = total - correct;
    final double percentage = total > 0 ? (correct / total) * 100 : 0;

    Color resultColor = AppTheme.primary;
    String resultTitle = t('quiz.results.good');
    IconData resultIcon = Icons.thumb_up_rounded;

    if (percentage >= 80) {
      resultColor = AppTheme.success;
      resultTitle = t('quiz.results.great');
      resultIcon = Icons.emoji_events_rounded;
    } else if (percentage < 50) {
      resultColor = AppTheme.accentAmber;
      resultTitle = t('quiz.results.practice');
      resultIcon = Icons.trending_up_rounded;
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Trophy / Medal Vector Graphic
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: context.isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: resultColor.withValues(alpha: 0.35), width: 2),
                ),
                child: Center(
                  child: Icon(
                    resultIcon,
                    color: resultColor,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                resultTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: resultColor),
              ),
              const SizedBox(height: 6),
              Text(
                '${t('quiz.results.subtitle')} ${quiz.totalQuestions} ${t('quiz.questionsUnit')}',
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),

              const SizedBox(height: 28),

              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: context.border),
                  boxShadow: context.cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, t('quiz.results.score'), '${quiz.score}', AppTheme.accentAmber, Icons.stars_rounded),
                    Container(width: 1, height: 38, color: context.border),
                    _buildStatItem(context, t('quiz.results.accuracy'), '${percentage.toStringAsFixed(0)}%', resultColor, Icons.percent_rounded),
                    Container(width: 1, height: 38, color: context.border),
                    _buildStatItem(context, t('quiz.results.bestStreak'), '${quiz.bestStreakInSession}', AppTheme.primary, Icons.local_fire_department_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Summary Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: context.border),
                  boxShadow: context.cardShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$correct ${t('quiz.results.correctCount')}',
                            style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$incorrect ${t('quiz.results.incorrectCount')}',
                            style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600),
                          ),
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
                    color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppTheme.accentAmber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$incorrect ${t('quiz.results.itemsSaved')}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accentAmber),
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
                  label: Text(t('quiz.results.retry'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    elevation: 0,
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
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppTheme.accentAmber),
                    label: Text(
                      '${t('quiz.results.viewSuggestions')} (${quiz.pendingSuggestions.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.accentAmber.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  quiz.exitQuiz();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(t('quiz.results.backHome'), style: TextStyle(color: context.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color, IconData icon) {
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
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
