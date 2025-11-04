import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Get All Notes Use Case
class GetAllNotes implements UseCase<List<Note>, NoParams> {
  final NotesRepository repository;

  GetAllNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) async {
    return await repository.getAllNotes();
  }
}
