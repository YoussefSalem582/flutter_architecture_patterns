import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// GetAllNotesUseCase - Application Service
///
/// Retrieves all notes from the repository.
/// Returns Either<Failure, List<NoteEntity>> for error handling.
class GetAllNotesUseCase {
  final NotesRepository repository;

  GetAllNotesUseCase(this.repository);

  Future<Either<Failure, List<NoteEntity>>> call() async {
    return await repository.getAllNotes();
  }
}
