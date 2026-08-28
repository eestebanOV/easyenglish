import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int current;
  final int total;
  final String label;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.current,
    required this.total,
    this.label = 'Completado',
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: 8,
              backgroundColor: context.isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current/$total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
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
