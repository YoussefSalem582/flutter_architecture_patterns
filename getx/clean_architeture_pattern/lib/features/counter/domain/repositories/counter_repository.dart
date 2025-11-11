import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/counter.dart';

/// Counter Repository - Domain layer interface
/// Defines the contract for counter data operations
abstract class CounterRepository {
  /// Get the current counter value
  Future<Either<Failure, Counter>> getCounter();

  /// Save counter value
  Future<Either<Failure, void>> saveCounter(Counter counter);

  /// Increment counter
  Future<Either<Failure, Counter>> incrementCounter();

  /// Decrement counter
  Future<Either<Failure, Counter>> decrementCounter();

  /// Reset counter to zero
  Future<Either<Failure, Counter>> resetCounter();
}
