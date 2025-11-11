import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// Increment Counter Use Case - Application Service
///
/// In DDD, this use case encapsulates the business process:
/// 1. Get current counter
/// 2. Apply domain logic (increment)
/// 3. Persist the result
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  /// Execute: Increment counter value
  Future<Either<Failure, CounterEntity>> execute() async {
    // Get current counter
    final currentResult = await repository.getCounter();

    return currentResult.fold((failure) => Left(failure), (counter) async {
      // Apply domain logic - entity knows how to increment itself
      final updatedCounter = counter.increment();

      // Persist the change
      final saveResult = await repository.saveCounter(updatedCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(updatedCounter),
      );
    });
  }
}
