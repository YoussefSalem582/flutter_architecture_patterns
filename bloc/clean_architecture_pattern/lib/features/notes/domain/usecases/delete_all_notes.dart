import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

/// Delete All Notes Use Case
/// Deletes all notes from the repository
class DeleteAllNotes implements UseCase<void, NoParams> {
  final NotesRepository repository;

  DeleteAllNotes(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllNotes();
  }
}
