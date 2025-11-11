import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/note_entity.dart';

/// Notes Repository Interface
///
/// Defines the contract for notes data operations.
/// Returns Either<Failure, Success> for explicit error handling.
///
/// Infrastructure layer provides the implementation.
abstract class NotesRepository {
  /// Get all notes
  Future<Either<Failure, List<NoteEntity>>> getAllNotes();

  /// Save a single note
  Future<Either<Failure, Unit>> saveNote(NoteEntity note);

  /// Delete a note by ID
  Future<Either<Failure, Unit>> deleteNote(String noteId);

  /// Delete all notes
  Future<Either<Failure, Unit>> deleteAllNotes();
}
