import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/reset_counter.dart';
import 'counter_state.dart';

/// Counter Cubit - Presentation layer
/// Manages counter state using BLoC pattern
class CounterCubit extends Cubit<CounterState> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;
  final ResetCounter resetCounter;

  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
    required this.resetCounter,
  }) : super(CounterInitial()) {
    loadCounter();
  }

  /// Load counter from repository
  Future<void> loadCounter() async {
    emit(CounterLoading());
    final result = await getCounter(const NoParams());
    result.fold(
      (failure) {
        Logger.error(
          'Failed to load counter: ${failure.message}',
          tag: 'CUBIT',
        );
        emit(CounterError(failure.message));
      },
      (counter) {
        Logger.info('Counter loaded: ${counter.value}', tag: 'CUBIT');
        emit(CounterLoaded(counter));
      },
    );
  }

  /// Increment counter
  Future<void> increment() async {
    final result = await incrementCounter(const NoParams());
    result.fold(
      (failure) {
        Logger.error('Failed to increment: ${failure.message}', tag: 'CUBIT');
        emit(CounterError(failure.message));
      },
      (counter) {
        Logger.info('Counter incremented: ${counter.value}', tag: 'CUBIT');
        emit(CounterLoaded(counter));
      },
    );
  }

  /// Decrement counter
  Future<void> decrement() async {
    final result = await decrementCounter(const NoParams());
    result.fold(
      (failure) {
        Logger.error('Failed to decrement: ${failure.message}', tag: 'CUBIT');
        emit(CounterError(failure.message));
      },
      (counter) {
        Logger.info('Counter decremented: ${counter.value}', tag: 'CUBIT');
        emit(CounterLoaded(counter));
      },
    );
  }

  /// Reset counter
  Future<void> reset() async {
    final result = await resetCounter(const NoParams());
    result.fold(
      (failure) {
        Logger.error('Failed to reset: ${failure.message}', tag: 'CUBIT');
        emit(CounterError(failure.message));
      },
      (counter) {
        Logger.info('Counter reset: ${counter.value}', tag: 'CUBIT');
        emit(CounterLoaded(counter));
      },
    );
  }
}
