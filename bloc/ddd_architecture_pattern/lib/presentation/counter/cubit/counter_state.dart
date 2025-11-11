import 'package:equatable/equatable.dart';

import '../../../domain/counter/entities/counter_entity.dart';

/// Counter State - Presentation Layer States
///
/// Represents all possible UI states for the counter feature.
/// Sealed with Equatable for value comparison and immutability.
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any data is loaded
class CounterInitial extends CounterState {
  const CounterInitial();
}

/// Loading state - while fetching or updating data
class CounterLoading extends CounterState {
  const CounterLoading();
}

/// Loaded state - counter data successfully retrieved
class CounterLoaded extends CounterState {
  final CounterEntity counter;

  const CounterLoaded(this.counter);

  @override
  List<Object?> get props => [counter];
}

/// Error state - operation failed
class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  List<Object?> get props => [message];
}
