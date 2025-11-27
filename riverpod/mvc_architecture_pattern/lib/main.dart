import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/theme_controller.dart';
import 'views/home_view.dart';

/// Entry point of the Counter Notes App
/// Demonstrates MVC pattern with Riverpod state management
void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope is required for Riverpod to work
    const ProviderScope(
      child: CounterNotesApp(),
    ),
  );
}

/// Root widget of the application
class CounterNotesApp extends ConsumerWidget {
  const CounterNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeController = ref.read(themeProvider.notifier);

    return MaterialApp(
      title: 'Counter Notes App - MVC',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeMode,

      // Home page
      home: const HomeView(),
    );
  }
}
