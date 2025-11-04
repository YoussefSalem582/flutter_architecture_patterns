import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';

/// Entry point of the application
/// Initializes GetStorage before running the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for local persistence
  await GetStorage.init();
  Logger.info('GetStorage initialized successfully', tag: 'MAIN');

  runApp(const MyApp());
}

/// Root widget configured with GetX
/// Implements Clean Architecture with GetX state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Counter Notes App - Clean Architecture',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing configuration
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
