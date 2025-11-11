import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

/// Notes Repository Implementation - Data layer
/// Implements the NotesRepository interface from domain layer
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      final notes = await localDataSource.getAllNotes();
      Logger.info('Retrieved ${notes.length} notes', tag: 'REPOSITORY');
      return Right(notes.map((model) => model.toEntity()).toList());
    } catch (e) {
      Logger.error('Error getting notes', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to get notes'));
    }
  }

  @override
  Future<Either<Failure, void>> addNote(Note note) async {
    try {
      final currentNotes = await localDataSource.getAllNotes();
      final newNote = NoteModel.fromEntity(note);
      currentNotes.add(newNote);
      await localDataSource.saveNotes(currentNotes);
      Logger.info('Note added: ${note.content}', tag: 'REPOSITORY');
      return const Right(null);
    } catch (e) {
      Logger.error('Error adding note', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to add note'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      final currentNotes = await localDataSource.getAllNotes();
      currentNotes.removeWhere((note) => note.id == id);
      await localDataSource.saveNotes(currentNotes);
      Logger.info('Note deleted: $id', tag: 'REPOSITORY');
      return const Right(null);
    } catch (e) {
      Logger.error('Error deleting note', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to delete note'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotes() async {
    try {
      await localDataSource.saveNotes([]);
      Logger.info('All notes deleted', tag: 'REPOSITORY');
      return const Right(null);
    } catch (e) {
      Logger.error('Error deleting all notes', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to delete all notes'));
    }
  }
}
