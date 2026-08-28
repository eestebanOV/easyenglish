import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final double masteryPercentage;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.masteryPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final t = settings.translate;
    final isEs = settings.languageCode == 'es';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: category.color.withValues(alpha: context.isDark ? 0.35 : 0.25),
              width: 1.2,
            ),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: context.isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      category.vectorIcon,
                      size: 20,
                      color: category.color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      border: Border.all(color: context.border),
                    ),
                    child: Text(
                      category.id == 'daily_phrases' || category.id == 'phrases'
                          ? '${category.cardCount} ${t('catcount.phrases')}'
                          : '${category.cardCount} ${t('catcount.words')}',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEs ? category.nameEs : category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                isEs ? category.name : category.nameEs,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('home.dominio'),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${masteryPercentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: masteryPercentage / 100,
                  backgroundColor: context.isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
