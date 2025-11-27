import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/counter/i_counter_repository.dart';
import '../../domain/notes/i_note_repository.dart';
import '../../infrastructure/counter/counter_repository.dart';
import '../../infrastructure/notes/note_repository.dart';
import '../../application/counter/counter_notifier.dart';
import '../../application/notes/note_notifier.dart';
import '../../domain/counter/counter.dart';
import '../../domain/notes/note.dart';

// Infrastructure Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Overridden in main.dart
});

final counterRepositoryProvider = Provider<ICounterRepository>((ref) {
  return CounterRepository(ref.watch(sharedPreferencesProvider));
});

final noteRepositoryProvider = Provider<INoteRepository>((ref) {
  return NoteRepository(ref.watch(sharedPreferencesProvider));
});

// Application Providers
final counterNotifierProvider = StateNotifierProvider<CounterNotifier, Counter>(
  (ref) {
    return CounterNotifier(ref.watch(counterRepositoryProvider));
  },
);

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<List<Note>>>((ref) {
      return NoteNotifier(ref.watch(noteRepositoryProvider));
    });
