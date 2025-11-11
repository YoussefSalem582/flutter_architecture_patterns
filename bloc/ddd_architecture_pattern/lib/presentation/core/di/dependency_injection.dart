import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../application/counter/usecases/decrement_counter_usecase.dart';
import '../../../application/counter/usecases/get_counter_usecase.dart';
import '../../../application/counter/usecases/increment_counter_usecase.dart';
import '../../../application/counter/usecases/reset_counter_usecase.dart';
import '../../../application/notes/usecases/add_note_usecase.dart';
import '../../../application/notes/usecases/delete_all_notes_usecase.dart';
import '../../../application/notes/usecases/delete_note_usecase.dart';
import '../../../application/notes/usecases/get_all_notes_usecase.dart';
import '../../../domain/counter/repositories/counter_repository.dart';
import '../../../domain/notes/repositories/notes_repository.dart';
import '../../../infrastructure/counter/datasources/counter_local_datasource.dart';
import '../../../infrastructure/counter/repositories/counter_repository_impl.dart';
import '../../../infrastructure/notes/datasources/notes_local_datasource.dart';
import '../../../infrastructure/notes/repositories/notes_repository_impl.dart';
import '../../counter/cubit/counter_cubit.dart';
import '../../notes/cubit/notes_cubit.dart';

/// Dependency Injection Container
///
/// Manages all dependencies for the application.
/// Implements manual DI for DDD architecture.
class DependencyInjection {
  static late SharedPreferences _sharedPreferences;
  static late Uuid _uuid;

  /// Initialize dependencies
  static Future<void> init() async {
    // External dependencies
    _sharedPreferences = await SharedPreferences.getInstance();
    _uuid = const Uuid();
  }

  // Counter Feature Dependencies

  static CounterLocalDataSource get counterLocalDataSource =>
      CounterLocalDataSourceImpl(_sharedPreferences);

  static CounterRepository get counterRepository =>
      CounterRepositoryImpl(counterLocalDataSource);

  static GetCounterUseCase get getCounterUseCase =>
      GetCounterUseCase(counterRepository);

  static IncrementCounterUseCase get incrementCounterUseCase =>
      IncrementCounterUseCase(counterRepository);

  static DecrementCounterUseCase get decrementCounterUseCase =>
      DecrementCounterUseCase(counterRepository);

  static ResetCounterUseCase get resetCounterUseCase =>
      ResetCounterUseCase(counterRepository);

  static CounterCubit createCounterCubit() {
    return CounterCubit(
      getCounterUseCase: getCounterUseCase,
      incrementCounterUseCase: incrementCounterUseCase,
      decrementCounterUseCase: decrementCounterUseCase,
      resetCounterUseCase: resetCounterUseCase,
    );
  }

  // Notes Feature Dependencies

  static NotesLocalDataSource get notesLocalDataSource =>
      NotesLocalDataSourceImpl(_sharedPreferences);

  static NotesRepository get notesRepository =>
      NotesRepositoryImpl(notesLocalDataSource);

  static GetAllNotesUseCase get getAllNotesUseCase =>
      GetAllNotesUseCase(notesRepository);

  static AddNoteUseCase get addNoteUseCase =>
      AddNoteUseCase(notesRepository, _uuid);

  static DeleteNoteUseCase get deleteNoteUseCase =>
      DeleteNoteUseCase(notesRepository);

  static DeleteAllNotesUseCase get deleteAllNotesUseCase =>
      DeleteAllNotesUseCase(notesRepository);

  static NotesCubit createNotesCubit() {
    return NotesCubit(
      getAllNotesUseCase: getAllNotesUseCase,
      addNoteUseCase: addNoteUseCase,
      deleteNoteUseCase: deleteNoteUseCase,
      deleteAllNotesUseCase: deleteAllNotesUseCase,
    );
  }
}
