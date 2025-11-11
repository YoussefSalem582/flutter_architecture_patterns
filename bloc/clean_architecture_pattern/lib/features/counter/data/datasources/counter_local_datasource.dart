import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/utils/logger.dart';
import '../models/counter_model.dart';

/// Counter Local Data Source
/// Handles local storage operations for counter data
abstract class CounterLocalDataSource {
  /// Get counter from local storage
  Future<CounterModel> getCounter();

  /// Save counter to local storage
  Future<void> saveCounter(CounterModel counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<CounterModel> getCounter() async {
    try {
      final value = sharedPreferences.getInt(StorageKeys.counterValue) ?? 0;
      Logger.info('Counter retrieved from storage: $value', tag: 'DATA_SOURCE');
      return CounterModel(value: value);
    } catch (e) {
      Logger.error(
        'Error getting counter from storage',
        tag: 'DATA_SOURCE',
        error: e,
      );
      return const CounterModel(value: 0);
    }
  }

  @override
  Future<void> saveCounter(CounterModel counter) async {
    try {
      await sharedPreferences.setInt(StorageKeys.counterValue, counter.value);
      Logger.info(
        'Counter saved to storage: ${counter.value}',
        tag: 'DATA_SOURCE',
      );
    } catch (e) {
      Logger.error(
        'Error saving counter to storage',
        tag: 'DATA_SOURCE',
        error: e,
      );
      rethrow;
    }
  }
}
