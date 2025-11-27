import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

class SaveCounterParams {
  final Counter counter;
  SaveCounterParams(this.counter);
}

class SaveCounter implements UseCase<void, SaveCounterParams> {
  final CounterRepository repository;

  SaveCounter(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveCounterParams params) async {
    return await repository.saveCounter(params.counter);
  }
}
