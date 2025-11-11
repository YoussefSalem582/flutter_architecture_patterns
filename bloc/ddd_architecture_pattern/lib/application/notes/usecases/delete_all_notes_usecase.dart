import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// DeleteAllNotesUseCase - Application Service
///
/// Deletes all notes from the repository.
/// Returns Either<Failure, Unit> for error handling.
class DeleteAllNotesUseCase {
  final NotesRepository repository;

  DeleteAllNotesUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.deleteAllNotes();
  }
}
