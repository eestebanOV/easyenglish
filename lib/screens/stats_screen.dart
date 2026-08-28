import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_badge.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;
    final isEs = settings.languageCode == 'es';

    final stats = flashcardProvider.stats;
    final categories = flashcardProvider.categories;
    final totalCards = flashcardProvider.allCards.length;
    final learnedCards = flashcardProvider.totalLearnedCount;
    final masteredCards = flashcardProvider.totalMasteredCount;
    final newCards = totalCards - learnedCards;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(t('stats.title')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Hero Card
              StreakBadge(streakDays: stats.streakDays),
              const SizedBox(height: 20),

              // Overview Numbers
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: t('stats.totalReviews'),
                      value: '${stats.totalReviews}',
                      icon: Icons.repeat_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: t('stats.bestStreak'),
                      value: '${stats.bestStreak} ${t('stats.days')}',
                      icon: Icons.emoji_events_rounded,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pie Chart: Learning Status Distribution
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: context.border),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('stats.distribution'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: totalCards > 0
                          ? PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: masteredCards.toDouble(),
                                    title: '$masteredCards',
                                    color: AppTheme.accentAmber,
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (learnedCards - masteredCards).clamp(0, totalCards).toDouble(),
                                    title: '${(learnedCards - masteredCards).clamp(0, totalCards)}',
                                    color: AppTheme.accent,
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: newCards.toDouble(),
                                    title: '$newCards',
                                    color: context.isDark ? AppTheme.darkBorder : const Color(0xFFCBD5E1),
                                    radius: 35,
                                    titleStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(child: Text(t('stats.noData'), style: TextStyle(color: context.textSecondary))),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(context, t('stats.legendMastered'), AppTheme.accentAmber),
                        _buildLegendItem(context, t('stats.legendLearning'), AppTheme.accent),
                        _buildLegendItem(context, t('stats.legendNew'), context.isDark ? AppTheme.darkBorder : const Color(0xFFCBD5E1)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Mastery Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: context.border),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('stats.catProgress'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...categories.map((cat) {
                      final mastery = flashcardProvider.getCategoryMastery(cat.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      cat.vectorIcon,
                                      size: 16,
                                      color: cat.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEs ? cat.nameEs : cat.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${mastery.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: cat.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: mastery / 100,
                                backgroundColor: context.cardSecondary,
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.border),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.textSecondary),
        ),
      ],
    );
  }
}
