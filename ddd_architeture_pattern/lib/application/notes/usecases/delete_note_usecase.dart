import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// Delete Note Use Case - Application Service
///
/// In DDD, this use case:
/// - Coordinates note deletion
/// - Delegates to repository for persistence
class DeleteNoteUseCase {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  /// Execute: Delete note by ID
  Future<Either<Failure, Unit>> execute(String noteId) async {
    if (noteId.isEmpty) {
      return const Left(ValidationFailure('Note ID cannot be empty'));
    }

    return await repository.deleteNote(noteId);
  }
}
