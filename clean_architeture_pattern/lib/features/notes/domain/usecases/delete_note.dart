import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

/// Delete Note Use Case
class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}

/// Parameters for DeleteNote use case
class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object> get props => [id];
}
