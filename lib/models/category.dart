import 'package:flutter/material.dart';

/// Model representing a vocabulary category
class Category {
  final String id;
  final String name;
  final String nameEs;
  final String icon;
  final Color color;
  final int cardCount;

  const Category({
    required this.id,
    required this.name,
    required this.nameEs,
    required this.icon,
    required this.color,
    required this.cardCount,
  });

  /// Modern vector icon for the category
  IconData get vectorIcon {
    switch (id) {
      case 'phrases':
        return Icons.chat_bubble_outline_rounded;
      case 'phrasal_verbs':
        return Icons.bolt_rounded;
      case 'irregular_verbs':
        return Icons.menu_book_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'daily_life':
        return Icons.coffee_rounded;
      case 'common_words':
        return Icons.auto_stories_rounded;
      case 'verb_tenses':
        return Icons.schedule_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEs: json['nameEs'] as String,
      icon: json['icon'] as String,
      color: _parseColor(json['color'] as String),
      cardCount: (json['cards'] as List).length,
    );
  }

  static Color _parseColor(String hexString) {
    hexString = hexString.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }
    return Color(int.parse(hexString, radix: 16));
  }
}
