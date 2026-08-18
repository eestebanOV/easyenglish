import 'dart:math';

import 'package:flutter/material.dart';

import '../models/flashcard.dart';
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
          final angle = _animation.value * pi;
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  /// LADO 1: INGLÉS + TRADUCCIÓN AL ESPAÑOL + PRONUNCIACIÓN + BOCINA
  Widget _buildFront() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2640), Color(0xFF131826)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: widget.card.categoryId == "verb_tenses"
            ? _buildVerbTenseFront()
            : _buildStandardFront(),
      ),
    );
  }

  Widget _buildVerbTenseFront() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tag Superior: STRUCTURE
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: AppTheme.accentOrange.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.rule_rounded,
                  size: 14,
                  color: AppTheme.accentOrange,
                ),
                SizedBox(width: 6),
                Text(
                  'STRUCTURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Nombre del tiempo verbal
        Text(
          widget.card.wordEn,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),

        // Estructura gramatical
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.accentOrange.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GRAMMAR FORMULA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  color: AppTheme.accentOrange,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.card.structure ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentOrange.withValues(alpha: 0.95),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Indicador para voltear
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 15,
              color: Colors.white.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            Text(
              'Toca para ver ejemplos de uso',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardFront() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tag Superior
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 14,
                  color: AppTheme.primaryLight,
                ),
                SizedBox(width: 6),
                Text(
                  'PALABRA & TRADUCCIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Término en Inglés o 3 formas verbales
        if (widget.card.isVerbWithForms) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTenseBox(
                    tense: 'PRESENT',
                    word: widget.card.present!,
                    color: AppTheme.accent,
                  ),
                ),
                Container(width: 1, height: 44, color: Colors.white12),
                Expanded(
                  child: _buildTenseBox(
                    tense: 'PAST',
                    word: widget.card.past!,
                    color: AppTheme.primaryLight,
                  ),
                ),
                Container(width: 1, height: 44, color: Colors.white12),
                Expanded(
                  child: _buildTenseBox(
                    tense: 'PARTICIPLE',
                    word: widget.card.participle!,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            widget.card.wordEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Pronunciación Fonética
        if (widget.card.pronunciation.isNotEmpty)
          Text(
            widget.card.pronunciation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),

        const SizedBox(height: 18),

        // Traducción al Español Destacada en el Frente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.12),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Bocina para pronunciación
        IconButton.filledTonal(
          onPressed: _speak,
          icon: const Icon(Icons.volume_up_rounded, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
            foregroundColor: AppTheme.primaryLight,
            padding: const EdgeInsets.all(12),
          ),
        ),

        const SizedBox(height: 16),

        // Indicador para voltear
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 15,
              color: Colors.white.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
            Text(
              'Toca para ver ejemplos de uso',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// LADO 2 (REVERSO): DEDICADO A EJEMPLOS + BOTÓN DADO + BOCINA
  Widget _buildBack() {
    final currentExample = _examplesList[_exampleIndex % _examplesList.length];

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 380),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF162E3B), Color(0xFF0F1E29)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppTheme.shadowSoft,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header reverso con Tag - CENTRALIZADO
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
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

              // Contenedor del Ejemplo Actual - contenido CENTRALIZADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (_exampleIndex == 0 &&
                        widget.card.exampleEs.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(
                        color: Colors.white12,
                        height: 1,
                        indent: 30,
                        endIndent: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.card.exampleEs,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Barra inferior con Bocina y Dado juntos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bocina para escuchar el ejemplo
                  IconButton.filledTonal(
                    onPressed: _speakCurrentExample,
                    icon: const Icon(Icons.volume_up_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.accent,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'Escuchar ejemplo',
                  ),
                  const SizedBox(width: 14),

                  // Botón Dado (solo icono, sin texto)
                  IconButton.filledTonal(
                    onPressed: _rollNextExample,
                    icon: const Icon(Icons.casino_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'Cambiar ejemplo',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Indicador para volver al frente
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flip_to_front_rounded,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Toca la tarjeta para volver',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
