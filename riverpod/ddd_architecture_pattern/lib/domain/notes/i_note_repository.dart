import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import 'note.dart';

abstract class INoteRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Unit>> addNote(Note note);
  Future<Either<Failure, Unit>> deleteNote(String id);
  Future<Either<Failure, Unit>> clearNotes();
}
