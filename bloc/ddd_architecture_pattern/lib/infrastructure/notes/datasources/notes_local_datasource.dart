import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dtos/note_dto.dart';

/// Notes Local Data Source Interface
///
/// Defines storage operations for notes data.
abstract class NotesLocalDataSource {
  /// Get all stored note DTOs
  Future<List<NoteDTO>> getAllNotes();

  /// Save all note DTOs (replaces existing)
  Future<void> saveAllNotes(List<NoteDTO> notes);
}

/// Notes Local Data Source Implementation
///
/// Uses SharedPreferences for persistence.
/// Stores notes as a JSON array.
class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  static const String _keyNotes = 'notes_ddd';
  final SharedPreferences sharedPreferences;

  NotesLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<NoteDTO>> getAllNotes() async {
    try {
      final jsonString = sharedPreferences.getString(_keyNotes);

      if (jsonString == null) {
        return _getDefaultNotes();
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => NoteDTO.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notes from storage: $e');
    }
  }

  @override
  Future<void> saveAllNotes(List<NoteDTO> notes) async {
    try {
      final jsonList = notes.map((note) => note.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await sharedPreferences.setString(_keyNotes, jsonString);
    } catch (e) {
      throw Exception('Failed to save notes to storage: $e');
    }
  }

  /// Returns default sample notes for first-time users
  List<NoteDTO> _getDefaultNotes() {
    return [
      NoteDTO(
        id: 'default-1',
        content: 'Welcome to DDD Architecture with BLoC!',
        createdAt: DateTime.now().toIso8601String(),
      ),
      NoteDTO(
        id: 'default-2',
        content:
            'This app demonstrates Domain-Driven Design with value objects, entities, and aggregates.',
        createdAt: DateTime.now()
            .add(const Duration(seconds: 1))
            .toIso8601String(),
      ),
    ];
  }
}
