import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/counter_model.dart';

/// Controller for Counter functionality
/// Manages counter state and business logic using GetX
/// Uses GetStorage for data persistence across app restarts
class CounterController extends GetxController {
  // GetStorage instance for persistence
  final _storage = GetStorage();

  // Storage key for counter value
  static const String _counterKey = 'counter_value';

  // Reactive counter model
  final _counter = CounterModel().obs;

  // Getter for counter value
  int get counterValue => _counter.value.value;

  @override
  void onInit() {
    super.onInit();
    // Load saved counter value from storage
    _loadCounter();
  }

  /// Load counter value from storage
  void _loadCounter() {
    final savedValue = _storage.read<int>(_counterKey);
    if (savedValue != null) {
      _counter.value = CounterModel(value: savedValue);
    }
  }

  /// Save counter value to storage
  Future<void> _saveCounter() async {
    await _storage.write(_counterKey, counterValue);
  }

  /// Increment the counter
  void increment() {
    _counter.value.increment();
    _counter.refresh(); // Notify observers
    _saveCounter(); // Persist to storage
    Get.snackbar(
      'Counter Updated',
      'Counter incremented to $counterValue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Decrement the counter
  void decrement() {
    _counter.value.decrement();
    _counter.refresh(); // Notify observers
    _saveCounter(); // Persist to storage
    Get.snackbar(
      'Counter Updated',
      'Counter decremented to $counterValue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Reset the counter to zero
  void reset() {
    _counter.value.reset();
    _counter.refresh(); // Notify observers
    _saveCounter(); // Persist to storage
    Get.snackbar(
      'Counter Reset',
      'Counter has been reset to 0',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
}
