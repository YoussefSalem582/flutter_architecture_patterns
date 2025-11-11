import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

/// Notes Repository Implementation - Data layer
/// Implements the domain repository interface
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      final notes = await localDataSource.getAllNotes();
      return Right(notes.map((model) => model.toEntity()).toList());
    } catch (e) {
      Logger.error('Repository: Failed to get notes', error: e);
      return Left(StorageFailure('Failed to get notes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Note>> addNote(String content) async {
    try {
      final note = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      await localDataSource.addNote(note);
      return Right(note.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to add note', error: e);
      return Left(StorageFailure('Failed to add note: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      await localDataSource.deleteNote(id);
      return const Right(null);
    } catch (e) {
      Logger.error('Repository: Failed to delete note', error: e);
      return Left(StorageFailure('Failed to delete note: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotes() async {
    try {
      await localDataSource.saveAllNotes([]);
      return const Right(null);
    } catch (e) {
      Logger.error('Repository: Failed to delete all notes', error: e);
      return Left(
        StorageFailure('Failed to delete all notes: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(String id, String content) async {
    try {
      final notes = await localDataSource.getAllNotes();
      final index = notes.indexWhere((note) => note.id == id);

      if (index == -1) {
        return const Left(StorageFailure('Note not found'));
      }

      final updatedNote = NoteModel(
        id: notes[index].id,
        content: content.trim(),
        createdAt: notes[index].createdAt,
      );

      notes[index] = updatedNote;
      await localDataSource.saveAllNotes(notes);

      return Right(updatedNote.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to update note', error: e);
      return Left(StorageFailure('Failed to update note: ${e.toString()}'));
    }
  }
}
