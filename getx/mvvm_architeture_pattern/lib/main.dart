import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'config/app_themes.dart';

/// Main entry point of the Counter Notes App
/// Demonstrates MVVM architecture pattern with GetX
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App Title
      title: 'Counter Notes App - MVVM',

      // Debug Banner
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,

      // Default Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
