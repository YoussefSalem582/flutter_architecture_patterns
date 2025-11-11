import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// IncrementCounterUseCase - Application Service
///
/// Increments the counter value using domain logic.
/// Coordinates between repository retrieval and saving.
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  Future<Either<Failure, CounterEntity>> call() async {
    // Get current counter
    final currentResult = await repository.getCounter();

    return await currentResult.fold((failure) async => Left(failure), (
      counter,
    ) async {
      // Apply domain logic: increment
      final incrementedCounter = counter.increment();

      // Save updated counter
      final saveResult = await repository.saveCounter(incrementedCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(incrementedCounter),
      );
    });
  }
}
