import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mvc_architeture_pattern/main.dart';
import 'package:mvc_architeture_pattern/controllers/theme_controller.dart';
import 'package:mvc_architeture_pattern/controllers/counter_controller.dart';

void main() {
  group('Navigation and Routing Tests', () {
    setUp(() {
      // Reset GetX before each test
      Get.reset();
    });

    testWidgets('App should start on Counter screen', (
      WidgetTester tester,
    ) async {
      // Initialize ThemeController for testing
      Get.put(ThemeController());

      // Build our app
      await tester.pumpWidget(const CounterNotesApp());
      await tester.pump();

      // Verify we start on Counter screen
      expect(find.text('Counter Screen'), findsOneWidget);
      expect(find.text('Current Count'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Should navigate from Counter to Notes screen', (
      WidgetTester tester,
    ) async {
      // Initialize ThemeController for testing
      Get.put(ThemeController());

      // Build our app
      await tester.pumpWidget(const CounterNotesApp());
      await tester.pump();

      // Verify we start on Counter screen
      expect(find.text('Counter Screen'), findsOneWidget);

      // Find and tap the notes navigation button
      final notesButton = find.byIcon(Icons.note_alt_outlined);
      expect(notesButton, findsOneWidget);
      await tester.tap(notesButton);
      await tester.pumpAndSettle();

      // Verify we navigated to Notes screen
      expect(find.text('Notes Screen'), findsOneWidget);
      expect(find.text('Counter Screen'), findsNothing);
    });

    testWidgets(
      'Should navigate back from Notes to Counter using back button',
      (WidgetTester tester) async {
        // Initialize ThemeController for testing
        Get.put(ThemeController());

        // Build our app
        await tester.pumpWidget(const CounterNotesApp());
        await tester.pump();

        // Navigate to Notes screen
        final notesButton = find.byIcon(Icons.note_alt_outlined);
        await tester.tap(notesButton);
        await tester.pumpAndSettle();

        // Verify we're on Notes screen
        expect(find.text('Notes Screen'), findsOneWidget);

        // Find and tap the back button (default system back button)
        final backButton = find.byType(BackButton);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify we're back on Counter screen
        expect(find.text('Counter Screen'), findsOneWidget);
        expect(find.text('Notes Screen'), findsNothing);
      },
    );

    testWidgets('Counter controller increments correctly', (
      WidgetTester tester,
    ) async {
      // Initialize controllers
      Get.put(ThemeController());
      final counterController = Get.put(CounterController());

      // Build our app
      await tester.pumpWidget(const CounterNotesApp());
      await tester.pump();

      // Verify initial counter value
      expect(counterController.counterValue, 0);
      expect(find.text('0'), findsOneWidget);

      // Call increment directly (avoid UI button issues in tests)
      counterController.increment();
      await tester.pump();

      // Verify counter incremented
      expect(counterController.counterValue, 1);
    });

    testWidgets('Theme toggle works correctly', (WidgetTester tester) async {
      // Initialize ThemeController for testing
      final themeController = Get.put(ThemeController());

      // Build our app
      await tester.pumpWidget(const CounterNotesApp());
      await tester.pump();

      // Verify initial theme (light mode)
      expect(themeController.isDarkMode, false);

      // Toggle theme directly
      themeController.toggleTheme();
      await tester.pump();

      // Verify theme changed to dark
      expect(themeController.isDarkMode, true);

      // Toggle back
      themeController.toggleTheme();
      await tester.pump();

      // Verify theme changed to light
      expect(themeController.isDarkMode, false);
    });
  });
}
