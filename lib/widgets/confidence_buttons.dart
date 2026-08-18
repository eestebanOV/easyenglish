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
              title: 'Difícil',
              color: AppTheme.warning,
              icon: Icons.replay_rounded,
              quality: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildButton(
              title: 'Normal',
              color: AppTheme.primaryLight,
              icon: Icons.check_rounded,
              quality: 2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildButton(
              title: 'Fácil',
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
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
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
