// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smartfruit_ai/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartFruitApp());

    // Verify that our app name is present on the Splash Screen
    await tester.runAsync(() async {
      await tester.pumpWidget(const SmartFruitApp());
      expect(find.text('SmartFruit AI'), findsOneWidget);
      
      // Let the timer elapse in the asynchronous background
      await Future.delayed(const Duration(seconds: 5));
      await tester.pump();
    });
  });
}
