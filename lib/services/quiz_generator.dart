import 'dart:math';
import '../models/flashcard.dart';
import '../models/quiz_question.dart';

class QuizGenerator {
  final Random _random = Random();

  /// Generates a list of questions based on selected cards, target size, and desired question type
  List<QuizQuestion> generateQuiz({
    required List<Flashcard> availableCards,
    required List<Flashcard> allPoolCards,
    required int count,
    QuizQuestionType? specificType, // null means mixed
  }) {
    if (availableCards.isEmpty) return [];

    final shuffledAvailable = List<Flashcard>.from(availableCards)..shuffle(_random);
    final selectedCards = shuffledAvailable.take(min(count, shuffledAvailable.length)).toList();

    final List<QuizQuestion> questions = [];

    final List<QuizQuestionType> mixedTypes = [
      QuizQuestionType.multipleChoice,
      QuizQuestionType.buildSentence,
      QuizQuestionType.speedQuiz,
      QuizQuestionType.situation,
      QuizQuestionType.findError,
    ];

    for (int i = 0; i < selectedCards.length; i++) {
      final card = selectedCards[i];
      final qType = specificType ?? mixedTypes[i % mixedTypes.length];

      switch (qType) {
        case QuizQuestionType.multipleChoice:
          questions.add(_generateMultipleChoice(card, allPoolCards, i));
          break;
        case QuizQuestionType.buildSentence:
          questions.add(_generateBuildSentence(card, allPoolCards, i));
          break;
        case QuizQuestionType.speedQuiz:
          questions.add(_generateSpeedQuiz(card, allPoolCards, i));
          break;
        case QuizQuestionType.situation:
          questions.add(_generateSituation(card, allPoolCards, i));
          break;
        case QuizQuestionType.findError:
          questions.add(_generateFindError(card, allPoolCards, i));
          break;
      }
    }

    return questions;
  }

  // 1. MULTIPLE CHOICE (100% English & Same Category)
  QuizQuestion _generateMultipleChoice(Flashcard card, List<Flashcard> pool, int index) {
    final distractors = _getDistractorWords(card, pool, 3);
    final options = [card.wordEn, ...distractors]..shuffle(_random);

    if (card.example.isNotEmpty && card.example.toLowerCase().contains(card.wordEn.toLowerCase())) {
      final regex = RegExp(RegExp.escape(card.wordEn), caseSensitive: false);
      final maskedExample = card.example.replaceAll(regex, '________');

      return QuizQuestion(
        id: 'mc_${card.id}_$index',
        card: card,
        type: QuizQuestionType.multipleChoice,
        prompt: 'Complete the sentence with the correct option:',
        subtitle: '"$maskedExample"',
        correctAnswer: card.wordEn,
        options: options,
        explanation: 'Correct answer: "${card.wordEn}". Full sentence: "${card.example}"',
      );
    } else {
      return QuizQuestion(
        id: 'mc_${card.id}_$index',
        card: card,
        type: QuizQuestionType.multipleChoice,
        prompt: 'Which is the correct term to use in this context?',
        subtitle: card.example.isNotEmpty ? 'Context: "${card.example}"' : (card.hasStructure ? 'Structure: ${card.structure}' : null),
        correctAnswer: card.wordEn,
        options: options,
        explanation: 'The correct choice is "${card.wordEn}". ${card.example.isNotEmpty ? 'Example: "${card.example}"' : ''}',
      );
    }
  }

  // 2. BUILD SENTENCE (100% English)
  QuizQuestion _generateBuildSentence(Flashcard card, List<Flashcard> pool, int index) {
    String sentence = card.example.isNotEmpty ? card.example.trim() : 'I practice ${card.wordEn} every single day.';
    final rawTokens = sentence.split(RegExp(r'\s+'));
    final scrambled = List<String>.from(rawTokens)..shuffle(_random);

    if (scrambled.join(' ') == sentence && rawTokens.length > 2) {
      scrambled.shuffle(_random);
    }

    return QuizQuestion(
      id: 'bs_${card.id}_$index',
      card: card,
      type: QuizQuestionType.buildSentence,
      prompt: 'Arrange the scrambled words to form the correct sentence:',
      subtitle: card.hasStructure ? 'Grammar Structure: ${card.structure}' : null,
      correctAnswer: sentence,
      scrambledWords: scrambled,
      explanation: 'Correct sentence: "$sentence"',
    );
  }

  // 3. SPEED QUIZ (100% English & Same Category)
  QuizQuestion _generateSpeedQuiz(Flashcard card, List<Flashcard> pool, int index) {
    final distractors = _getDistractorWords(card, pool, 3);
    final options = [card.wordEn, ...distractors]..shuffle(_random);

    String? subtitle;
    if (card.example.isNotEmpty && card.example.toLowerCase().contains(card.wordEn.toLowerCase())) {
      final regex = RegExp(RegExp.escape(card.wordEn), caseSensitive: false);
      subtitle = '"${card.example.replaceAll(regex, '________')}"';
    } else if (card.example.isNotEmpty) {
      subtitle = 'Context: "${card.example}"';
    }

    return QuizQuestion(
      id: 'sq_${card.id}_$index',
      card: card,
      type: QuizQuestionType.speedQuiz,
      prompt: 'Quick! Select the correct word or phrase:',
      subtitle: subtitle,
      correctAnswer: card.wordEn,
      options: options,
      timeLimitSeconds: 7,
      explanation: 'Correct choice: "${card.wordEn}". ${card.example.isNotEmpty ? 'Sentence: "${card.example}"' : ''}',
    );
  }

  // 4. SITUATION (100% English & Same Category)
  QuizQuestion _generateSituation(Flashcard card, List<Flashcard> pool, int index) {
    String promptScenario;
    switch (card.categoryId) {
      case 'phrasal_verbs':
        promptScenario = 'In an everyday conversation, which phrasal verb fits this context best?';
        break;
      case 'daily_phrases':
        promptScenario = 'In a social interaction, which expression is the most natural to use?';
        break;
      case 'verb_tenses':
        promptScenario = 'Which sentence uses the correct grammatical tense and structure?';
        break;
      case 'irregular_verbs':
        promptScenario = 'Which verb form correctly completes the sentence?';
        break;
      default:
        promptScenario = 'Which word or phrase fits best in this scenario?';
        break;
    }

    final bool useFullSentence = card.example.isNotEmpty && (card.categoryId == 'daily_phrases' || card.categoryId == 'verb_tenses');
    final String correct = useFullSentence ? card.example : card.wordEn;

    final distractors = _getDistractorsForSituation(card, pool, 3, useFullSentence);
    final options = [correct, ...distractors]..shuffle(_random);

    return QuizQuestion(
      id: 'sit_${card.id}_$index',
      card: card,
      type: QuizQuestionType.situation,
      prompt: promptScenario,
      subtitle: card.hasStructure ? 'Structure: ${card.structure}' : (card.example.isNotEmpty && !useFullSentence ? 'Context: "${card.example.replaceAll(card.wordEn, '______')}"' : null),
      correctAnswer: correct,
      options: options,
      explanation: 'The most natural option is "$correct".',
    );
  }

  // 5. FIND ERROR (100% English & Same Category)
  QuizQuestion _generateFindError(Flashcard card, List<Flashcard> pool, int index) {
    String originalSentence = card.example.isNotEmpty ? card.example : 'She ${card.wordEn} every morning.';
    String erroneousSentence = _createIntentionalError(originalSentence, card);

    if (erroneousSentence == originalSentence) {
      erroneousSentence = originalSentence.replaceFirst(' ', ' is not ');
    }

    final distractors = _getFindErrorDistractors(originalSentence, erroneousSentence, pool, 3);
    final options = [originalSentence, ...distractors]..shuffle(_random);

    return QuizQuestion(
      id: 'fe_${card.id}_$index',
      card: card,
      type: QuizQuestionType.findError,
      prompt: 'Identify the corrected version of the erroneous sentence:',
      erroneousSentence: erroneousSentence,
      subtitle: 'Incorrect sentence: "$erroneousSentence"',
      correctAnswer: originalSentence,
      options: options,
      explanation: 'The grammatically correct sentence is: "$originalSentence"',
    );
  }

  // Helper: Create grammatical errors
  String _createIntentionalError(String sentence, Flashcard card) {
    String lower = sentence.toLowerCase();

    // 1. Irregular verbs errors
    if (card.past != null && card.past!.isNotEmpty && sentence.contains(card.past!)) {
      final fakeRegular = '${card.present ?? card.wordEn}ed';
      return sentence.replaceAll(card.past!, fakeRegular);
    }

    // 2. Common auxiliary errors
    if (sentence.contains('doesn\'t ')) return sentence.replaceAll('doesn\'t ', 'don\'t ');
    if (sentence.contains('doesn’t ')) return sentence.replaceAll('doesn’t ', 'don’t ');
    if (sentence.contains('don\'t ')) return sentence.replaceAll('don\'t ', 'doesn\'t ');
    if (sentence.contains('did not ')) return sentence.replaceAll('did not ', 'did not went ');
    if (sentence.contains('didn\'t ')) return sentence.replaceAll('didn\'t ', 'didn\'t went ');
    if (sentence.contains('were ')) return sentence.replaceAll('were ', 'was ');
    if (sentence.contains('was ')) return sentence.replaceAll('was ', 'were ');
    if (sentence.contains('have ')) return sentence.replaceAll('have ', 'has ');
    if (sentence.contains('has ')) return sentence.replaceAll('has ', 'have ');
    if (sentence.contains('will ')) return sentence.replaceAll('will ', 'will goes to ');

    // 3. Phrasal verb preposition errors
    final parts = card.wordEn.split(' ');
    if (parts.length >= 2) {
      final prep = parts.last;
      const wrongPreps = ['in', 'at', 'on', 'off', 'up', 'down', 'out', 'away', 'for'];
      final replacement = wrongPreps.firstWhere((p) => p != prep.toLowerCase(), orElse: () => 'to');
      if (sentence.contains(prep)) {
        return sentence.replaceFirst(prep, replacement);
      }
    }

    // 4. Default: 3rd person 's' error
    if (lower.contains('goes')) return sentence.replaceAll('goes', 'go');
    if (lower.contains('studies')) return sentence.replaceAll('studies', 'study');
    if (lower.contains('plays')) return sentence.replaceAll('plays', 'play');

    return sentence;
  }

  List<String> _getFindErrorDistractors(String correctSentence, String erroneous, List<Flashcard> pool, int count) {
    final List<String> result = [];
    result.add(erroneous);

    final words = correctSentence.split(' ');
    if (words.length > 3) {
      final v1 = List<String>.from(words)..removeAt(1);
      result.add(v1.join(' '));
    } else {
      result.add('$correctSentence not');
    }

    if (words.length > 2) {
      final v2 = List<String>.from(words);
      v2[0] = 'He';
      result.add(v2.join(' '));
    } else {
      result.add('Does $correctSentence?');
    }

    final sameCategoryPool = pool.where((c) => c.example.isNotEmpty && c.example != correctSentence).toList()..shuffle(_random);
    for (var card in sameCategoryPool) {
      if (result.length >= count) break;
      if (!result.contains(card.example)) {
        result.add(card.example);
      }
    }

    while (result.length < count) {
      result.add('$correctSentence (incorrect)');
    }

    return result.take(count).toList();
  }

  List<String> _getDistractorWords(Flashcard current, List<Flashcard> pool, int count) {
    final List<String> distractors = [];
    // Strict filter: SAME category only
    final sameCategoryPool = pool.where((c) => c.categoryId == current.categoryId && c.id != current.id).toList();
    final candidates = List<Flashcard>.from(sameCategoryPool)..shuffle(_random);

    for (var card in candidates) {
      final word = card.wordEn.trim();
      if (word.isNotEmpty && !distractors.contains(word) && word.toLowerCase() != current.wordEn.trim().toLowerCase()) {
        distractors.add(word);
        if (distractors.length == count) break;
      }
    }

    // Fallback if category has very few cards
    if (distractors.length < count) {
      final fallbackPool = pool.where((c) => c.id != current.id && !distractors.contains(c.wordEn.trim())).toList()..shuffle(_random);
      for (var card in fallbackPool) {
        final word = card.wordEn.trim();
        if (word.isNotEmpty && !distractors.contains(word)) {
          distractors.add(word);
          if (distractors.length == count) break;
        }
      }
    }

    return distractors;
  }

  List<String> _getDistractorsForSituation(Flashcard current, List<Flashcard> pool, int count, bool useFullSentence) {
    final List<String> distractors = [];
    final sameCategoryPool = pool.where((c) => c.categoryId == current.categoryId && c.id != current.id).toList();
    final candidates = List<Flashcard>.from(sameCategoryPool)..shuffle(_random);

    for (var card in candidates) {
      final text = useFullSentence
          ? (card.example.isNotEmpty ? card.example.trim() : card.wordEn.trim())
          : card.wordEn.trim();
      if (text.isNotEmpty && !distractors.contains(text) && text != (useFullSentence ? current.example.trim() : current.wordEn.trim())) {
        distractors.add(text);
        if (distractors.length == count) break;
      }
    }

    if (distractors.length < count) {
      final fallbackPool = pool.where((c) => c.id != current.id).toList()..shuffle(_random);
      for (var card in fallbackPool) {
        final text = useFullSentence
            ? (card.example.isNotEmpty ? card.example.trim() : card.wordEn.trim())
            : card.wordEn.trim();
        if (text.isNotEmpty && !distractors.contains(text)) {
          distractors.add(text);
          if (distractors.length == count) break;
        }
      }
    }

    return distractors;
  }
}
