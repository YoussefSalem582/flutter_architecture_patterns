import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/counter_entity.dart';

/// Counter Repository Interface
///
/// Defines the contract for counter data operations.
/// Returns Either<Failure, Success> for explicit error handling.
///
/// Infrastructure layer provides the implementation.
abstract class CounterRepository {
  /// Get the current counter entity
  Future<Either<Failure, CounterEntity>> getCounter();

  /// Save the counter entity
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter);
}
