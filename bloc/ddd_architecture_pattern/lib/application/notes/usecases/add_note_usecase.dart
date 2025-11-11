import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';

/// AddNoteUseCase - Application Service
///
/// Creates and saves a new note.
/// Generates UUID for the note ID.
/// Validates content through value object.
class AddNoteUseCase {
  final NotesRepository repository;
  final Uuid uuid;

  AddNoteUseCase(this.repository, this.uuid);

  Future<Either<Failure, Unit>> call(String content) async {
    try {
      // Generate unique ID
      final id = uuid.v4();

      // Create note entity (validates through value objects)
      final note = NoteEntity.create(id: id, content: content);

      // Save note
      return await repository.saveNote(note);
    } on ArgumentError catch (e) {
      // Validation failed (from value objects)
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
