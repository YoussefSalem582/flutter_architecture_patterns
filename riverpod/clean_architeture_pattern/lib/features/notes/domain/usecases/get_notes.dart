import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetNotes implements UseCase<List<Note>, NoParams> {
  final NotesRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) async {
    return await repository.getNotes();
  }
}
