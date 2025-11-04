import 'package:get_storage/get_storage.dart';

import '../dtos/counter_dto.dart';

/// Counter Local Data Source - Infrastructure Layer
///
/// In DDD, data sources:
/// - Handle low-level persistence operations
/// - Use infrastructure-specific tools (GetStorage)
/// - Throw exceptions (not Either)
/// - Work with DTOs, not domain entities
class CounterLocalDataSource {
  final GetStorage storage;
  static const String _counterKey = 'counter';

  CounterLocalDataSource(this.storage);

  /// Read counter from storage
  Future<CounterDto?> getCounter() async {
    try {
      final data = storage.read<Map<String, dynamic>>(_counterKey);
      if (data == null) return null;
      return CounterDto.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to read counter: $e');
    }
  }

  /// Write counter to storage
  Future<void> saveCounter(CounterDto counter) async {
    try {
      await storage.write(_counterKey, counter.toJson());
    } catch (e) {
      throw StorageException('Failed to save counter: $e');
    }
  }

  /// Check if counter exists
  Future<bool> exists() async {
    return storage.hasData(_counterKey);
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
