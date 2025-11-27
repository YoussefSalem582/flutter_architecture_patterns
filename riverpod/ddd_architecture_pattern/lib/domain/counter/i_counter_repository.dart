import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import 'counter.dart';

abstract class ICounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Unit>> saveCounter(Counter counter);
}
