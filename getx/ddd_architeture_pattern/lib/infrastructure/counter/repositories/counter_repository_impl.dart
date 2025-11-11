import 'package:dartz/dartz.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../dtos/counter_dto.dart';

/// Counter Repository Implementation - Infrastructure Layer
///
/// In DDD, repository implementations:
/// - Implement domain repository interfaces
/// - Live in infrastructure layer
/// - Use data sources for actual persistence
/// - Convert DTOs to domain entities
/// - Convert exceptions to Either<Failure, Success>
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource dataSource;

  CounterRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, CounterEntity>> getCounter() async {
    try {
      final dto = await dataSource.getCounter();

      if (dto == null) {
        return const Left(NotFoundFailure('Counter not found'));
      }

      // Convert DTO to domain entity
      return Right(dto.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter) async {
    try {
      // Convert domain entity to DTO
      final dto = CounterDto.fromEntity(counter);

      await dataSource.saveCounter(dto);

      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<bool> exists() async {
    return await dataSource.exists();
  }
}
