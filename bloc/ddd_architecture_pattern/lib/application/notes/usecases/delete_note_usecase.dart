import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// DeleteNoteUseCase - Application Service
///
/// Deletes a specific note by ID.
/// Returns Either<Failure, Unit> for error handling.
class DeleteNoteUseCase {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String noteId) async {
    if (noteId.isEmpty) {
      return const Left(ValidationFailure('Note ID cannot be empty'));
    }

    return await repository.deleteNote(noteId);
  }
}
