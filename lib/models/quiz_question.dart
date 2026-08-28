import 'package:flutter/material.dart';
import 'flashcard.dart';

/// Formats of quiz questions available
enum QuizQuestionType {
  multipleChoice,
  buildSentence,
  speedQuiz,
  situation,
  findError,
}

extension QuizQuestionTypeExtension on QuizQuestionType {
  String get displayNameEs {
    switch (this) {
      case QuizQuestionType.multipleChoice:
        return 'Opción Múltiple';
      case QuizQuestionType.buildSentence:
        return 'Construir Oración';
      case QuizQuestionType.speedQuiz:
        return 'Speed Quiz';
      case QuizQuestionType.situation:
        return 'Situacional';
      case QuizQuestionType.findError:
        return 'Encuentra el Error';
    }
  }

  String get shortName {
    switch (this) {
      case QuizQuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuizQuestionType.buildSentence:
        return 'Build Sentence';
      case QuizQuestionType.speedQuiz:
        return 'Speed Quiz';
      case QuizQuestionType.situation:
        return 'Situation';
      case QuizQuestionType.findError:
        return 'Find Error';
    }
  }

  String get badgeLabel {
    switch (this) {
      case QuizQuestionType.multipleChoice:
        return 'OPCIÓN MÚLTIPLE';
      case QuizQuestionType.buildSentence:
        return 'ORDENAR PALABRAS';
      case QuizQuestionType.speedQuiz:
        return 'CONTRARRELOJ';
      case QuizQuestionType.situation:
        return 'SITUACIONAL';
      case QuizQuestionType.findError:
        return 'CORREGIR ERROR';
    }
  }

  IconData get icon {
    switch (this) {
      case QuizQuestionType.multipleChoice:
        return Icons.radio_button_checked_rounded;
      case QuizQuestionType.buildSentence:
        return Icons.sort_rounded;
      case QuizQuestionType.speedQuiz:
        return Icons.bolt_rounded;
      case QuizQuestionType.situation:
        return Icons.chat_bubble_outline_rounded;
      case QuizQuestionType.findError:
        return Icons.find_replace_rounded;
    }
  }
}

/// Represents a single question in a quiz session
class QuizQuestion {
  final String id;
  final Flashcard card;
  final QuizQuestionType type;
  final String prompt;
  final String? subtitle;
  final String? erroneousSentence;
  final String correctAnswer;
  final List<String> options;
  final List<String> scrambledWords;
  final String explanation;
  final int timeLimitSeconds;

  const QuizQuestion({
    required this.id,
    required this.card,
    required this.type,
    required this.prompt,
    this.subtitle,
    this.erroneousSentence,
    required this.correctAnswer,
    this.options = const [],
    this.scrambledWords = const [],
    required this.explanation,
    this.timeLimitSeconds = 8,
  });
}
