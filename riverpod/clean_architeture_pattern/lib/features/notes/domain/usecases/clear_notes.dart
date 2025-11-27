import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

class ClearNotes implements UseCase<void, NoParams> {
  final NotesRepository repository;

  ClearNotes(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearNotes();
  }
}
