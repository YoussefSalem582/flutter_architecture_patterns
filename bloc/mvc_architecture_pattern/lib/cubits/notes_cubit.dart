import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/note_model.dart';

/// Cubit for Notes functionality
/// Manages notes list and business logic using Cubit
/// Uses HydratedCubit for automatic state persistence across app restarts
class NotesCubit extends HydratedCubit<List<NoteModel>> {
  NotesCubit() : super([]) {
    // Add sample notes only if no saved notes exist
    if (state.isEmpty) {
      _addSampleNotesQuietly();
    }
  }

  /// Check if notes list is empty
  bool get isEmpty => state.isEmpty;

  /// Get notes count
  int get notesCount => state.length;

  /// Add sample notes without notifications (only on first run)
  void _addSampleNotesQuietly() {
    final note1 = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Welcome to Counter Notes App!',
    );
    final note2 = NoteModel.create(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: 'This app demonstrates MVC pattern with BLoC',
    );
    emit([note1, note2]);
  }

  /// Add a new note
  void addNote(String content) {
    if (content.trim().isEmpty) {
      return;
    }

    final note = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
    );

    emit([...state, note]);
  }

  /// Delete a note by id
  void deleteNote(String id) {
    emit(state.where((note) => note.id != id).toList());
  }

  /// Clear all notes
  void clearAllNotes() {
    emit([]);
  }

  @override
  List<NoteModel>? fromJson(Map<String, dynamic> json) {
    final notesList = json['notes'] as List;
    return notesList
        .map((noteJson) => NoteModel.fromJson(noteJson as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic>? toJson(List<NoteModel> state) {
    return {'notes': state.map((note) => note.toJson()).toList()};
  }
}
