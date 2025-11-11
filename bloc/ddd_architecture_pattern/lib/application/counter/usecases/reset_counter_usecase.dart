import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// ResetCounterUseCase - Application Service
///
/// Resets the counter to zero using domain logic.
/// Coordinates between repository retrieval and saving.
class ResetCounterUseCase {
  final CounterRepository repository;

  ResetCounterUseCase(this.repository);

  Future<Either<Failure, CounterEntity>> call() async {
    // Get current counter
    final currentResult = await repository.getCounter();

    return await currentResult.fold((failure) async => Left(failure), (
      counter,
    ) async {
      // Apply domain logic: reset to zero
      final resetCounter = counter.reset();

      // Save updated counter
      final saveResult = await repository.saveCounter(resetCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(resetCounter),
      );
    });
  }
}
