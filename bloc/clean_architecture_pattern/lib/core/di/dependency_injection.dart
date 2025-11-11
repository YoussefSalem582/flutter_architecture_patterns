import 'package:shared_preferences/shared_preferences.dart';
import '../../features/counter/data/datasources/counter_local_datasource.dart';
import '../../features/counter/data/repositories/counter_repository_impl.dart';
import '../../features/counter/domain/repositories/counter_repository.dart';
import '../../features/counter/domain/usecases/decrement_counter.dart';
import '../../features/counter/domain/usecases/get_counter.dart';
import '../../features/counter/domain/usecases/increment_counter.dart';
import '../../features/counter/domain/usecases/reset_counter.dart';
import '../../features/counter/presentation/cubit/counter_cubit.dart';
import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/add_note.dart';
import '../../features/notes/domain/usecases/delete_all_notes.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/get_all_notes.dart';
import '../../features/notes/presentation/cubit/notes_cubit.dart';

/// Dependency Injection Container
/// Manages all dependencies for the application
class DependencyInjection {
  static late SharedPreferences _sharedPreferences;

  /// Initialize dependencies
  static Future<void> init() async {
    // External dependencies
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Counter Feature Dependencies

  static CounterLocalDataSource get counterLocalDataSource =>
      CounterLocalDataSourceImpl(_sharedPreferences);

  static CounterRepository get counterRepository =>
      CounterRepositoryImpl(counterLocalDataSource);

  static GetCounter get getCounter => GetCounter(counterRepository);
  static IncrementCounter get incrementCounter =>
      IncrementCounter(counterRepository);
  static DecrementCounter get decrementCounter =>
      DecrementCounter(counterRepository);
  static ResetCounter get resetCounter => ResetCounter(counterRepository);

  static CounterCubit createCounterCubit() {
    return CounterCubit(
      getCounter: getCounter,
      incrementCounter: incrementCounter,
      decrementCounter: decrementCounter,
      resetCounter: resetCounter,
    );
  }

  // Notes Feature Dependencies

  static NotesLocalDataSource get notesLocalDataSource =>
      NotesLocalDataSourceImpl(_sharedPreferences);

  static NotesRepository get notesRepository =>
      NotesRepositoryImpl(notesLocalDataSource);

  static GetAllNotes get getAllNotes => GetAllNotes(notesRepository);
  static AddNote get addNote => AddNote(notesRepository);
  static DeleteNote get deleteNote => DeleteNote(notesRepository);
  static DeleteAllNotes get deleteAllNotes => DeleteAllNotes(notesRepository);

  static NotesCubit createNotesCubit() {
    return NotesCubit(
      getAllNotes: getAllNotes,
      addNote: addNote,
      deleteNote: deleteNote,
      deleteAllNotes: deleteAllNotes,
    );
  }
}
