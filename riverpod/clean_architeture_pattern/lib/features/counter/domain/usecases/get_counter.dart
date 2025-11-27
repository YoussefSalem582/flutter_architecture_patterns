import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

class GetCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;

  GetCounter(this.repository);

  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    return await repository.getCounter();
  }
}
