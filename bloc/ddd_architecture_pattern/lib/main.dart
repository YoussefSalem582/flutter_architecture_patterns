import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/core/di/dependency_injection.dart';
import 'presentation/core/routes/app_routes.dart';
import 'presentation/core/theme/app_theme.dart';
import 'presentation/core/views/home_view.dart';
import 'presentation/counter/views/counter_view.dart';
import 'presentation/notes/views/notes_view.dart';

/// Entry point of the application
/// Initializes dependencies before running the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await DependencyInjection.init();

  runApp(const MyApp());
}

/// Root widget configured with BLoC
/// Implements DDD Architecture with BLoC state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Notes App - DDD Architecture',
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
