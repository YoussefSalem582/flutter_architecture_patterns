import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/theme_controller.dart';
import 'views/home_view.dart';
import 'views/counter_view.dart';
import 'views/notes_view.dart';

/// Entry point of the Counter Notes App
/// Demonstrates MVC pattern with GetX state management
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for persistent data storage
  await GetStorage.init();

  runApp(const CounterNotesApp());
}

/// Root widget of the application
class CounterNotesApp extends StatelessWidget {
  const CounterNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ThemeController globally
    final themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        title: 'Counter Notes App - MVC',
        debugShowCheckedModeBanner: false,

        // Theme configuration - reactive theme switching
        theme: themeController.currentTheme,

        // Navigation configuration
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => const HomeView(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 300),
          ),
          GetPage(
            name: '/counter',
            page: () => const CounterView(),
            transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 300),
          ),
          GetPage(
            name: '/notes',
            page: () => const NotesView(),
            transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ],

        // Default transition for all routes
        defaultTransition: Transition.fade,
      ),
    );
  }
}
