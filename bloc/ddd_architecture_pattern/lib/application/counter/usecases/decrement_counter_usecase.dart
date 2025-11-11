import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// DecrementCounterUseCase - Application Service
///
/// Decrements the counter value using domain logic.
/// Coordinates between repository retrieval and saving.
class DecrementCounterUseCase {
  final CounterRepository repository;

  DecrementCounterUseCase(this.repository);

  Future<Either<Failure, CounterEntity>> call() async {
    // Get current counter
    final currentResult = await repository.getCounter();

    return await currentResult.fold((failure) async => Left(failure), (
      counter,
    ) async {
      // Apply domain logic: decrement (won't go below zero)
      final decrementedCounter = counter.decrement();

      // Save updated counter
      final saveResult = await repository.saveCounter(decrementedCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(decrementedCounter),
      );
    });
  }
}
