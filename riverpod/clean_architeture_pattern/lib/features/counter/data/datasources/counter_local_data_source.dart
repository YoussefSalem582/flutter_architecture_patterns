import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/counter_model.dart';

abstract class CounterLocalDataSource {
  Future<CounterModel> getLastCounter();
  Future<void> cacheCounter(CounterModel counterToCache);
}

const CACHED_COUNTER = 'CACHED_COUNTER';

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<CounterModel> getLastCounter() {
    final jsonString = sharedPreferences.getString(CACHED_COUNTER);
    if (jsonString != null) {
      return Future.value(CounterModel.fromJson(json.decode(jsonString)));
    } else {
      return Future.value(const CounterModel(value: 0));
    }
  }

  @override
  Future<void> cacheCounter(CounterModel counterToCache) {
    return sharedPreferences.setString(
      CACHED_COUNTER,
      json.encode(counterToCache.toJson()),
    );
  }
}
