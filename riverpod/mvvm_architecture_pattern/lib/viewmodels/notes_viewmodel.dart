import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../providers/app_providers.dart';

class NotesViewModel extends StateNotifier<List<Note>> {
  final SharedPreferences _prefs;

  NotesViewModel(this._prefs) : super([]) {
    _loadNotes();
  }

  void _loadNotes() {
    final notesJson = _prefs.getStringList('notes') ?? [];
    state = notesJson
        .map((noteStr) => Note.fromJson(json.decode(noteStr)))
        .toList();
  }

  Future<void> _saveNotes() async {
    final notesJson = state.map((note) => json.encode(note.toJson())).toList();
    await _prefs.setStringList('notes', notesJson);
  }

  Future<void> addNote(String content) async {
    final newNote = Note(
      id: DateTime.now().toString(),
      content: content,
      timestamp: DateTime.now(),
    );
    state = [...state, newNote];
    await _saveNotes();
  }

  Future<void> deleteNote(String id) async {
    state = state.where((note) => note.id != id).toList();
    await _saveNotes();
  }

  Future<void> clearAllNotes() async {
    state = [];
    await _saveNotes();
  }
}

final notesViewModelProvider =
    StateNotifierProvider<NotesViewModel, List<Note>>((ref) {
      return NotesViewModel(ref.watch(sharedPreferencesProvider));
    });
