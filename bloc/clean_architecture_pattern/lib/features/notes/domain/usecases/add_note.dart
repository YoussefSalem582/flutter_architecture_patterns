import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Add Note Parameters
class AddNoteParams {
  final Note note;

  const AddNoteParams(this.note);
}

/// Add Note Use Case
/// Adds a new note to the repository
class AddNote implements UseCase<void, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, void>> call(AddNoteParams params) async {
    if (params.note.content.trim().isEmpty) {
      return const Left(ValidationFailure('Note content cannot be empty'));
    }
    return await repository.addNote(params.note);
  }
}
