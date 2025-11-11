import 'package:shared_preferences/shared_preferences.dart';

import '../dtos/counter_dto.dart';

/// Counter Local Data Source Interface
///
/// Defines storage operations for counter data.
abstract class CounterLocalDataSource {
  /// Get stored counter DTO
  Future<CounterDTO?> getCounter();

  /// Save counter DTO
  Future<void> saveCounter(CounterDTO counter);
}

/// Counter Local Data Source Implementation
///
/// Uses SharedPreferences for persistence.
/// Handles serialization/deserialization through CounterDTO.
class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  static const String _keyCounter = 'counter_ddd';
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<CounterDTO?> getCounter() async {
    try {
      final jsonString = sharedPreferences.getString(_keyCounter);
      if (jsonString == null) {
        return null;
      }
      return CounterDTO.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to get counter from storage: $e');
    }
  }

  @override
  Future<void> saveCounter(CounterDTO counter) async {
    try {
      final jsonString = counter.encode();
      await sharedPreferences.setString(_keyCounter, jsonString);
    } catch (e) {
      throw Exception('Failed to save counter to storage: $e');
    }
  }
}
