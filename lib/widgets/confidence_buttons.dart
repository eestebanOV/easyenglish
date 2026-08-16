import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfidenceButtons extends StatelessWidget {
  final Function(int quality) onRate;

  const ConfidenceButtons({
    super.key,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              title: 'No lo sé',
              subtitle: '1 min',
              color: AppTheme.error,
              icon: Icons.close_rounded,
              quality: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              title: 'Difícil',
              subtitle: '10 min',
              color: AppTheme.warning,
              icon: Icons.replay_rounded,
              quality: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              title: 'Bien',
              subtitle: '1 día',
              color: AppTheme.primaryLight,
              icon: Icons.check_rounded,
              quality: 3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildButton(
              title: 'Fácil',
              subtitle: '3 días',
              color: AppTheme.accent,
              icon: Icons.sentiment_very_satisfied_rounded,
              quality: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required int quality,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRate(quality),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
