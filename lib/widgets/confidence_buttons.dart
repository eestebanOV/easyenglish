import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class ConfidenceButtons extends StatelessWidget {
  final Function(int quality) onRate;

  const ConfidenceButtons({
    super.key,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsProvider>().translate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              context: context,
              title: t('srs.hard'),
              color: AppTheme.accentAmber,
              icon: Icons.replay_rounded,
              quality: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildButton(
              context: context,
              title: t('srs.normal'),
              color: AppTheme.primary,
              icon: Icons.check_rounded,
              quality: 2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildButton(
              context: context,
              title: t('srs.easy'),
              color: AppTheme.accent,
              icon: Icons.sentiment_very_satisfied_rounded,
              quality: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required int quality,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRate(quality),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: context.isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: context.isDark ? 0.55 : 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
