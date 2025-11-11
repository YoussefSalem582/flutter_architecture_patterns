import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/utils/logger.dart';
import '../models/counter_model.dart';

/// Counter Local Data Source
/// Handles local storage operations for counter
abstract class CounterLocalDataSource {
  /// Get counter from storage
  Future<CounterModel> getCounter();

  /// Save counter to storage
  Future<void> saveCounter(CounterModel counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final GetStorage storage;

  CounterLocalDataSourceImpl(this.storage);

  @override
  Future<CounterModel> getCounter() async {
    try {
      final value = storage.read<int>(StorageKeys.counterValue);
      Logger.info('Retrieved counter value: $value', tag: 'CounterDataSource');
      return CounterModel(value: value ?? 0);
    } catch (e) {
      Logger.error('Failed to get counter', tag: 'CounterDataSource', error: e);
      return const CounterModel(value: 0);
    }
  }

  @override
  Future<void> saveCounter(CounterModel counter) async {
    try {
      await storage.write(StorageKeys.counterValue, counter.value);
      Logger.info(
        'Saved counter value: ${counter.value}',
        tag: 'CounterDataSource',
      );
    } catch (e) {
      Logger.error(
        'Failed to save counter',
        tag: 'CounterDataSource',
        error: e,
      );
      rethrow;
    }
  }
}
