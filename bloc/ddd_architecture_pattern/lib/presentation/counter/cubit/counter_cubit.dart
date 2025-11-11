import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/counter/usecases/decrement_counter_usecase.dart';
import '../../../application/counter/usecases/get_counter_usecase.dart';
import '../../../application/counter/usecases/increment_counter_usecase.dart';
import '../../../application/counter/usecases/reset_counter_usecase.dart';
import 'counter_state.dart';

/// Counter Cubit - Presentation Layer State Management
///
/// Manages counter state using BLoC pattern with Cubit.
/// Coordinates with use cases from the application layer.
/// Emits different states based on operation results.
class CounterCubit extends Cubit<CounterState> {
  final GetCounterUseCase getCounterUseCase;
  final IncrementCounterUseCase incrementCounterUseCase;
  final DecrementCounterUseCase decrementCounterUseCase;
  final ResetCounterUseCase resetCounterUseCase;

  CounterCubit({
    required this.getCounterUseCase,
    required this.incrementCounterUseCase,
    required this.decrementCounterUseCase,
    required this.resetCounterUseCase,
  }) : super(const CounterInitial()) {
    // Load counter on initialization
    loadCounter();
  }

  /// Load the current counter
  Future<void> loadCounter() async {
    emit(const CounterLoading());

    final result = await getCounterUseCase();

    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  /// Increment the counter
  Future<void> increment() async {
    emit(const CounterLoading());

    final result = await incrementCounterUseCase();

    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  /// Decrement the counter
  Future<void> decrement() async {
    emit(const CounterLoading());

    final result = await decrementCounterUseCase();

    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  /// Reset the counter to zero
  Future<void> reset() async {
    emit(const CounterLoading());

    final result = await resetCounterUseCase();

    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }
}
