import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/datasources/counter_local_datasource.dart';
import '../../data/repositories/counter_repository_impl.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/reset_counter.dart';
import '../controllers/counter_controller.dart';

/// Counter Binding - Presentation layer
/// Handles dependency injection for Counter feature
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.lazyPut<CounterLocalDataSource>(
      () => CounterLocalDataSourceImpl(GetStorage()),
    );

    Get.lazyPut(
      () => CounterRepositoryImpl(Get.find<CounterLocalDataSource>()),
    );

    // Domain layer - Use cases
    Get.lazyPut(() => GetCounter(Get.find<CounterRepositoryImpl>()));
    Get.lazyPut(() => IncrementCounter(Get.find<CounterRepositoryImpl>()));
    Get.lazyPut(() => DecrementCounter(Get.find<CounterRepositoryImpl>()));
    Get.lazyPut(() => ResetCounter(Get.find<CounterRepositoryImpl>()));

    // Presentation layer - Controller
    Get.lazyPut(
      () => CounterController(
        getCounterUseCase: Get.find<GetCounter>(),
        incrementCounterUseCase: Get.find<IncrementCounter>(),
        decrementCounterUseCase: Get.find<DecrementCounter>(),
        resetCounterUseCase: Get.find<ResetCounter>(),
      ),
    );
  }
}
