import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../models/counter_model.dart';

/// Counter Repository Implementation - Data layer
/// Implements the domain repository interface
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final counter = await localDataSource.getCounter();
      return Right(counter.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to get counter', error: e);
      return Left(StorageFailure('Failed to get counter: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCounter(Counter counter) async {
    try {
      final model = CounterModel.fromEntity(counter);
      await localDataSource.saveCounter(model);
      return const Right(null);
    } catch (e) {
      Logger.error('Repository: Failed to save counter', error: e);
      return Left(StorageFailure('Failed to save counter: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Counter>> incrementCounter() async {
    try {
      final current = await localDataSource.getCounter();
      final newCounter = CounterModel(value: current.value + 1);
      await localDataSource.saveCounter(newCounter);
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to increment counter', error: e);
      return Left(
        StorageFailure('Failed to increment counter: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Counter>> decrementCounter() async {
    try {
      final current = await localDataSource.getCounter();
      final newCounter = CounterModel(value: current.value - 1);
      await localDataSource.saveCounter(newCounter);
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to decrement counter', error: e);
      return Left(
        StorageFailure('Failed to decrement counter: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Counter>> resetCounter() async {
    try {
      const newCounter = CounterModel(value: 0);
      await localDataSource.saveCounter(newCounter);
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Repository: Failed to reset counter', error: e);
      return Left(StorageFailure('Failed to reset counter: ${e.toString()}'));
    }
  }
}
