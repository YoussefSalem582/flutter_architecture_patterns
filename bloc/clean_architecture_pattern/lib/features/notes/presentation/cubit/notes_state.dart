import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

/// Notes State
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

/// Initial state
class NotesInitial extends NotesState {}

/// Loading state
class NotesLoading extends NotesState {}

/// Loaded state with notes data
class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

/// Error state
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object> get props => [message];
}
