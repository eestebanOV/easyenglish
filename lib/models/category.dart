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
