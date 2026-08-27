import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Configuration for item-based daily notifications with rotating examples
class ItemNotificationConfig {
  final String cardId;
  final String categoryId;
  final String wordEn;
  final String wordEs;
  final String? grammarFormula;
  final List<String> examples;
  final List<TimeOfDay> times;
  final int intervalMinutes;
  final int currentExampleIndex;
  final bool isEnabled;

  const ItemNotificationConfig({
    required this.cardId,
    required this.categoryId,
    required this.wordEn,
    required this.wordEs,
    this.grammarFormula,
    required this.examples,
    required this.times,
    this.intervalMinutes = AppConstants.defaultNotificationInterval,
    this.currentExampleIndex = 0,
    this.isEnabled = true,
  });

  bool get hasGrammarFormula => grammarFormula != null && grammarFormula!.trim().isNotEmpty;

  ItemNotificationConfig copyWith({
    String? cardId,
    String? categoryId,
    String? wordEn,
    String? wordEs,
    String? grammarFormula,
    List<String>? examples,
    List<TimeOfDay>? times,
    int? intervalMinutes,
    int? currentExampleIndex,
    bool? isEnabled,
  }) {
    return ItemNotificationConfig(
      cardId: cardId ?? this.cardId,
      categoryId: categoryId ?? this.categoryId,
      wordEn: wordEn ?? this.wordEn,
      wordEs: wordEs ?? this.wordEs,
      grammarFormula: grammarFormula ?? this.grammarFormula,
      examples: examples ?? this.examples,
      times: times ?? this.times,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      currentExampleIndex: currentExampleIndex ?? this.currentExampleIndex,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'categoryId': categoryId,
      'wordEn': wordEn,
      'wordEs': wordEs,
      'grammarFormula': grammarFormula,
      'examples': examples,
      'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'intervalMinutes': intervalMinutes,
      'currentExampleIndex': currentExampleIndex,
      'isEnabled': isEnabled,
    };
  }

  factory ItemNotificationConfig.fromMap(Map<dynamic, dynamic> map) {
    List<TimeOfDay> loadedTimes = [];
    if (map['times'] is List) {
      for (var item in (map['times'] as List)) {
        if (item is Map) {
          loadedTimes.add(
            TimeOfDay(
              hour: item['hour'] as int? ?? 9,
              minute: item['minute'] as int? ?? 0,
            ),
          );
        }
      }
    }

    if (loadedTimes.isEmpty) {
      loadedTimes = const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 8, minute: 30),
        TimeOfDay(hour: 9, minute: 0),
      ];
    }

    List<String> loadedExamples = [];
    if (map['examples'] is List) {
      loadedExamples = (map['examples'] as List).map((e) => e.toString()).toList();
    }

    return ItemNotificationConfig(
      cardId: map['cardId'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      wordEn: map['wordEn'] as String? ?? '',
      wordEs: map['wordEs'] as String? ?? '',
      grammarFormula: map['grammarFormula'] as String?,
      examples: loadedExamples,
      times: loadedTimes,
      intervalMinutes: map['intervalMinutes'] as int? ?? AppConstants.defaultNotificationInterval,
      currentExampleIndex: map['currentExampleIndex'] as int? ?? 0,
      isEnabled: map['isEnabled'] as bool? ?? true,
    );
  }
}
