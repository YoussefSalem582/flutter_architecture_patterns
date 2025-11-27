import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/core/failures.dart';
import '../../domain/notes/note.dart';
import '../../domain/notes/i_note_repository.dart';
import 'note_dtos.dart';

class NoteRepository implements INoteRepository {
  final SharedPreferences _sharedPreferences;
  static const String _notesKey = 'notes_key';

  NoteRepository(this._sharedPreferences);

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final jsonString = _sharedPreferences.getString(_notesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final notes = jsonList
            .map((e) => NoteDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList();
        return Right(notes);
      } else {
        return const Right([]);
      }
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addNote(Note note) async {
    try {
      final notesOrFailure = await getNotes();
      return notesOrFailure.fold((failure) => Left(failure), (notes) async {
        final newNotes = List<Note>.from(notes)..add(note);
        final noteDtos = newNotes
            .map((e) => NoteDto.fromDomain(e).toJson())
            .toList();
        await _sharedPreferences.setString(_notesKey, json.encode(noteDtos));
        return const Right(unit);
      });
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNote(String id) async {
    try {
      final notesOrFailure = await getNotes();
      return notesOrFailure.fold((failure) => Left(failure), (notes) async {
        final newNotes = notes.where((n) => n.id != id).toList();
        final noteDtos = newNotes
            .map((e) => NoteDto.fromDomain(e).toJson())
            .toList();
        await _sharedPreferences.setString(_notesKey, json.encode(noteDtos));
        return const Right(unit);
      });
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> clearNotes() async {
    try {
      await _sharedPreferences.remove(_notesKey);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}
