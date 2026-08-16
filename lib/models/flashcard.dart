/// Model representing a vocabulary flashcard
class Flashcard {
  final String id;
  final String wordEn;
  final String wordEs;
  final String pronunciation;
  final String example;
  final String exampleEs;
  final String categoryId;
  final String? present;
  final String? past;
  final String? participle;

  final List<String>? extraExamples;

  const Flashcard({
    required this.id,
    required this.wordEn,
    required this.wordEs,
    required this.pronunciation,
    required this.example,
    required this.exampleEs,
    required this.categoryId,
    this.present,
    this.past,
    this.participle,
    this.extraExamples,
  });

  bool get isVerbWithForms => present != null && past != null && participle != null;

  /// Returns all available examples for widget timeline rotation
  List<String> get allExamples {
    if (extraExamples != null && extraExamples!.isNotEmpty) {
      return [example, ...extraExamples!];
    }
    return [example];
  }

  factory Flashcard.fromJson(Map<String, dynamic> json, String categoryId) {
    List<String>? extra;
    if (json['extraExamples'] is List) {
      extra = (json['extraExamples'] as List).map((e) => e.toString()).toList();
    } else if (json['examples'] is List) {
      final list = (json['examples'] as List).map((e) => e.toString()).toList();
      if (list.length > 1) {
        extra = list.sublist(1);
      }
    }

    return Flashcard(
      id: json['id'] as String,
      wordEn: json['wordEn'] as String,
      wordEs: json['wordEs'] as String,
      pronunciation: json['pronunciation'] as String,
      example: json['example'] as String? ?? (json['examples'] != null && (json['examples'] as List).isNotEmpty ? json['examples'][0] : ''),
      exampleEs: json['exampleEs'] as String? ?? '',
      categoryId: categoryId,
      present: json['present'] as String?,
      past: json['past'] as String?,
      participle: json['participle'] as String?,
      extraExamples: extra,
    );
  }
}

