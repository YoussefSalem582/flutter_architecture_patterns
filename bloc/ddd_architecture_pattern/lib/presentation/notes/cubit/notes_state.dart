import 'package:equatable/equatable.dart';

import '../../../domain/notes/entities/note_entity.dart';

/// Notes State - Presentation Layer States
///
/// Represents all possible UI states for the notes feature.
/// Sealed with Equatable for value comparison and immutability.
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any data is loaded
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// Loading state - while fetching or updating data
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// Loaded state - notes successfully retrieved
class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Error state - operation failed
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
