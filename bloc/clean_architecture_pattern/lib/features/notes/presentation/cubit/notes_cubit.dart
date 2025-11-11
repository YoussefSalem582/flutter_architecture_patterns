import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_all_notes.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';
import 'notes_state.dart';

/// Notes Cubit - Presentation layer
/// Manages notes state using BLoC pattern
class NotesCubit extends Cubit<NotesState> {
  final GetAllNotes getAllNotes;
  final AddNote addNote;
  final DeleteNote deleteNote;
  final DeleteAllNotes deleteAllNotes;

  NotesCubit({
    required this.getAllNotes,
    required this.addNote,
    required this.deleteNote,
    required this.deleteAllNotes,
  }) : super(NotesInitial()) {
    loadNotes();
  }

  /// Load all notes from repository
  Future<void> loadNotes() async {
    emit(NotesLoading());
    final result = await getAllNotes(const NoParams());
    result.fold(
      (failure) {
        Logger.error('Failed to load notes: ${failure.message}', tag: 'CUBIT');
        emit(NotesError(failure.message));
      },
      (notes) {
        Logger.info('Notes loaded: ${notes.length} notes', tag: 'CUBIT');
        emit(NotesLoaded(notes));
      },
    );
  }

  /// Add a new note
  Future<void> addNewNote(String content) async {
    if (content.trim().isEmpty) {
      emit(const NotesError('Note content cannot be empty'));
      await loadNotes();
      return;
    }

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final result = await addNote(AddNoteParams(note));
    result.fold(
      (failure) {
        Logger.error('Failed to add note: ${failure.message}', tag: 'CUBIT');
        emit(NotesError(failure.message));
      },
      (_) {
        Logger.info('Note added successfully', tag: 'CUBIT');
        loadNotes();
      },
    );
  }

  /// Delete a note by ID
  Future<void> removeNote(String id) async {
    final result = await deleteNote(DeleteNoteParams(id));
    result.fold(
      (failure) {
        Logger.error('Failed to delete note: ${failure.message}', tag: 'CUBIT');
        emit(NotesError(failure.message));
      },
      (_) {
        Logger.info('Note deleted successfully', tag: 'CUBIT');
        loadNotes();
      },
    );
  }

  /// Delete all notes
  Future<void> removeAllNotes() async {
    final result = await deleteAllNotes(const NoParams());
    result.fold(
      (failure) {
        Logger.error(
          'Failed to delete all notes: ${failure.message}',
          tag: 'CUBIT',
        );
        emit(NotesError(failure.message));
      },
      (_) {
        Logger.info('All notes deleted successfully', tag: 'CUBIT');
        loadNotes();
      },
    );
  }
}
