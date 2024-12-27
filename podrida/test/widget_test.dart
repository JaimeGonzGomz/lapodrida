import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podrida/game_demo_screen.dart';

void main() {
  testWidgets('Game screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(
      home: GameDemoScreen(),
    ));

    // Verify that we have 4 players
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
    expect(find.text('Player 4'), findsOneWidget);

    // Verify that we have the deal button
    expect(find.text('Deal New Round'), findsOneWidget);
  });
}
