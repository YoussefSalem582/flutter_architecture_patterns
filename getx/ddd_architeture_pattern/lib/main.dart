import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'presentation/core/routes/app_pages.dart';
import 'presentation/core/routes/app_routes.dart';

/// Entry Point - DDD Architecture
///
/// In DDD:
/// - main.dart is the application entry point
/// - It initializes infrastructure (GetStorage)
/// - It sets up dependency injection container (GetX)
/// - It bootstraps the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize infrastructure (local storage)
  await GetStorage.init();

  // Register global storage instance
  Get.put(GetStorage());

  runApp(const MyApp());
}

/// Root Application Widget
///
/// Configured with:
/// - GetX for routing and state management
/// - Material Design 3 theme
/// - Route configuration
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Counter Notes App - DDD',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),

      // Routing
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,

      // Transitions
      defaultTransition: Transition.cupertino,
    );
  }
}
