import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../dtos/counter_dto.dart';

/// Counter Repository Implementation
///
/// Implements the domain repository interface.
/// Coordinates with data sources and handles domain/DTO conversion.
/// Returns Either<Failure, Success> for error handling.
class CounterRepositoryImpl implements CounterRepository {
  static const String _defaultCounterId = 'main_counter';
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, CounterEntity>> getCounter() async {
    try {
      final dto = await localDataSource.getCounter();

      if (dto == null) {
        // Return default counter if none exists
        final defaultCounter = CounterEntity.create(_defaultCounterId);
        await saveCounter(defaultCounter);
        return Right(defaultCounter);
      }

      return Right(dto.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get counter: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter) async {
    try {
      final dto = CounterDTO.fromEntity(counter);
      await localDataSource.saveCounter(dto);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to save counter: $e'));
    }
  }
}
