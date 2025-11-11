import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// Add Note Use Case - Application Service
///
/// In DDD, this use case:
/// - Creates a new domain entity with proper validation
/// - Generates unique ID (infrastructure concern)
/// - Delegates persistence to repository
class AddNoteUseCase {
  final NotesRepository repository;
  final Uuid _uuid = const Uuid();

  AddNoteUseCase(this.repository);

  /// Execute: Create and add a new note
  Future<Either<Failure, NoteEntity>> execute(String content) async {
    try {
      // Create domain entity (validation happens in value objects)
      final note = NoteEntity.create(id: _uuid.v4(), content: content);

      // Check if note is valid
      if (!note.isValid) {
        return const Left(ValidationFailure('Invalid note content'));
      }

      // Persist through repository
      final result = await repository.addNote(note);

      return result.fold((failure) => Left(failure), (_) => Right(note));
    } on ArgumentError catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add note: $e'));
    }
  }
}
