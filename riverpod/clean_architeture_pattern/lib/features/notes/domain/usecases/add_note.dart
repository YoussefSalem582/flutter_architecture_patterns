import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class AddNoteParams {
  final Note note;
  AddNoteParams(this.note);
}

class AddNote implements UseCase<void, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, void>> call(AddNoteParams params) async {
    return await repository.addNote(params.note);
  }
}
