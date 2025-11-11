import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// Get All Notes Use Case - Application Service
///
/// In DDD, this use case:
/// - Retrieves all notes from repository
/// - Returns domain entities (not DTOs or models)
/// - Keeps UI layer independent of persistence details
class GetAllNotesUseCase {
  final NotesRepository repository;

  GetAllNotesUseCase(this.repository);

  /// Execute: Retrieve all notes
  Future<Either<Failure, List<NoteEntity>>> execute() async {
    return await repository.getAllNotes();
  }
}
