import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_badge.dart';
import 'category_detail_screen.dart';
import 'flashcard_session_screen.dart';
import 'quiz_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final t = settingsProvider.translate;

    if (flashcardProvider.isLoading) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final stats = flashcardProvider.stats;
    final dueCards = flashcardProvider.getDueCards();
    final categories = flashcardProvider.categories;
    final dailyGoal = settingsProvider.dailyGoal;
    final progress = stats.reviewsToday / (dailyGoal > 0 ? dailyGoal : 1);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('home.greeting'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        t('home.learnToday'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  StreakBadge(
                    streakDays: stats.streakDays,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: context.border),
                  boxShadow: context.cardShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('home.dailyGoal'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dueCards.isNotEmpty
                                ? '${dueCards.length} ${t('home.dueCards')}'
                                : t('home.goalDone'),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlashcardSessionScreen(
                                    title: t('srs.title'),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: Text(
                              dueCards.isNotEmpty ? t('home.startReview') : t('home.practiceMore'),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ProgressRing(
                      progress: progress,
                      current: stats.reviewsToday,
                      total: dailyGoal,
                      label: t('home.dailyGoal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      icon: Icons.check_circle_outline_rounded,
                      title: t('home.learned'),
                      value: '${flashcardProvider.totalLearnedCount}',
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      icon: Icons.star_rounded,
                      title: t('home.mastered'),
                      value: '${flashcardProvider.totalMasteredCount}',
                      color: AppTheme.accentAmber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      icon: Icons.layers_rounded,
                      title: t('home.totalCards'),
                      value: '${flashcardProvider.allCards.length}',
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quiz Challenge Card
              InkWell(
                onTap: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(2); // Navigate to Quiz Tab
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppTheme.darkCardSecondary : const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: AppTheme.accentPurple.withValues(alpha: context.isDark ? 0.35 : 0.25),
                    ),
                    boxShadow: context.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(Icons.quiz_rounded, color: AppTheme.accentPurple, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('home.quizChallenge.title'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t('home.quizChallenge.desc'),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: context.textSecondary.withValues(alpha: 0.6),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('home.categoriesTitle'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: Text(
                      t('home.viewAll'),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Category List
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.take(4).length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final mastery = flashcardProvider.getCategoryMastery(category.id);
                    return SizedBox(
                      width: 175,
                      child: CategoryCard(
                        category: category,
                        masteryPercentage: mastery,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                category: category,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.border),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
