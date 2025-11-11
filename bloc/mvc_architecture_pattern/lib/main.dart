import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'cubits/counter_cubit.dart';
import 'cubits/notes_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'views/home_view.dart';

/// Entry point of the Counter Notes App
/// Demonstrates MVC pattern with BLoC state management
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc for persistent state storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  runApp(const CounterNotesApp());
}

/// Root widget of the application
class CounterNotesApp extends StatelessWidget {
  const CounterNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide ThemeCubit globally
        BlocProvider(create: (context) => ThemeCubit()),

        // Provide CounterCubit globally
        BlocProvider(create: (context) => CounterCubit()),

        // Provide NotesCubit globally
        BlocProvider(create: (context) => NotesCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Counter Notes App - MVC',
            debugShowCheckedModeBanner: false,

            // Theme configuration - reactive theme switching
            theme: context.read<ThemeCubit>().currentTheme,

            // Home page
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
