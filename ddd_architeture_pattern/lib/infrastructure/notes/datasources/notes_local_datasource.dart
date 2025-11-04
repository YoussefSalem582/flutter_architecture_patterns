import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import '../dtos/note_dto.dart';

/// Notes Local Data Source - Infrastructure Layer
///
/// In DDD, data sources:
/// - Handle persistence operations
/// - Work with DTOs (data transfer objects)
/// - Throw exceptions for errors
/// - Use infrastructure-specific tools (GetStorage)
class NotesLocalDataSource {
  final GetStorage storage;
  static const String _notesKey = 'notes';

  NotesLocalDataSource(this.storage);

  /// Get all notes
  Future<List<NoteDto>> getAllNotes() async {
    try {
      final data = storage.read<String>(_notesKey);
      if (data == null || data.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((json) => NoteDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Failed to read notes: $e');
    }
  }

  /// Add note
  Future<void> addNote(NoteDto note) async {
    try {
      final notes = await getAllNotes();
      notes.add(note);
      await _saveNotes(notes);
    } catch (e) {
      throw StorageException('Failed to add note: $e');
    }
  }

  /// Delete note by ID
  Future<void> deleteNote(String id) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      await _saveNotes(notes);
    } catch (e) {
      throw StorageException('Failed to delete note: $e');
    }
  }

  /// Delete all notes
  Future<void> deleteAllNotes() async {
    try {
      await storage.remove(_notesKey);
    } catch (e) {
      throw StorageException('Failed to delete all notes: $e');
    }
  }

  /// Get note by ID
  Future<NoteDto?> getNoteById(String id) async {
    try {
      final notes = await getAllNotes();
      return notes.firstWhere(
        (note) => note.id == id,
        orElse: () => throw NotFoundException('Note not found'),
      );
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw StorageException('Failed to get note: $e');
    }
  }

  /// Save notes to storage
  Future<void> _saveNotes(List<NoteDto> notes) async {
    final jsonString = jsonEncode(notes.map((n) => n.toJson()).toList());
    await storage.write(_notesKey, jsonString);
  }
}

/// Storage exception
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

/// Not found exception
class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}
