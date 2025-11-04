import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Add Note Use Case
class AddNote implements UseCase<Note, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(AddNoteParams params) async {
    if (params.content.trim().isEmpty) {
      return const Left(ValidationFailure('Note content cannot be empty'));
    }
    return await repository.addNote(params.content);
  }
}

/// Parameters for AddNote use case
class AddNoteParams extends Equatable {
  final String content;

  const AddNoteParams({required this.content});

  @override
  List<Object> get props => [content];
}
