import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// Reset Counter Use Case - Application Service
///
/// Orchestrates: get → reset (domain operation) → save
class ResetCounterUseCase {
  final CounterRepository repository;

  ResetCounterUseCase(this.repository);

  /// Execute: Reset counter to zero
  Future<Either<Failure, CounterEntity>> execute() async {
    final currentResult = await repository.getCounter();

    return currentResult.fold((failure) => Left(failure), (counter) async {
      // Domain entity knows how to reset itself
      final resetCounter = counter.reset();

      final saveResult = await repository.saveCounter(resetCounter);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(resetCounter),
      );
    });
  }
}
