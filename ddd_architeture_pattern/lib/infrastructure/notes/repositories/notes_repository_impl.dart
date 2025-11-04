import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../dtos/note_dto.dart';

/// Notes Repository Implementation - Infrastructure Layer
///
/// In DDD, repository implementations:
/// - Implement domain repository interfaces
/// - Bridge between domain and infrastructure
/// - Convert DTOs to/from domain entities
/// - Handle error translation (exceptions → Either)
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource dataSource;

  NotesRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<NoteEntity>>> getAllNotes() async {
    try {
      final dtos = await dataSource.getAllNotes();

      // Convert DTOs to domain entities
      final entities = dtos.map((dto) => dto.toEntity()).toList();

      return Right(entities);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addNote(NoteEntity note) async {
    try {
      // Convert domain entity to DTO
      final dto = NoteDto.fromEntity(note);

      await dataSource.addNote(dto);

      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNote(String id) async {
    try {
      await dataSource.deleteNote(id);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllNotes() async {
    try {
      await dataSource.deleteAllNotes();
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> getNoteById(String id) async {
    try {
      final dto = await dataSource.getNoteById(id);

      if (dto == null) {
        return const Left(NotFoundFailure('Note not found'));
      }

      return Right(dto.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }
}
