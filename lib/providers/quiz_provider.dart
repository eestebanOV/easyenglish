import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/flashcard.dart';
import '../models/quiz_question.dart';
import '../models/quiz_suggestion.dart';
import '../services/quiz_generator.dart';
import '../services/storage_service.dart';

class QuizProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final QuizGenerator _generator = QuizGenerator();

  // Setup configuration
  Set<String> _selectedCategoryIds = {};
  int _selectedQuizSize = AppConstants.defaultQuizSize;
  QuizQuestionType? _selectedQuestionType; // null = Mixed

  // Active session
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isSessionActive = false;
  bool _isSessionFinished = false;

  // Question answering state
  bool _isAnswered = false;
  bool _isCorrect = false;
  String? _selectedAnswer;
  List<String> _builtSentence = [];
  List<String> _remainingScrambledWords = [];

  // Scoring
  int _score = 0;
  int _correctCount = 0;
  int _streak = 0;
  int _bestStreakInSession = 0;

  // Speed quiz timer
  Timer? _speedTimer;
  int _timeRemaining = 7;

  // Suggestions
  List<QuizSuggestion> _suggestions = [];

  // Getters
  Set<String> get selectedCategoryIds => _selectedCategoryIds;
  int get selectedQuizSize => _selectedQuizSize;
  QuizQuestionType? get selectedQuestionType => _selectedQuestionType;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  bool get isSessionActive => _isSessionActive;
  bool get isSessionFinished => _isSessionFinished;

  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  bool get isAnswered => _isAnswered;
  bool get isCorrect => _isCorrect;
  String? get selectedAnswer => _selectedAnswer;
  List<String> get builtSentence => _builtSentence;
  List<String> get remainingScrambledWords => _remainingScrambledWords;

  int get score => _score;
  int get correctCount => _correctCount;
  int get streak => _streak;
  int get bestStreakInSession => _bestStreakInSession;
  int get timeRemaining => _timeRemaining;

  List<QuizSuggestion> get suggestions => _suggestions;
  List<QuizSuggestion> get pendingSuggestions =>
      _suggestions.where((s) => !s.isResolved).toList();
  List<QuizSuggestion> get resolvedSuggestions =>
      _suggestions.where((s) => s.isResolved).toList();

  Future<void> init() async {
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final rawList = _storage.getRawQuizSuggestions();
    _suggestions = rawList.map((m) => QuizSuggestion.fromMap(m)).toList();
    // Sort: most failed first, then recent
    _suggestions.sort((a, b) {
      if (b.failCount != a.failCount) {
        return b.failCount.compareTo(a.failCount);
      }
      return b.lastFailedDate.compareTo(a.lastFailedDate);
    });
    notifyListeners();
  }

  Future<void> _saveSuggestions() async {
    final rawList = _suggestions.map((s) => s.toMap()).toList();
    await _storage.saveRawQuizSuggestions(rawList);
  }

  // --- Configuration Methods ---
  void toggleCategory(String categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      if (_selectedCategoryIds.length > 1) {
        _selectedCategoryIds.remove(categoryId);
      }
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    notifyListeners();
  }

  void selectAllCategories(List<String> allCategoryIds) {
    _selectedCategoryIds = Set.from(allCategoryIds);
    notifyListeners();
  }

  void setQuizSize(int size) {
    _selectedQuizSize = size;
    notifyListeners();
  }

  void setQuestionType(QuizQuestionType? type) {
    _selectedQuestionType = type;
    notifyListeners();
  }

  // --- Start Quiz ---
  void startQuiz({
    required List<Flashcard> allCards,
    List<String>? initialCategoryIds,
  }) {
    if (initialCategoryIds != null && initialCategoryIds.isNotEmpty) {
      if (_selectedCategoryIds.isEmpty) {
        _selectedCategoryIds = Set.from(initialCategoryIds);
      }
    }

    final pool = _selectedCategoryIds.isEmpty
        ? allCards
        : allCards.where((c) => _selectedCategoryIds.contains(c.categoryId)).toList();

    _questions = _generator.generateQuiz(
      availableCards: pool.isNotEmpty ? pool : allCards,
      allPoolCards: allCards,
      count: _selectedQuizSize,
      specificType: _selectedQuestionType,
    );

    if (_questions.isEmpty) return;

    _currentIndex = 0;
    _isSessionActive = true;
    _isSessionFinished = false;
    _score = 0;
    _correctCount = 0;
    _streak = 0;
    _bestStreakInSession = 0;

    _setupCurrentQuestion();
    notifyListeners();
  }

  void _setupCurrentQuestion() {
    _isAnswered = false;
    _isCorrect = false;
    _selectedAnswer = null;
    _builtSentence = [];

    _speedTimer?.cancel();

    final q = currentQuestion;
    if (q == null) return;

    if (q.type == QuizQuestionType.buildSentence) {
      _remainingScrambledWords = List<String>.from(q.scrambledWords);
    } else if (q.type == QuizQuestionType.speedQuiz) {
      _timeRemaining = q.timeLimitSeconds;
      _startSpeedTimer();
    }
  }

  void _startSpeedTimer() {
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_isAnswered) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _speedTimer?.cancel();
        if (!_isAnswered) {
          // Time expired -> count as incorrect
          submitAnswer('');
        }
      }
    });
  }

  // --- Submitting Answers ---
  void submitAnswer(String answer) {
    if (_isAnswered || currentQuestion == null) return;

    _speedTimer?.cancel();
    _isAnswered = true;
    _selectedAnswer = answer;

    final q = currentQuestion!;
    final bool correct = answer.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();
    _isCorrect = correct;

    if (correct) {
      _correctCount++;
      _streak++;
      if (_streak > _bestStreakInSession) {
        _bestStreakInSession = _streak;
      }
      // Speed bonus
      int points = 100;
      if (q.type == QuizQuestionType.speedQuiz) {
        points += _timeRemaining * 20;
      }
      points += (_streak > 1 ? (_streak - 1) * 25 : 0);
      _score += points;
    } else {
      _streak = 0;
      // Record failure in Suggestions!
      _recordFailure(q);
    }

    notifyListeners();
  }

  // Build Sentence actions
  void addWordToBuiltSentence(int scrambledIndex) {
    if (_isAnswered) return;
    if (scrambledIndex >= 0 && scrambledIndex < _remainingScrambledWords.length) {
      final word = _remainingScrambledWords.removeAt(scrambledIndex);
      _builtSentence.add(word);
      notifyListeners();
    }
  }

  void removeWordFromBuiltSentence(int builtIndex) {
    if (_isAnswered) return;
    if (builtIndex >= 0 && builtIndex < _builtSentence.length) {
      final word = _builtSentence.removeAt(builtIndex);
      _remainingScrambledWords.add(word);
      notifyListeners();
    }
  }

  void submitBuiltSentence() {
    if (_isAnswered || currentQuestion == null) return;
    final userSentence = _builtSentence.join(' ');
    submitAnswer(userSentence);
  }

  void nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      _currentIndex++;
      _setupCurrentQuestion();
    } else {
      _isSessionFinished = true;
      _isSessionActive = false;
      _speedTimer?.cancel();
    }
    notifyListeners();
  }

  void exitQuiz() {
    _speedTimer?.cancel();
    _isSessionActive = false;
    _isSessionFinished = false;
    _questions = [];
    notifyListeners();
  }

  // --- Suggestions & Failure Recording ---
  void _recordFailure(QuizQuestion question) {
    final card = question.card;
    final existingIndex = _suggestions.indexWhere((s) => s.cardId == card.id);

    if (existingIndex >= 0) {
      final existing = _suggestions[existingIndex];
      _suggestions[existingIndex] = existing.copyWith(
        failCount: existing.failCount + 1,
        lastFailedDate: DateTime.now(),
        lastErrorTypeName: question.type.displayNameEs,
        isResolved: false, // Re-open if failed again
      );
    } else {
      _suggestions.insert(
        0,
        QuizSuggestion(
          cardId: card.id,
          categoryId: card.categoryId,
          wordEn: card.wordEn,
          wordEs: card.wordEs,
          example: card.example,
          exampleEs: card.exampleEs,
          grammarFormula: card.hasStructure ? card.structure : null,
          failCount: 1,
          lastFailedDate: DateTime.now(),
          lastErrorTypeName: question.type.displayNameEs,
          isResolved: false,
        ),
      );
    }

    _saveSuggestions();
  }

  Future<void> toggleSuggestionResolved(String cardId) async {
    final index = _suggestions.indexWhere((s) => s.cardId == cardId);
    if (index >= 0) {
      final current = _suggestions[index];
      _suggestions[index] = current.copyWith(isResolved: !current.isResolved);
      await _saveSuggestions();
      notifyListeners();
    }
  }

  Future<void> removeSuggestion(String cardId) async {
    _suggestions.removeWhere((s) => s.cardId == cardId);
    await _saveSuggestions();
    notifyListeners();
  }

  Future<void> clearAllSuggestions() async {
    _suggestions.clear();
    await _saveSuggestions();
    notifyListeners();
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    super.dispose();
  }
}
