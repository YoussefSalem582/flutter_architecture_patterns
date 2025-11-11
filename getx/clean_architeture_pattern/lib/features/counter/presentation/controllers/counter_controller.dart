import 'package:get/get.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/reset_counter.dart';

/// Counter Controller - Presentation layer
/// Manages counter state and business logic using GetX
class CounterController extends GetxController {
  final GetCounter getCounterUseCase;
  final IncrementCounter incrementCounterUseCase;
  final DecrementCounter decrementCounterUseCase;
  final ResetCounter resetCounterUseCase;

  CounterController({
    required this.getCounterUseCase,
    required this.incrementCounterUseCase,
    required this.decrementCounterUseCase,
    required this.resetCounterUseCase,
  });

  // Reactive state
  final _counterValue = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  int get counterValue => _counterValue.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    Logger.info('CounterController initialized', tag: 'CounterController');
    loadCounter();
  }

  /// Load counter from storage
  Future<void> loadCounter() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getCounterUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Logger.error('Failed to load counter: ${failure.message}', tag: 'CounterController');
      },
      (counter) {
        _counterValue.value = counter.value;
        Logger.info('Counter loaded: ${counter.value}', tag: 'CounterController');
      },
    );

    _isLoading.value = false;
  }

  /// Increment counter
  Future<void> increment() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await incrementCounterUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (counter) {
        _counterValue.value = counter.value;
        Get.snackbar(
          'Success',
          'Counter incremented to ${counter.value}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  /// Decrement counter
  Future<void> decrement() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await decrementCounterUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (counter) {
        _counterValue.value = counter.value;
        Get.snackbar(
          'Success',
          'Counter decremented to ${counter.value}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  /// Reset counter
  Future<void> reset() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await resetCounterUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (counter) {
        _counterValue.value = counter.value;
        Get.snackbar(
          'Success',
          'Counter reset to 0',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  @override
  void onClose() {
    Logger.info('CounterController disposed', tag: 'CounterController');
    super.onClose();
  }
}
