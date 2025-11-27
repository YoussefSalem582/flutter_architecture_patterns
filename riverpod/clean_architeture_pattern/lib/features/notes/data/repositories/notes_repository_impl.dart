import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();
      return Right(localNotes);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addNote(Note note) async {
    try {
      final currentNotes = await localDataSource.getNotes();
      final newNotes = List<NoteModel>.from(currentNotes);
      newNotes.add(NoteModel.fromEntity(note));
      await localDataSource.cacheNotes(newNotes);
      return const Right(null);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      final currentNotes = await localDataSource.getNotes();
      final newNotes = currentNotes.where((note) => note.id != id).toList();
      await localDataSource.cacheNotes(newNotes);
      return const Right(null);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearNotes() async {
    try {
      await localDataSource.cacheNotes([]);
      return const Right(null);
    } on Exception {
      return Left(CacheFailure());
    }
  }
}
