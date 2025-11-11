import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../dtos/note_dto.dart';

/// Notes Repository Implementation
///
/// Implements the domain repository interface.
/// Coordinates with data sources and handles domain/DTO conversion.
/// Returns Either<Failure, Success> for error handling.
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<NoteEntity>>> getAllNotes() async {
    try {
      final dtos = await localDataSource.getAllNotes();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to get notes: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveNote(NoteEntity note) async {
    try {
      // Get existing notes
      final currentDtos = await localDataSource.getAllNotes();

      // Convert new note to DTO
      final newDto = NoteDTO.fromEntity(note);

      // Add or update note
      final existingIndex = currentDtos.indexWhere(
        (dto) => dto.id == newDto.id,
      );
      if (existingIndex != -1) {
        currentDtos[existingIndex] = newDto;
      } else {
        currentDtos.add(newDto);
      }

      // Save all notes
      await localDataSource.saveAllNotes(currentDtos);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to save note: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNote(String noteId) async {
    try {
      // Get existing notes
      final currentDtos = await localDataSource.getAllNotes();

      // Remove note with matching ID
      currentDtos.removeWhere((dto) => dto.id == noteId);

      // Save updated notes
      await localDataSource.saveAllNotes(currentDtos);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to delete note: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllNotes() async {
    try {
      await localDataSource.saveAllNotes([]);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to delete all notes: $e'));
    }
  }
}
