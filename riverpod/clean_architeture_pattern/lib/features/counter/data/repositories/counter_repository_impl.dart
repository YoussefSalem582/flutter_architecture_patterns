import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_data_source.dart';
import '../models/counter_model.dart';

class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final localCounter = await localDataSource.getLastCounter();
      return Right(localCounter);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveCounter(Counter counter) async {
    try {
      await localDataSource.cacheCounter(CounterModel(value: counter.value));
      return const Right(null);
    } on Exception {
      return Left(CacheFailure());
    }
  }
}
