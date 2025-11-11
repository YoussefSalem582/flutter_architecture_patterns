import 'package:equatable/equatable.dart';
import '../../domain/entities/counter.dart';

/// Counter State
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object> get props => [];
}

/// Initial state
class CounterInitial extends CounterState {}

/// Loading state
class CounterLoading extends CounterState {}

/// Loaded state with counter data
class CounterLoaded extends CounterState {
  final Counter counter;

  const CounterLoaded(this.counter);

  @override
  List<Object> get props => [counter];
}

/// Error state
class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  List<Object> get props => [message];
}
