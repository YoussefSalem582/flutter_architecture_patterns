import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'config/app_themes.dart';
import 'views/home_view.dart';
import 'views/counter_view.dart';
import 'views/notes_view.dart';

/// Main entry point of the Counter Notes App
/// Demonstrates MVVM architecture pattern with BLoC
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      routes: {
        AppRoutes.home: (context) => const HomeView(),
        AppRoutes.counter: (context) => const CounterView(),
        AppRoutes.notes: (context) => const NotesView(),
      },
    );
  }
}
