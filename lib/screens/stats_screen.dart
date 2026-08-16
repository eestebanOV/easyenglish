import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_badge.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final stats = flashcardProvider.stats;
    final categories = flashcardProvider.categories;
    final totalCards = flashcardProvider.allCards.length;
    final learnedCards = flashcardProvider.totalLearnedCount;
    final masteredCards = flashcardProvider.totalMasteredCount;
    final newCards = totalCards - learnedCards;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Mi Progreso'),
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
              const SizedBox(height: 24),

              // Overview Numbers
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Repasos Totales',
                      value: '${stats.totalReviews}',
                      icon: Icons.repeat_rounded,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Mejor Racha',
                      value: '${stats.bestStreak} días',
                      icon: Icons.emoji_events_rounded,
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pie Chart: Learning Status Distribution
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distribución de Vocabulario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                                    color: AppTheme.warning,
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
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
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: newCards.toDouble(),
                                    title: '$newCards',
                                    color: AppTheme.darkBorder,
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Center(child: Text('Sin datos')),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Dominadas', AppTheme.warning),
                        _buildLegendItem('En aprendizaje', AppTheme.accent),
                        _buildLegendItem('Nuevas', AppTheme.darkBorder),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Mastery Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progreso por Categoría',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                                    Text(cat.icon, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat.nameEs,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
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
                                backgroundColor: AppTheme.darkBorder,
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
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}
