import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

/// Delete Note Parameters
class DeleteNoteParams {
  final String id;

  const DeleteNoteParams(this.id);
}

/// Delete Note Use Case
/// Deletes a note by ID from the repository
class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}
