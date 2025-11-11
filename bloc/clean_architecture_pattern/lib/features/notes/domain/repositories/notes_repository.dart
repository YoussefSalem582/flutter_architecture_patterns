import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

/// Notes Repository - Domain layer interface
/// Defines the contract for notes data operations
abstract class NotesRepository {
  /// Get all notes
  Future<Either<Failure, List<Note>>> getAllNotes();

  /// Add a new note
  Future<Either<Failure, void>> addNote(Note note);

  /// Delete a note by ID
  Future<Either<Failure, void>> deleteNote(String id);

  /// Delete all notes
  Future<Either<Failure, void>> deleteAllNotes();
}
