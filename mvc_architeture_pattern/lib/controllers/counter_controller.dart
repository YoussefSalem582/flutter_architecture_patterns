import 'package:get/get.dart';
import '../models/counter_model.dart';

/// Controller for Counter functionality
/// Manages counter state and business logic using GetX
class CounterController extends GetxController {
  // Reactive counter model
  final _counter = CounterModel().obs;

  // Getter for counter value
  int get counterValue => _counter.value.value;

  /// Increment the counter
  void increment() {
    _counter.value.increment();
    _counter.refresh(); // Notify observers
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
    Get.snackbar(
      'Counter Reset',
      'Counter has been reset to 0',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
}
