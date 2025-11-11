// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mvc_architeture_pattern/main.dart';
import 'package:mvc_architeture_pattern/controllers/theme_controller.dart';

void main() {
  testWidgets('Counter Notes App smoke test', (WidgetTester tester) async {
    // Initialize ThemeController for testing
    Get.put(ThemeController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const CounterNotesApp());

    // Verify that Counter screen is shown initially
    expect(find.text('Counter Screen'), findsOneWidget);
    expect(find.text('Current Count'), findsOneWidget);

    // Verify initial counter value is 0
    expect(find.text('0'), findsOneWidget);
  });
}
