import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// Reset Counter Use Case
/// Resets the counter value to zero
class ResetCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;

  ResetCounter(this.repository);

  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    return await repository.resetCounter();
  }
}
