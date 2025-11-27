import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

class DeleteNoteParams {
  final String id;
  DeleteNoteParams(this.id);
}

class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}
