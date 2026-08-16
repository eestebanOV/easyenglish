import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import '../core/srs_engine.dart';
import '../models/flashcard.dart';
import '../models/card_progress.dart';
import '../models/category.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Category> _categories = [];
  List<Flashcard> _allCards = [];
  Map<String, CardProgress> _progressMap = {};
  UserStats _stats = UserStats();
  bool _isLoading = true;

  List<Category> get categories => _categories;
  List<Flashcard> get allCards => _allCards;
  Map<String, CardProgress> get progressMap => _progressMap;
  UserStats get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.init();
      await _loadVocabulary();
      _progressMap = _storage.getAllCardProgress();
      _stats = _storage.getUserStats();
      _checkStreak();
    } catch (e) {
      debugPrint('Error initializing FlashcardProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadVocabulary() async {
    final String response = await rootBundle.loadString('assets/data/vocabulary.json');
    final data = json.decode(response);
    final categoriesJson = data['categories'] as List;

    _categories = [];
    _allCards = [];

    for (var catJson in categoriesJson) {
      final category = Category.fromJson(catJson);
      _categories.add(category);

      final cardsJson = catJson['cards'] as List;
      for (var cardJson in cardsJson) {
        _allCards.add(Flashcard.fromJson(cardJson, category.id));
      }
    }
  }

  void _checkStreak() {
    final now = DateTime.now();
    if (_stats.lastStudyDate != null) {
      final lastDate = _stats.lastStudyDate!;
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (difference == 0) {
        // Same day, streak intact
      } else if (difference == 1) {
        // Yesterday, streak continues
        _stats.reviewsToday = 0;
      } else {
        // Missed more than a day, streak broken
        _stats.streakDays = 0;
        _stats.reviewsToday = 0;
      }
    }
    _storage.saveUserStats(_stats);
  }

  CardProgress getProgressForCard(String cardId) {
    return _progressMap[cardId] ?? CardProgress(cardId: cardId);
  }

  List<Flashcard> getDueCards({String? categoryId, int? limit}) {
    List<Flashcard> filteredCards = categoryId != null
        ? _allCards.where((card) => card.categoryId == categoryId).toList()
        : List.from(_allCards);

    // Sort by priority:
    // 1. Cards due for review (earliest nextReview first)
    // 2. New cards (never studied)
    // 3. Cards not yet due
    final now = DateTime.now();

    List<Flashcard> dueReview = [];
    List<Flashcard> newCards = [];
    List<Flashcard> futureReview = [];

    for (var card in filteredCards) {
      final progress = _progressMap[card.id];
      if (progress == null || progress.isNew) {
        newCards.add(card);
      } else if (progress.nextReview != null && now.isAfter(progress.nextReview!)) {
        dueReview.add(card);
      } else {
        futureReview.add(card);
      }
    }

    // Due reviews get priority, followed by new cards
    List<Flashcard> result = [...dueReview, ...newCards];
    if (result.isEmpty) {
      result = futureReview; // If everything is done, allow reviewing future cards
    }

    if (limit != null && result.length > limit) {
      return result.sublist(0, limit);
    }
    return result;
  }

  int get totalLearnedCount {
    return _progressMap.values.where((p) => p.repetitions >= 1).length;
  }

  int get totalMasteredCount {
    return _progressMap.values.where((p) => p.repetitions >= 4).length;
  }

  double getCategoryMastery(String categoryId) {
    final catCards = _allCards.where((c) => c.categoryId == categoryId).toList();
    if (catCards.isEmpty) return 0.0;

    int learned = 0;
    for (var card in catCards) {
      final progress = _progressMap[card.id];
      if (progress != null && progress.repetitions >= 1) {
        learned++;
      }
    }
    return (learned / catCards.length) * 100;
  }

  Future<void> recordCardReview(String cardId, int quality) async {
    final currentProgress = getProgressForCard(cardId);

    final srsResult = SrsEngine.calculateNextReview(
      quality: quality,
      easeFactor: currentProgress.easeFactor,
      interval: currentProgress.interval,
      repetitions: currentProgress.repetitions,
    );

    currentProgress.easeFactor = srsResult.easeFactor;
    currentProgress.interval = srsResult.interval;
    currentProgress.repetitions = srsResult.repetitions;
    currentProgress.nextReview = srsResult.nextReview;
    currentProgress.lastReview = DateTime.now();

    _progressMap[cardId] = currentProgress;
    await _storage.saveCardProgress(currentProgress);

    // Update global user stats
    final now = DateTime.now();
    _stats.totalReviews++;
    _stats.reviewsToday++;

    if (_stats.lastStudyDate == null ||
        DateTime(now.year, now.month, now.day).isAfter(DateTime(
          _stats.lastStudyDate!.year,
          _stats.lastStudyDate!.month,
          _stats.lastStudyDate!.day,
        ))) {
      _stats.streakDays++;
      if (_stats.streakDays > _stats.bestStreak) {
        _stats.bestStreak = _stats.streakDays;
      }
    }
    _stats.lastStudyDate = now;
    _stats.totalCardsLearned = totalLearnedCount;

    await _storage.saveUserStats(_stats);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _storage.clearAllProgress();
    _progressMap.clear();
    _stats = UserStats();
    await _storage.saveUserStats(_stats);
    notifyListeners();
  }
}
