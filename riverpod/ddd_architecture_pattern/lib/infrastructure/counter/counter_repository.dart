import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/core/failures.dart';
import '../../domain/counter/counter.dart';
import '../../domain/counter/i_counter_repository.dart';
import 'counter_dtos.dart';

class CounterRepository implements ICounterRepository {
  final SharedPreferences _sharedPreferences;
  static const String _counterKey = 'counter_key';

  CounterRepository(this._sharedPreferences);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final jsonString = _sharedPreferences.getString(_counterKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return Right(CounterDto.fromJson(jsonMap).toDomain());
      } else {
        return Right(Counter.initial());
      }
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCounter(Counter counter) async {
    try {
      final counterDto = CounterDto.fromDomain(counter);
      final jsonString = json.encode(counterDto.toJson());
      await _sharedPreferences.setString(_counterKey, jsonString);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}
