import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for Theme management
/// Handles light/dark theme switching using GetX
class ThemeController extends GetxController {
  // Reactive theme mode
  final _isDarkMode = false.obs;

  // Getter for theme mode
  bool get isDarkMode => _isDarkMode.value;

  // Get current theme data
  ThemeData get currentTheme => isDarkMode ? _darkTheme : _lightTheme;

  /// Toggle between light and dark theme
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(currentTheme);
    Get.snackbar(
      'Theme Changed',
      'Switched to ${isDarkMode ? 'Dark' : 'Light'} mode',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Light theme configuration
  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );

  /// Dark theme configuration
  ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );
}
