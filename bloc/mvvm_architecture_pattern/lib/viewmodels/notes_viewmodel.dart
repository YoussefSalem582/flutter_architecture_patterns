import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';

/// Notes ViewModel (Cubit)
/// Contains reactive data and business logic for the notes feature
/// Uses Cubit to enable reactive UI updates via BlocBuilder
class NotesViewModel extends Cubit<List<NoteModel>> {
  NotesViewModel() : super([]) {
    // Add some sample notes for demonstration
    _loadSampleNotes();
  }

  /// Getter to check if notes list is empty
  bool get hasNotes => state.isNotEmpty;

  /// Getter for notes count
  int get notesCount => state.length;

  /// Add a new note to the list
  void addNote(String content) {
    if (content.trim().isEmpty) {
      return;
    }

    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    emit([...state, note]);
  }

  /// Delete a note by its ID
  void deleteNote(String id) {
    emit(state.where((note) => note.id != id).toList());
  }

  /// Delete all notes
  void deleteAllNotes() {
    emit([]);
  }

  /// Update a note's content
  void updateNote(String id, String newContent) {
    if (newContent.trim().isEmpty) {
      return;
    }

    final updatedNotes = state.map((note) {
      if (note.id == id) {
        return note.copyWith(content: newContent.trim());
      }
      return note;
    }).toList();

    emit(updatedNotes);
  }

  void _loadSampleNotes() {
    final sampleNotes = [
      NoteModel(
        id: '1',
        content: 'Welcome to Counter Notes App!',
        createdAt: DateTime.now(),
      ),
      NoteModel(
        id: '2',
        content: 'This is a sample note using MVVM with BLoC',
        createdAt: DateTime.now(),
      ),
    ];
    emit(sampleNotes);
  }

  @override
  void onChange(Change<List<NoteModel>> change) {
    super.onChange(change);
    print(
      'NotesViewModel changed: ${change.currentState.length} -> ${change.nextState.length} notes',
    );
  }

  @override
  Future<void> close() {
    print('NotesViewModel disposed');
    return super.close();
  }
}
