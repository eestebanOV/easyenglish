import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: AppTheme.accentAmber.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 16,
              color: AppTheme.accentAmber,
            ),
            const SizedBox(width: 4),
            Text(
              '$streakDays',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.accentAmber,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 26,
              color: AppTheme.accentAmber,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streakDays ${streakDays == 1 ? "día" : "días"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.accentAmber,
                ),
              ),
              Text(
                'Racha de estudio',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
