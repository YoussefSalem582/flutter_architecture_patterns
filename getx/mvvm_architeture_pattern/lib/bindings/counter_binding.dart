import 'package:get/get.dart';
import '../viewmodels/counter_viewmodel.dart';

/// Counter Binding
/// Initializes and injects CounterViewModel when navigating to Counter screen
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - ViewModel is created only when needed
    Get.lazyPut<CounterViewModel>(() => CounterViewModel());
  }
}
