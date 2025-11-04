import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';

/// Get Counter Use Case - Application Service
///
/// In DDD, use cases (application services) orchestrate domain logic.
/// They:
/// - Coordinate between domain entities and repositories
/// - Handle application-specific workflows
/// - Remain independent of UI frameworks
class GetCounterUseCase {
  final CounterRepository repository;

  GetCounterUseCase(this.repository);

  /// Execute: Get current counter or create new one
  Future<Either<Failure, CounterEntity>> execute() async {
    final exists = await repository.exists();

    if (!exists) {
      // Create default counter if doesn't exist
      final newCounter = CounterEntity.create('default');
      await repository.saveCounter(newCounter);
      return Right(newCounter);
    }

    return await repository.getCounter();
  }
}
