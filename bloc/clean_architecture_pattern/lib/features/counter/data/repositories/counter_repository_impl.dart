import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../models/counter_model.dart';

/// Counter Repository Implementation - Data layer
/// Implements the CounterRepository interface from domain layer
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final counter = await localDataSource.getCounter();
      Logger.info('Counter retrieved: ${counter.value}', tag: 'REPOSITORY');
      return Right(counter.toEntity());
    } catch (e) {
      Logger.error('Error getting counter', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to get counter'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCounter(Counter counter) async {
    try {
      final model = CounterModel.fromEntity(counter);
      await localDataSource.saveCounter(model);
      Logger.info('Counter saved: ${counter.value}', tag: 'REPOSITORY');
      return const Right(null);
    } catch (e) {
      Logger.error('Error saving counter', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to save counter'));
    }
  }

  @override
  Future<Either<Failure, Counter>> incrementCounter() async {
    try {
      final currentCounter = await localDataSource.getCounter();
      final newCounter = currentCounter.copyWith(
        value: currentCounter.value + 1,
      );
      await localDataSource.saveCounter(newCounter);
      Logger.info(
        'Counter incremented to: ${newCounter.value}',
        tag: 'REPOSITORY',
      );
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Error incrementing counter', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to increment counter'));
    }
  }

  @override
  Future<Either<Failure, Counter>> decrementCounter() async {
    try {
      final currentCounter = await localDataSource.getCounter();
      final newCounter = currentCounter.copyWith(
        value: currentCounter.value - 1,
      );
      await localDataSource.saveCounter(newCounter);
      Logger.info(
        'Counter decremented to: ${newCounter.value}',
        tag: 'REPOSITORY',
      );
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Error decrementing counter', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to decrement counter'));
    }
  }

  @override
  Future<Either<Failure, Counter>> resetCounter() async {
    try {
      const newCounter = CounterModel(value: 0);
      await localDataSource.saveCounter(newCounter);
      Logger.info('Counter reset to: 0', tag: 'REPOSITORY');
      return Right(newCounter.toEntity());
    } catch (e) {
      Logger.error('Error resetting counter', tag: 'REPOSITORY', error: e);
      return const Left(StorageFailure('Failed to reset counter'));
    }
  }
}
