import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> cacheNotes(List<NoteModel> notesToCache);
}

const CACHED_NOTES = 'CACHED_NOTES';

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final SharedPreferences sharedPreferences;

  NotesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NoteModel>> getNotes() {
    final jsonString = sharedPreferences.getString(CACHED_NOTES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(
        jsonList.map((json) => NoteModel.fromJson(json)).toList(),
      );
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notesToCache) {
    final jsonList = notesToCache.map((note) => note.toJson()).toList();
    return sharedPreferences.setString(CACHED_NOTES, json.encode(jsonList));
  }
}
