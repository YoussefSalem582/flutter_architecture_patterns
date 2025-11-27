import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/notes_local_data_source.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/clear_notes.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../../counter/presentation/providers/counter_provider.dart'; // For sharedPreferencesProvider

// Dependency Injection via Providers

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  return NotesLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final notesRepositoryProvider = Provider<NotesRepositoryImpl>((ref) {
  return NotesRepositoryImpl(
    localDataSource: ref.watch(notesLocalDataSourceProvider),
  );
});

final getNotesUseCaseProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(notesRepositoryProvider));
});

final addNoteUseCaseProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(notesRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(notesRepositoryProvider));
});

final clearNotesUseCaseProvider = Provider<ClearNotes>((ref) {
  return ClearNotes(ref.watch(notesRepositoryProvider));
});

// StateNotifier

class NotesNotifier extends StateNotifier<List<Note>> {
  final GetNotes getNotes;
  final AddNote addNote;
  final DeleteNote deleteNote;
  final ClearNotes clearNotes;

  NotesNotifier({
    required this.getNotes,
    required this.addNote,
    required this.deleteNote,
    required this.clearNotes,
  }) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final result = await getNotes(NoParams());
    result.fold((failure) => null, (notes) => state = notes);
  }

  Future<void> add(String content) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
    );
    await addNote(AddNoteParams(note));
    await loadNotes();
  }

  Future<void> delete(String id) async {
    await deleteNote(DeleteNoteParams(id));
    await loadNotes();
  }

  Future<void> clear() async {
    await clearNotes(NoParams());
    await loadNotes();
  }
}

final notesNotifierProvider = StateNotifierProvider<NotesNotifier, List<Note>>((
  ref,
) {
  return NotesNotifier(
    getNotes: ref.watch(getNotesUseCaseProvider),
    addNote: ref.watch(addNoteUseCaseProvider),
    deleteNote: ref.watch(deleteNoteUseCaseProvider),
    clearNotes: ref.watch(clearNotesUseCaseProvider),
  );
});
