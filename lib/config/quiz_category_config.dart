import 'dart:math';
import '../models/quiz_question.dart';

/// Configuration that maps each category to its allowed question types with weights.
///
/// Higher weight = more likely to be selected when quiz type is "mixed" (auto).
/// The list order does not determine probability — the weights do.
///
/// To modify category-type relationships, edit only this file.
class QuizCategoryConfig {
  final List<QuizQuestionType> allowedTypes;
  final Map<QuizQuestionType, int> weights;

  const QuizCategoryConfig({
    required this.allowedTypes,
    required this.weights,
  });

  /// The primary (highest-weight) type for this category.
  QuizQuestionType get primaryType {
    return allowedTypes.reduce(
      (a, b) => (weights[a] ?? 1) >= (weights[b] ?? 1) ? a : b,
    );
  }

  /// Picks a type randomly based on weights.
  QuizQuestionType pickWeightedType(Random random) {
    final totalWeight = allowedTypes.fold<int>(0, (sum, t) => sum + (weights[t] ?? 1));
    int roll = random.nextInt(totalWeight);
    for (final type in allowedTypes) {
      roll -= (weights[type] ?? 1);
      if (roll < 0) return type;
    }
    return allowedTypes.first;
  }

  /// Returns true if the given type is allowed for this category.
  bool supportsType(QuizQuestionType type) => allowedTypes.contains(type);
}

/// Central table: category ID → quiz configuration.
/// Edit weights and allowed types here to change quiz behavior per category.
class QuizCategoryConfigs {
  QuizCategoryConfigs._();

  static const Map<String, QuizCategoryConfig> _configs = {
    // -----------------------------------------------------------------------
    // Everyday Phrases
    // Principal: Situational (social context is the core challenge)
    // Supported: Multiple Choice, Find Error, Speed Quiz, Build Sentence
    // -----------------------------------------------------------------------
    'daily_phrases': QuizCategoryConfig(
      allowedTypes: [
        QuizQuestionType.situation,
        QuizQuestionType.multipleChoice,
        QuizQuestionType.findError,
        QuizQuestionType.speedQuiz,
        QuizQuestionType.buildSentence,
      ],
      weights: {
        QuizQuestionType.situation: 4,
        QuizQuestionType.multipleChoice: 2,
        QuizQuestionType.findError: 2,
        QuizQuestionType.speedQuiz: 1,
        QuizQuestionType.buildSentence: 1,
      },
    ),

    // -----------------------------------------------------------------------
    // Phrasal Verbs
    // All 5 types work well — verb + particle structure supports all formats
    // Principal: Multiple Choice (recognition of meaning)
    // -----------------------------------------------------------------------
    'phrasal_verbs': QuizCategoryConfig(
      allowedTypes: [
        QuizQuestionType.multipleChoice,
        QuizQuestionType.situation,
        QuizQuestionType.findError,
        QuizQuestionType.buildSentence,
        QuizQuestionType.speedQuiz,
      ],
      weights: {
        QuizQuestionType.multipleChoice: 3,
        QuizQuestionType.situation: 2,
        QuizQuestionType.findError: 2,
        QuizQuestionType.buildSentence: 2,
        QuizQuestionType.speedQuiz: 1,
      },
    ),

    // -----------------------------------------------------------------------
    // Irregular Verbs
    // Principal: Multiple Choice (recognizing past/participle form)
    // Supported: Find Error, Speed Quiz
    // Not recommended: Build Sentence, Situational
    // -----------------------------------------------------------------------
    'irregular_verbs': QuizCategoryConfig(
      allowedTypes: [
        QuizQuestionType.multipleChoice,
        QuizQuestionType.findError,
        QuizQuestionType.speedQuiz,
      ],
      weights: {
        QuizQuestionType.multipleChoice: 4,
        QuizQuestionType.findError: 3,
        QuizQuestionType.speedQuiz: 2,
      },
    ),

    // -----------------------------------------------------------------------
    // Common Words
    // Principal: Multiple Choice (vocabulary meaning recognition)
    // Supported: Speed Quiz
    // Not recommended: Build Sentence, Find Error, Situational
    // -----------------------------------------------------------------------
    'common_words': QuizCategoryConfig(
      allowedTypes: [
        QuizQuestionType.multipleChoice,
        QuizQuestionType.speedQuiz,
      ],
      weights: {
        QuizQuestionType.multipleChoice: 3,
        QuizQuestionType.speedQuiz: 2,
      },
    ),

    // -----------------------------------------------------------------------
    // Verb Tenses
    // Principal: Find Error (detecting wrong tense usage is the core skill)
    // Supported: Situational, Build Sentence, Multiple Choice, Speed Quiz
    // -----------------------------------------------------------------------
    'verb_tenses': QuizCategoryConfig(
      allowedTypes: [
        QuizQuestionType.findError,
        QuizQuestionType.situation,
        QuizQuestionType.buildSentence,
        QuizQuestionType.multipleChoice,
        QuizQuestionType.speedQuiz,
      ],
      weights: {
        QuizQuestionType.findError: 4,
        QuizQuestionType.situation: 3,
        QuizQuestionType.buildSentence: 2,
        QuizQuestionType.multipleChoice: 2,
        QuizQuestionType.speedQuiz: 1,
      },
    ),
  };

  /// Returns the config for a given category ID.
  /// Falls back to a balanced default if the category is unknown.
  static QuizCategoryConfig forCategory(String categoryId) {
    return _configs[categoryId] ?? _defaultConfig;
  }

  /// Default config used for unknown/new categories (balanced, all types).
  static const QuizCategoryConfig _defaultConfig = QuizCategoryConfig(
    allowedTypes: [
      QuizQuestionType.multipleChoice,
      QuizQuestionType.speedQuiz,
      QuizQuestionType.situation,
      QuizQuestionType.findError,
      QuizQuestionType.buildSentence,
    ],
    weights: {
      QuizQuestionType.multipleChoice: 2,
      QuizQuestionType.speedQuiz: 2,
      QuizQuestionType.situation: 2,
      QuizQuestionType.findError: 2,
      QuizQuestionType.buildSentence: 2,
    },
  );
}
