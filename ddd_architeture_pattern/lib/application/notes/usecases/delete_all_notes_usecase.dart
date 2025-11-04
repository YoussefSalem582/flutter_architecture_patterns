import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// Delete All Notes Use Case - Application Service
///
/// In DDD, even simple operations are wrapped in use cases
/// to keep business logic centralized and testable.
class DeleteAllNotesUseCase {
  final NotesRepository repository;

  DeleteAllNotesUseCase(this.repository);

  /// Execute: Delete all notes
  Future<Either<Failure, Unit>> execute() async {
    return await repository.deleteAllNotes();
  }
}
