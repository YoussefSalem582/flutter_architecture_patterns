import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/notes/usecases/add_note_usecase.dart';
import '../../../application/notes/usecases/delete_all_notes_usecase.dart';
import '../../../application/notes/usecases/delete_note_usecase.dart';
import '../../../application/notes/usecases/get_all_notes_usecase.dart';
import 'notes_state.dart';

/// Notes Cubit - Presentation Layer State Management
///
/// Manages notes state using BLoC pattern with Cubit.
/// Coordinates with use cases from the application layer.
/// Emits different states based on operation results.
class NotesCubit extends Cubit<NotesState> {
  final GetAllNotesUseCase getAllNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final DeleteAllNotesUseCase deleteAllNotesUseCase;

  NotesCubit({
    required this.getAllNotesUseCase,
    required this.addNoteUseCase,
    required this.deleteNoteUseCase,
    required this.deleteAllNotesUseCase,
  }) : super(const NotesInitial()) {
    // Load notes on initialization
    loadNotes();
  }

  /// Load all notes
  Future<void> loadNotes() async {
    emit(const NotesLoading());

    final result = await getAllNotesUseCase();

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesLoaded(notes)),
    );
  }

  /// Add a new note
  Future<void> addNote(String content) async {
    // Validate content before processing
    if (content.trim().isEmpty) {
      emit(const NotesError('Note content cannot be empty'));
      await loadNotes(); // Reload to reset state
      return;
    }

    emit(const NotesLoading());

    final result = await addNoteUseCase(content);

    await result.fold(
      (failure) async {
        emit(NotesError(failure.message));
        await loadNotes(); // Reload to show current state
      },
      (_) async {
        await loadNotes(); // Reload to show updated list
      },
    );
  }

  /// Delete a specific note
  Future<void> deleteNote(String noteId) async {
    emit(const NotesLoading());

    final result = await deleteNoteUseCase(noteId);

    await result.fold(
      (failure) async {
        emit(NotesError(failure.message));
        await loadNotes(); // Reload to show current state
      },
      (_) async {
        await loadNotes(); // Reload to show updated list
      },
    );
  }

  /// Delete all notes
  Future<void> deleteAllNotes() async {
    emit(const NotesLoading());

    final result = await deleteAllNotesUseCase();

    await result.fold(
      (failure) async {
        emit(NotesError(failure.message));
        await loadNotes(); // Reload to show current state
      },
      (_) async {
        await loadNotes(); // Reload to show updated list
      },
    );
  }
}
