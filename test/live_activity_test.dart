import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easyenglish/models/flashcard.dart';
import 'package:easyenglish/services/live_activity_service.dart';
import 'package:easyenglish/widgets/live_activity_pin_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveActivityService Tests', () {
    const sampleCard = Flashcard(
      id: 'card_take_care',
      categoryId: 'phrases',
      wordEn: 'Take care',
      wordEs: 'Cuídate / Cuidar',
      pronunciation: '/teɪk keər/',
      example: 'Take care of yourself.',
      exampleEs: 'Cuídate.',
      extraExamples: [
        'Take care when you cross the street.',
        'Take care of your little brother.',
        'Take care on your way home.'
      ],
    );

    test('LiveActivityService singleton instance is maintained', () {
      final s1 = LiveActivityService();
      final s2 = LiveActivityService();
      expect(identical(s1, s2), isTrue);
    });

    testWidgets('LiveActivityPinSheet renders preview and all elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveActivityPinSheet(card: sampleCard),
          ),
        ),
      );

      // Verify Main Learning Item is displayed (Never changes rule)
      expect(find.text('Take care'), findsOneWidget);
      expect(find.text('Cuídate / Cuidar'), findsOneWidget);
      expect(find.text('/teɪk keər/'), findsOneWidget);
      expect(find.text('Live Activities (iOS)'), findsOneWidget);

      // Verify Action Button
      expect(find.text('Activar Live Activities de Hoy'), findsOneWidget);

      // Verify Initial Example
      expect(find.text('Take care of yourself.'), findsOneWidget);

      // Verify 30-min default frequency option is present
      expect(find.text('30 min'), findsOneWidget);
    });
  });
}
