import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/utils/logger.dart';
import '../models/note_model.dart';

/// Notes Local Data Source
/// Handles local storage operations for notes
abstract class NotesLocalDataSource {
  /// Get all notes from storage
  Future<List<NoteModel>> getAllNotes();

  /// Save all notes to storage
  Future<void> saveAllNotes(List<NoteModel> notes);

  /// Add a note to storage
  Future<void> addNote(NoteModel note);

  /// Delete a note from storage
  Future<void> deleteNote(String id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final GetStorage storage;

  NotesLocalDataSourceImpl(this.storage);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final jsonString = storage.read<String>(StorageKeys.notesList);
      if (jsonString == null || jsonString.isEmpty) {
        Logger.info('No notes found in storage', tag: 'NotesDataSource');
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final notes = jsonList
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();

      Logger.info('Retrieved ${notes.length} notes', tag: 'NotesDataSource');
      return notes;
    } catch (e) {
      Logger.error('Failed to get notes', tag: 'NotesDataSource', error: e);
      return [];
    }
  }

  @override
  Future<void> saveAllNotes(List<NoteModel> notes) async {
    try {
      final jsonList = notes.map((note) => note.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await storage.write(StorageKeys.notesList, jsonString);
      Logger.info('Saved ${notes.length} notes', tag: 'NotesDataSource');
    } catch (e) {
      Logger.error('Failed to save notes', tag: 'NotesDataSource', error: e);
      rethrow;
    }
  }

  @override
  Future<void> addNote(NoteModel note) async {
    try {
      final notes = await getAllNotes();
      notes.add(note);
      await saveAllNotes(notes);
      Logger.info('Added note: ${note.id}', tag: 'NotesDataSource');
    } catch (e) {
      Logger.error('Failed to add note', tag: 'NotesDataSource', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      await saveAllNotes(notes);
      Logger.info('Deleted note: $id', tag: 'NotesDataSource');
    } catch (e) {
      Logger.error('Failed to delete note', tag: 'NotesDataSource', error: e);
      rethrow;
    }
  }
}
