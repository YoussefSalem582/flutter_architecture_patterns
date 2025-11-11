import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// Decrement Counter Use Case - Application Service
///
/// Orchestrates: get → decrement (with domain rules) → save
class DecrementCounterUseCase {
  final CounterRepository repository;

  DecrementCounterUseCase(this.repository);

  /// Execute: Decrement counter value
  Future<Either<Failure, CounterEntity>> execute() async {
    final currentResult = await repository.getCounter();

    return currentResult.fold((failure) => Left(failure), (counter) async {
      // Domain entity applies business rule (cannot go below zero)
      final updatedCounter = counter.decrement();

      final saveResult = await repository.saveCounter(updatedCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(updatedCounter),
      );
    });
  }
}
