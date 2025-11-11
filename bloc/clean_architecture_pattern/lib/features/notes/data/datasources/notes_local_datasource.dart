import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/utils/logger.dart';
import '../models/note_model.dart';

/// Notes Local Data Source
/// Handles local storage operations for notes data
abstract class NotesLocalDataSource {
  /// Get all notes from local storage
  Future<List<NoteModel>> getAllNotes();

  /// Save notes to local storage
  Future<void> saveNotes(List<NoteModel> notes);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final SharedPreferences sharedPreferences;

  NotesLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final notesJson = sharedPreferences.getString(StorageKeys.notesList);
      if (notesJson == null || notesJson.isEmpty) {
        Logger.info('No notes found in storage', tag: 'DATA_SOURCE');
        return _getDefaultNotes();
      }

      final List<dynamic> decoded = json.decode(notesJson);
      final notes = decoded
          .map(
            (noteJson) => NoteModel.fromJson(noteJson as Map<String, dynamic>),
          )
          .toList();

      Logger.info(
        'Retrieved ${notes.length} notes from storage',
        tag: 'DATA_SOURCE',
      );
      return notes;
    } catch (e) {
      Logger.error(
        'Error getting notes from storage',
        tag: 'DATA_SOURCE',
        error: e,
      );
      return _getDefaultNotes();
    }
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    try {
      final notesJson = json.encode(
        notes.map((note) => note.toJson()).toList(),
      );
      await sharedPreferences.setString(StorageKeys.notesList, notesJson);
      Logger.info('Saved ${notes.length} notes to storage', tag: 'DATA_SOURCE');
    } catch (e) {
      Logger.error(
        'Error saving notes to storage',
        tag: 'DATA_SOURCE',
        error: e,
      );
      rethrow;
    }
  }

  /// Get default sample notes
  List<NoteModel> _getDefaultNotes() {
    return [
      NoteModel(
        id: '1',
        content: 'Welcome to Counter Notes App!',
        createdAt: DateTime.now(),
      ),
      NoteModel(
        id: '2',
        content: 'This app demonstrates Clean Architecture with BLoC',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
