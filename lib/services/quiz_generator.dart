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

  // 1. MULTIPLE CHOICE
  QuizQuestion _generateMultipleChoice(Flashcard card, List<Flashcard> pool, int index) {
    final bool isFillInTheBlank = card.example.isNotEmpty && _random.nextBool();

    if (isFillInTheBlank && card.wordEn.length > 2 && card.example.toLowerCase().contains(card.wordEn.toLowerCase())) {
      // Fill-in-the-blank
      final regex = RegExp(RegExp.escape(card.wordEn), caseSensitive: false);
      final maskedExample = card.example.replaceAll(regex, '________');

      final distractors = _getDistractorWords(card, pool, 3, isEnglish: true);
      final options = [card.wordEn, ...distractors]..shuffle(_random);

      return QuizQuestion(
        id: 'mc_${card.id}_$index',
        card: card,
        type: QuizQuestionType.multipleChoice,
        prompt: 'Completa el espacio en blanco con la palabra correcta:',
        subtitle: '"$maskedExample"',
        correctAnswer: card.wordEn,
        options: options,
        explanation: 'La respuesta correcta es "${card.wordEn}" (${card.wordEs}). Oración completa: "${card.example}"',
      );
    } else {
      // Translation / Meaning
      final isEnToEs = _random.nextBool();
      if (isEnToEs) {
        final distractors = _getDistractorWords(card, pool, 3, isEnglish: false);
        final options = [card.wordEs, ...distractors]..shuffle(_random);

        return QuizQuestion(
          id: 'mc_${card.id}_$index',
          card: card,
          type: QuizQuestionType.multipleChoice,
          prompt: '¿Cuál es el significado correcto de "${card.wordEn}"?',
          subtitle: card.example.isNotEmpty ? 'Ejemplo: "${card.example}"' : null,
          correctAnswer: card.wordEs,
          options: options,
          explanation: '"${card.wordEn}" significa "${card.wordEs}".',
        );
      } else {
        final distractors = _getDistractorWords(card, pool, 3, isEnglish: true);
        final options = [card.wordEn, ...distractors]..shuffle(_random);

        return QuizQuestion(
          id: 'mc_${card.id}_$index',
          card: card,
          type: QuizQuestionType.multipleChoice,
          prompt: '¿Cómo se dice "${card.wordEs}" en inglés?',
          subtitle: card.exampleEs.isNotEmpty ? 'Contexto: "${card.exampleEs}"' : null,
          correctAnswer: card.wordEn,
          options: options,
          explanation: 'La traducción en inglés de "${card.wordEs}" es "${card.wordEn}".',
        );
      }
    }
  }

  // 2. BUILD SENTENCE
  QuizQuestion _generateBuildSentence(Flashcard card, List<Flashcard> pool, int index) {
    String sentence = card.example.isNotEmpty ? card.example.trim() : 'I learn ${card.wordEn} every day.';
    // Tokenize sentence into words
    final rawTokens = sentence.split(RegExp(r'\s+'));
    final scrambled = List<String>.from(rawTokens)..shuffle(_random);

    // If accidentally same order and length > 2, shuffle again
    if (scrambled.join(' ') == sentence && rawTokens.length > 2) {
      scrambled.shuffle(_random);
    }

    return QuizQuestion(
      id: 'bs_${card.id}_$index',
      card: card,
      type: QuizQuestionType.buildSentence,
      prompt: 'Ordena las palabras para formar la oración correcta:',
      subtitle: card.exampleEs.isNotEmpty ? 'Traducción: "${card.exampleEs}"' : 'Significado: "${card.wordEs}"',
      correctAnswer: sentence,
      scrambledWords: scrambled,
      explanation: 'Oración correcta: "$sentence"\n(${card.exampleEs.isNotEmpty ? card.exampleEs : card.wordEs})',
    );
  }

  // 3. SPEED QUIZ
  QuizQuestion _generateSpeedQuiz(Flashcard card, List<Flashcard> pool, int index) {
    final isEnToEs = _random.nextBool();
    final distractors = _getDistractorWords(card, pool, 3, isEnglish: !isEnToEs);
    final correct = isEnToEs ? card.wordEs : card.wordEn;
    final options = [correct, ...distractors]..shuffle(_random);

    return QuizQuestion(
      id: 'sq_${card.id}_$index',
      card: card,
      type: QuizQuestionType.speedQuiz,
      prompt: isEnToEs ? '¡Rápido! ¿Qué significa "${card.wordEn}"?' : '¡Rápido! ¿Cómo se dice "${card.wordEs}"?',
      subtitle: card.example.isNotEmpty ? '"${card.example}"' : null,
      correctAnswer: correct,
      options: options,
      timeLimitSeconds: 7,
      explanation: '"${card.wordEn}" = "${card.wordEs}".',
    );
  }

  // 4. SITUATION
  QuizQuestion _generateSituation(Flashcard card, List<Flashcard> pool, int index) {
    String promptScenario;
    if (card.categoryId == 'phrasal_verbs') {
      promptScenario = 'Estás en una conversación y quieres expresar la idea de "${card.wordEs}". ¿Qué phrasal verb es el más adecuado?';
    } else if (card.categoryId == 'daily_phrases') {
      promptScenario = card.exampleEs.isNotEmpty
          ? 'En una situación cotidiana donde quieres decir "${card.exampleEs}", ¿cuál es la expresión correcta?'
          : 'Quieres decir "${card.wordEs}" a un amigo en inglés. ¿Qué frase usas?';
    } else if (card.categoryId == 'verb_tenses') {
      promptScenario = card.exampleEs.isNotEmpty
          ? 'Quieres describir la siguiente acción en inglés: "${card.exampleEs}". ¿Cuál es la oración gramaticalmente adecuada?'
          : 'Para la estructura de ${card.wordEn} (${card.wordEs}), ¿cuál es la opción correcta?';
    } else if (card.categoryId == 'irregular_verbs') {
      promptScenario = card.exampleEs.isNotEmpty
          ? 'Estás contando una historia en pasado y quieres decir: "${card.exampleEs}". ¿Cuál es la forma correcta?'
          : 'Para expresar la acción "${card.wordEs}", ¿qué verbo o forma debes usar?';
    } else {
      promptScenario = card.exampleEs.isNotEmpty
          ? 'En una situación donde necesitas expresar: "${card.exampleEs}", ¿cuál es la mejor opción en inglés?'
          : '¿Cuál es la palabra o frase en inglés para expresar "${card.wordEs}"?';
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
      subtitle: card.hasStructure ? 'Estructura: ${card.structure}' : null,
      correctAnswer: correct,
      options: options,
      explanation: 'Para esta situación, la respuesta ideal es "$correct" (${card.wordEs}).',
    );
  }

  // 5. FIND ERROR
  QuizQuestion _generateFindError(Flashcard card, List<Flashcard> pool, int index) {
    String originalSentence = card.example.isNotEmpty ? card.example : 'She ${card.wordEn} every morning.';
    String erroneousSentence = _createIntentionalError(originalSentence, card);

    // If couldn't make a distinct error, fallback to modifying words
    if (erroneousSentence == originalSentence) {
      erroneousSentence = originalSentence.replaceFirst(' ', ' is not ');
    }

    final distractors = _getFindErrorDistractors(originalSentence, erroneousSentence, pool, 3);
    final options = [originalSentence, ...distractors]..shuffle(_random);

    return QuizQuestion(
      id: 'fe_${card.id}_$index',
      card: card,
      type: QuizQuestionType.findError,
      prompt: 'Identifica la versión corregida de la siguiente oración con error:',
      erroneousSentence: erroneousSentence,
      subtitle: 'Oración incorrecta: "$erroneousSentence"',
      correctAnswer: originalSentence,
      options: options,
      explanation: 'La versión correcta es: "$originalSentence"\n(${card.exampleEs.isNotEmpty ? card.exampleEs : card.wordEs})',
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
    if (lower.contains('goes')) return sentence.replaceAll('goes', 'go');
    if (lower.contains('studies')) return sentence.replaceAll('studies', 'study');
    if (lower.contains('plays')) return sentence.replaceAll('plays', 'play');

    return sentence;
  }

  List<String> _getFindErrorDistractors(String correctSentence, String erroneous, List<Flashcard> pool, int count) {
    final List<String> result = [];
    result.add(erroneous); // One option is the actual error itself

    // Add altered variants
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

    while (result.length < count) {
      final randomCard = pool[_random.nextInt(pool.length)];
      if (randomCard.example.isNotEmpty && randomCard.example != correctSentence) {
        result.add(randomCard.example);
      } else {
        result.add('$correctSentence (incorrect)');
      }
    }

    return result.take(count).toList();
  }

  List<String> _getDistractorWords(Flashcard current, List<Flashcard> pool, int count, {required bool isEnglish}) {
    final List<String> distractors = [];
    final candidates = List<Flashcard>.from(pool)..shuffle(_random);

    for (var card in candidates) {
      if (card.id == current.id) continue;
      final word = isEnglish ? card.wordEn : card.wordEs;
      if (word.isNotEmpty && !distractors.contains(word) && word != (isEnglish ? current.wordEn : current.wordEs)) {
        distractors.add(word);
        if (distractors.length == count) break;
      }
    }

    // Fallbacks if pool is small
    while (distractors.length < count) {
      distractors.add(isEnglish ? 'Option ${distractors.length + 1}' : 'Opción ${distractors.length + 1}');
    }

    return distractors;
  }

  List<String> _getDistractorsForSituation(Flashcard current, List<Flashcard> pool, int count, bool useFullSentence) {
    final List<String> distractors = [];
    final candidates = List<Flashcard>.from(pool)..shuffle(_random);

    for (var card in candidates) {
      if (card.id == current.id) continue;
      final text = useFullSentence
          ? (card.example.isNotEmpty ? card.example : card.wordEn)
          : card.wordEn;
      if (text.isNotEmpty && !distractors.contains(text)) {
        distractors.add(text);
        if (distractors.length == count) break;
      }
    }

    while (distractors.length < count) {
      distractors.add(useFullSentence ? 'I will call you later.' : 'Get along');
    }

    return distractors;
  }
}
