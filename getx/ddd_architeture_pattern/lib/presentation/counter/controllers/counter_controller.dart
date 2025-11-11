import 'package:get/get.dart';

import '../../../application/counter/usecases/get_counter_usecase.dart';
import '../../../application/counter/usecases/increment_counter_usecase.dart';
import '../../../application/counter/usecases/decrement_counter_usecase.dart';
import '../../../application/counter/usecases/reset_counter_usecase.dart';
import '../../../domain/counter/entities/counter_entity.dart';

/// Counter Controller - Presentation Layer
///
/// In DDD with GetX:
/// - Controllers belong to presentation/UI layer
/// - They call application use cases (not domain directly)
/// - They manage reactive UI state
/// - They translate domain concepts to UI concepts
class CounterController extends GetxController {
  // Use cases (injected via binding)
  final GetCounterUseCase getCounterUseCase;
  final IncrementCounterUseCase incrementCounterUseCase;
  final DecrementCounterUseCase decrementCounterUseCase;
  final ResetCounterUseCase resetCounterUseCase;

  CounterController({
    required this.getCounterUseCase,
    required this.incrementCounterUseCase,
    required this.decrementCounterUseCase,
    required this.resetCounterUseCase,
  });

  // Reactive state
  final Rx<CounterEntity?> _counter = Rx<CounterEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters for UI
  int get counterValue => _counter.value?.value.number ?? 0;
  bool get canDecrement => _counter.value?.value.canDecrement ?? false;

  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }

  /// Load counter from use case
  Future<void> loadCounter() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getCounterUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (counter) {
        _counter.value = counter;
      },
    );

    isLoading.value = false;
  }

  /// Increment counter
  Future<void> increment() async {
    final result = await incrementCounterUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (counter) {
        _counter.value = counter;
      },
    );
  }

  /// Decrement counter
  Future<void> decrement() async {
    if (!canDecrement) return;

    final result = await decrementCounterUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (counter) {
        _counter.value = counter;
      },
    );
  }

  /// Reset counter
  Future<void> reset() async {
    final result = await resetCounterUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (counter) {
        _counter.value = counter;
        Get.snackbar('Success', 'Counter reset to zero');
      },
    );
  }
}
