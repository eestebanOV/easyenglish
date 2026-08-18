import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'live_activity_pin_sheet.dart';

/// Legacy export/wrapper for WidgetPinSheet which now opens LiveActivityPinSheet
class WidgetPinSheet extends StatelessWidget {
  final Flashcard card;

  const WidgetPinSheet({
    super.key,
    required this.card,
  });

  static Future<bool?> show(BuildContext context, Flashcard card) {
    return LiveActivityPinSheet.show(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return LiveActivityPinSheet(card: card);
  }
}
