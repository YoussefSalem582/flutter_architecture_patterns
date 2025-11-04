import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/note_entity.dart';

/// Notes Repository Interface - Domain Contract
///
/// In DDD, repositories abstract persistence concerns.
/// The domain defines WHAT operations are needed.
/// Infrastructure defines HOW they are implemented.
abstract class NotesRepository {
  /// Get all notes
  Future<Either<Failure, List<NoteEntity>>> getAllNotes();

  /// Add a new note
  Future<Either<Failure, Unit>> addNote(NoteEntity note);

  /// Delete a note by ID
  Future<Either<Failure, Unit>> deleteNote(String id);

  /// Delete all notes
  Future<Either<Failure, Unit>> deleteAllNotes();

  /// Get note by ID
  Future<Either<Failure, NoteEntity>> getNoteById(String id);
}
