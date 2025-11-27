import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/notes/note.dart';
import '../../domain/notes/i_note_repository.dart';

class NoteNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final INoteRepository _repository;

  NoteNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    final failureOrNotes = await _repository.getNotes();
    state = failureOrNotes.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (notes) => AsyncValue.data(notes),
    );
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(id: const Uuid().v4(), title: title, content: content);
    final failureOrSuccess = await _repository.addNote(note);
    failureOrSuccess.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => loadNotes(), // Reload to get fresh data
    );
  }

  Future<void> deleteNote(String id) async {
    final failureOrSuccess = await _repository.deleteNote(id);
    failureOrSuccess.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => loadNotes(),
    );
  }

  Future<void> clearNotes() async {
    final failureOrSuccess = await _repository.clearNotes();
    failureOrSuccess.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => loadNotes(),
    );
  }
}
