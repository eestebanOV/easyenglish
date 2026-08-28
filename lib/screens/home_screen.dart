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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = flashcardProvider.stats;
    final dueCards = flashcardProvider.getDueCards();
    final categories = flashcardProvider.categories;
    final dailyGoal = settingsProvider.dailyGoal;
    final progress = stats.reviewsToday / (dailyGoal > 0 ? dailyGoal : 1);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
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
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        t('home.learnToday'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
              const SizedBox(height: 24),

              // Daily Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2640), Color(0xFF141A29)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: AppTheme.primaryLight.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('home.dailyGoal'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dueCards.isNotEmpty
                                ? '${dueCards.length} ${t('home.dueCards')}'
                                : t('home.goalDone'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
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
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            label: Text(
                              dueCards.isNotEmpty ? t('home.startReview') : t('home.practiceMore'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: AppTheme.darkBg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
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
              const SizedBox(height: 24),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: t('home.learned'),
                      value: '${flashcardProvider.totalLearnedCount}',
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      icon: Icons.star_rounded,
                      title: t('home.mastered'),
                      value: '${flashcardProvider.totalMasteredCount}',
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      icon: Icons.layers_rounded,
                      title: t('home.totalCards'),
                      value: '${flashcardProvider.allCards.length}',
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1C59), Color(0xFF192341)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.quiz_rounded, color: Colors.purpleAccent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Desafío de Quiz 🎯',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Pon a prueba tu vocabulario con 5 tipos de preguntas interactivas.',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.purpleAccent, size: 14),
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
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: Text(
                      t('home.viewAll'),
                      style: const TextStyle(color: AppTheme.primaryLight, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Category List
              SizedBox(
                height: 215,
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
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
