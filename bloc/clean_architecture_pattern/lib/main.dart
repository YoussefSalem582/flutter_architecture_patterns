import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/presentation/views/home_view.dart';
import 'features/counter/presentation/views/counter_view.dart';
import 'features/notes/presentation/views/notes_view.dart';

/// Entry point of the application
/// Initializes dependencies before running the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await DependencyInjection.init();
  Logger.info('Dependencies initialized successfully', tag: 'MAIN');

  runApp(const MyApp());
}

/// Root widget configured with BLoC
/// Implements Clean Architecture with BLoC state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Notes App - Clean Architecture',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing configuration
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeView(),
        AppRoutes.counter: (context) => BlocProvider(
          create: (context) => DependencyInjection.createCounterCubit(),
          child: const CounterView(),
        ),
        AppRoutes.notes: (context) => BlocProvider(
          create: (context) => DependencyInjection.createNotesCubit(),
          child: const NotesView(),
        ),
      },
    );
  }
}
