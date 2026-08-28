import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flashcard.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TtsService _ttsService = TtsService();

  int _exampleIndex = 0;
  late List<String> _examplesList;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _initExamples();

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  void _initExamples() {
    _examplesList = widget.card.allExamples;
    if (_examplesList.length < 3) {
      final word = widget.card.wordEn;
      _examplesList = [
        ..._examplesList,
        'Practice using "$word" in your everyday conversations.',
        'Try making a new sentence with "$word" right now.',
      ];
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      _exampleIndex = 0;
      _initExamples();
    }
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _speak() {
    _ttsService.speak(widget.card.wordEn);
  }

  void _speakCurrentExample() {
    if (_examplesList.isNotEmpty) {
      _ttsService.speak(_examplesList[_exampleIndex % _examplesList.length]);
    } else {
      _ttsService.speak(widget.card.example);
    }
  }

  void _rollNextExample() {
    setState(() {
      _exampleIndex = (_exampleIndex + 1) % _examplesList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value < 0.5;
          final angle = _animation.value * pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? _buildFront(context) : _buildBack(context),
          );
        },
      ),
    );
  }

  /// LADO 1: INGLÉS + TRADUCCIÓN AL ESPAÑOL + PRONUNCIACIÓN + BOCINA
  Widget _buildFront(BuildContext context) {
    final t = context.read<SettingsProvider>().translate;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: context.isDark ? 0.35 : 0.25),
          width: 1.5,
        ),
        boxShadow: context.cardShadow,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: widget.card.categoryId == "verb_tenses"
            ? _buildVerbTenseFront(context, t)
            : _buildStandardFront(context, t),
      ),
    );
  }

  Widget _buildVerbTenseFront(BuildContext context, String Function(String) t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: context.isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: AppTheme.accentPurple.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.functions_rounded,
                  size: 14,
                  color: AppTheme.accentPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  t('card.structureLabel'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        Text(
          widget.card.wordEn,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: context.isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.accentPurple.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('card.grammarFormula'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.card.structure ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentPurple,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 15,
              color: context.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              t('card.tapToFlip'),
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardFront(BuildContext context, String Function(String) t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: context.isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.translate_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  t('card.frontTag'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (widget.card.isVerbWithForms) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: context.cardSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTenseBox(
                    context: context,
                    tense: t('card.tense.present'),
                    word: widget.card.present!,
                    color: AppTheme.accent,
                  ),
                ),
                Container(width: 1, height: 40, color: context.border),
                Expanded(
                  child: _buildTenseBox(
                    context: context,
                    tense: t('card.tense.past'),
                    word: widget.card.past!,
                    color: AppTheme.primary,
                  ),
                ),
                Container(width: 1, height: 40, color: context.border),
                Expanded(
                  child: _buildTenseBox(
                    context: context,
                    tense: t('card.tense.participle'),
                    word: widget.card.participle!,
                    color: AppTheme.accentAmber,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            widget.card.wordEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],

        const SizedBox(height: 10),

        if (widget.card.pronunciation.isNotEmpty)
          Text(
            widget.card.pronunciation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: context.textSecondary,
            ),
          ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: context.isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, size: 16, color: AppTheme.accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.card.wordEs,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        IconButton.filledTonal(
          onPressed: _speak,
          icon: const Icon(Icons.volume_up_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primary.withValues(alpha: context.isDark ? 0.2 : 0.12),
            foregroundColor: AppTheme.primary,
            padding: const EdgeInsets.all(12),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 15,
              color: context.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              t('card.tapToFlip'),
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// LADO 2 (REVERSO): DEDICADO A EJEMPLOS + BOTÓN DADO + BOCINA
  Widget _buildBack(BuildContext context) {
    final currentExample = _examplesList[_exampleIndex % _examplesList.length];
    final t = context.read<SettingsProvider>().translate;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 380),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: context.isDark ? 0.45 : 0.3),
            width: 1.5,
          ),
          boxShadow: context.cardShadow,
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: context.isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 14,
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'EJEMPLO ${_exampleIndex + 1}/${_examplesList.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardSecondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: context.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        '"$currentExample"',
                        key: ValueKey(currentExample),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: context.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (_exampleIndex == 0 &&
                        widget.card.exampleEs.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(
                        color: context.border,
                        height: 1,
                        indent: 30,
                        endIndent: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.card.exampleEs,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: _speakCurrentExample,
                    icon: const Icon(Icons.volume_up_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accent.withValues(alpha: context.isDark ? 0.2 : 0.12),
                      foregroundColor: AppTheme.accent,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'Escuchar ejemplo',
                  ),
                  const SizedBox(width: 14),
                  IconButton.filledTonal(
                    onPressed: _rollNextExample,
                    icon: const Icon(Icons.shuffle_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentAmber.withValues(alpha: context.isDark ? 0.2 : 0.12),
                      foregroundColor: AppTheme.accentAmber,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'Cambiar ejemplo',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flip_to_front_rounded,
                    size: 15,
                    color: context.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t('card.backHint'),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenseBox({
    required BuildContext context,
    required String tense,
    required String word,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tense,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
