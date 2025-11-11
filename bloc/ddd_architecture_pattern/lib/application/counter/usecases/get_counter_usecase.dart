import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// GetCounterUseCase - Application Service
///
/// Retrieves the current counter from the repository.
/// Returns Either<Failure, CounterEntity> for error handling.
class GetCounterUseCase {
  final CounterRepository repository;

  GetCounterUseCase(this.repository);

  Future<Either<Failure, CounterEntity>> call() async {
    return await repository.getCounter();
  }
}
