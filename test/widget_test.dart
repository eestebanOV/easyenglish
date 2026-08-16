import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easyenglish/widgets/streak_badge.dart';

void main() {
  testWidgets('Streak badge renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakBadge(streakDays: 5),
        ),
      ),
    );
    expect(find.text('5 días'), findsOneWidget);
  });
}


