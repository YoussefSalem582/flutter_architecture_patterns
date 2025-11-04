import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/counter_entity.dart';

/// Counter Repository Interface - Domain Contract
///
/// In DDD, repositories are defined in the domain layer as interfaces.
/// They provide abstraction for data access without implementation details.
///
/// Infrastructure layer will implement this interface.
abstract class CounterRepository {
  /// Get the current counter
  Future<Either<Failure, CounterEntity>> getCounter();

  /// Save the counter state
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter);

  /// Check if counter exists
  Future<bool> exists();
}
