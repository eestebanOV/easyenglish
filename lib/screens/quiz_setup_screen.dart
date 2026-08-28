import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/quiz_question.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';
import 'suggestions_screen.dart';

class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcards = context.watch<FlashcardProvider>();
    final quiz = context.watch<QuizProvider>();

    final allCategories = flashcards.categories;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.quiz_rounded, color: AppTheme.primaryLight, size: 22),
            SizedBox(width: 8),
            Text(
              'Quiz & Desafíos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sugerencias de repaso',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 24),
                if (quiz.pendingSuggestions.isNotEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${quiz.pendingSuggestions.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggestions banner if any pending
              if (quiz.pendingSuggestions.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.15),
                          Colors.orange.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tienes ítems recomendados para repasar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                              Text(
                                '${quiz.pendingSuggestions.length} palabras o frases que fallaste en quizzes anteriores.',
                                style: const TextStyle(fontSize: 11, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.amberAccent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],

              // 1. Category Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1. CATEGORÍAS (MULTI-SELECCIÓN)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (quiz.selectedCategoryIds.length == allCategories.length) {
                        quiz.toggleCategory(allCategories.first.id);
                      } else {
                        quiz.selectAllCategories(allCategories.map((c) => c.id).toList());
                      }
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      quiz.selectedCategoryIds.length == allCategories.length ? 'Desmarcar' : 'Todas',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allCategories.map((cat) {
                  final bool isSelected = quiz.selectedCategoryIds.contains(cat.id);
                  final cardCount = flashcards.allCards.where((c) => c.categoryId == cat.id).length;

                  return FilterChip(
                    label: Text(
                      '${cat.nameEs} ($cardCount)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: cat.color.withValues(alpha: 0.35),
                    backgroundColor: AppTheme.darkCard,
                    side: BorderSide(
                      color: isSelected ? cat.color : AppTheme.darkBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    avatar: isSelected ? Icon(Icons.check, size: 14, color: cat.color) : null,
                    onSelected: (val) {
                      quiz.toggleCategory(cat.id);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 26),

              // 2. Question Types
              const Text(
                '2. TIPO DE DESAFÍO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 10),

              _buildTypeSelector(quiz),

              const SizedBox(height: 26),

              // 3. Quiz Size / Length
              const Text(
                '3. CANTIDAD DE PREGUNTAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: AppConstants.quizSizeOptions.map((size) {
                  final isSelected = quiz.selectedQuizSize == size;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => quiz.setQuizSize(size),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryLight : AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryLight : AppTheme.darkBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$size',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'preguntas',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Launch Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    quiz.startQuiz(allCards: flashcards.allCards);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: Text(
                    'Iniciar Quiz (${quiz.selectedQuizSize} preguntas)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(QuizProvider quiz) {
    final List<Map<String, dynamic>> types = [
      {
        'type': null,
        'title': '🎲 Mezcla Aleatoria',
        'subtitle': 'Combina los 5 formatos en una sesión dinámica (Recomendado)',
      },
      {
        'type': QuizQuestionType.multipleChoice,
        'title': '🎯 Opción Múltiple',
        'subtitle': 'Traducción y completar espacios en blanco con 4 opciones',
      },
      {
        'type': QuizQuestionType.buildSentence,
        'title': '🧩 Construir Oración',
        'subtitle': 'Ordena palabras y fragmentos desordenados',
      },
      {
        'type': QuizQuestionType.speedQuiz,
        'title': '⚡ Speed Quiz',
        'subtitle': 'Contrarreloj veloz (7 segundos por pregunta)',
      },
      {
        'type': QuizQuestionType.situation,
        'title': '🎭 Situacional',
        'subtitle': 'Elige la frase o tiempo adecuado según el contexto',
      },
      {
        'type': QuizQuestionType.findError,
        'title': '🔎 Encuentra el Error',
        'subtitle': 'Detecta y corrige el fallo gramatical en la oración',
      },
    ];

    return Column(
      children: types.map((item) {
        final QuizQuestionType? type = item['type'] as QuizQuestionType?;
        final isSelected = quiz.selectedQuestionType == type;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => quiz.setQuestionType(type),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryLight : AppTheme.darkBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: 4, right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryLight : Colors.white38,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: const TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
