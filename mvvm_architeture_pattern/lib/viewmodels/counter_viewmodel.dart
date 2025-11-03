import 'package:get/get.dart';
import '../models/counter_model.dart';

/// Counter ViewModel
/// Contains reactive data and business logic for the counter feature
/// Uses GetX observables (.obs) to enable reactive UI updates
class CounterViewModel extends GetxController {
  // Reactive observable - UI will automatically update when this changes
  final _counter = CounterModel(value: 0).obs;

  // Getter to access the counter model
  CounterModel get counter => _counter.value;

  // Getter to access just the counter value
  int get counterValue => _counter.value.value;

  /// Increment the counter by 1
  void increment() {
    _counter.value = _counter.value.copyWith(value: counterValue + 1);
    Get.snackbar(
      'Counter Updated',
      'Counter incremented to $counterValue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Decrement the counter by 1
  void decrement() {
    _counter.value = _counter.value.copyWith(value: counterValue - 1);
    Get.snackbar(
      'Counter Updated',
      'Counter decremented to $counterValue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Reset the counter to 0
  void reset() {
    _counter.value = CounterModel(value: 0);
    Get.snackbar(
      'Counter Reset',
      'Counter has been reset to 0',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void onInit() {
    super.onInit();
    print('CounterViewModel initialized');
  }

  @override
  void onClose() {
    print('CounterViewModel disposed');
    super.onClose();
  }
}
