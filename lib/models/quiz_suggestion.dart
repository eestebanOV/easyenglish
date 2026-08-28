/// Represents a vocabulary item that was failed during a quiz, recommended for review
class QuizSuggestion {
  final String cardId;
  final String categoryId;
  final String wordEn;
  final String wordEs;
  final String example;
  final String exampleEs;
  final String? grammarFormula;
  final int failCount;
  final DateTime lastFailedDate;
  final String lastErrorTypeName;
  final bool isResolved;

  const QuizSuggestion({
    required this.cardId,
    required this.categoryId,
    required this.wordEn,
    required this.wordEs,
    required this.example,
    required this.exampleEs,
    this.grammarFormula,
    this.failCount = 1,
    required this.lastFailedDate,
    required this.lastErrorTypeName,
    this.isResolved = false,
  });

  QuizSuggestion copyWith({
    String? cardId,
    String? categoryId,
    String? wordEn,
    String? wordEs,
    String? example,
    String? exampleEs,
    String? grammarFormula,
    int? failCount,
    DateTime? lastFailedDate,
    String? lastErrorTypeName,
    bool? isResolved,
  }) {
    return QuizSuggestion(
      cardId: cardId ?? this.cardId,
      categoryId: categoryId ?? this.categoryId,
      wordEn: wordEn ?? this.wordEn,
      wordEs: wordEs ?? this.wordEs,
      example: example ?? this.example,
      exampleEs: exampleEs ?? this.exampleEs,
      grammarFormula: grammarFormula ?? this.grammarFormula,
      failCount: failCount ?? this.failCount,
      lastFailedDate: lastFailedDate ?? this.lastFailedDate,
      lastErrorTypeName: lastErrorTypeName ?? this.lastErrorTypeName,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'categoryId': categoryId,
      'wordEn': wordEn,
      'wordEs': wordEs,
      'example': example,
      'exampleEs': exampleEs,
      'grammarFormula': grammarFormula,
      'failCount': failCount,
      'lastFailedDate': lastFailedDate.toIso8601String(),
      'lastErrorTypeName': lastErrorTypeName,
      'isResolved': isResolved,
    };
  }

  factory QuizSuggestion.fromMap(Map<dynamic, dynamic> map) {
    return QuizSuggestion(
      cardId: map['cardId'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      wordEn: map['wordEn'] as String? ?? '',
      wordEs: map['wordEs'] as String? ?? '',
      example: map['example'] as String? ?? '',
      exampleEs: map['exampleEs'] as String? ?? '',
      grammarFormula: map['grammarFormula'] as String?,
      failCount: map['failCount'] as int? ?? 1,
      lastFailedDate: map['lastFailedDate'] != null
          ? DateTime.tryParse(map['lastFailedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastErrorTypeName: map['lastErrorTypeName'] as String? ?? 'Quiz',
      isResolved: map['isResolved'] as bool? ?? false,
    );
  }
}
