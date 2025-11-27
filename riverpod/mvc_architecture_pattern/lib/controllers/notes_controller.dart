import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

/// Controller for Notes functionality
/// Manages notes list and business logic using StateNotifier
class NotesController extends StateNotifier<List<NoteModel>> {
  NotesController() : super([]) {
    _loadState();
  }

  /// Load state from SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes_list');

    if (notesJson != null) {
      state = notesJson
          .map((note) => NoteModel.fromJson(jsonDecode(note)))
          .toList();
    } else {
      _addSampleNotesQuietly();
    }
  }

  /// Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = state.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes_list', notesJson);
  }

  /// Add sample notes without notifications (only on first run)
  void _addSampleNotesQuietly() {
    final note1 = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Welcome to Counter Notes App!',
    );
    final note2 = NoteModel.create(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: 'This app demonstrates MVC pattern with Riverpod',
    );
    state = [note1, note2];
    _saveState();
  }

  /// Add a new note
  void addNote(String content) {
    if (content.trim().isEmpty) return;

    final note = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
    );

    state = [...state, note];
    _saveState();
  }

  /// Delete a note by id
  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
    _saveState();
  }

  /// Clear all notes
  void clearAllNotes() {
    state = [];
    _saveState();
  }

  /// Check if notes list is empty
  bool get isEmpty => state.isEmpty;

  /// Get notes count
  int get notesCount => state.length;
}

/// Provider for NotesController
final notesProvider = StateNotifierProvider<NotesController, List<NoteModel>>((
  ref,
) {
  return NotesController();
});
