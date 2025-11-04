import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../application/counter/usecases/get_counter_usecase.dart';
import '../../../application/counter/usecases/increment_counter_usecase.dart';
import '../../../application/counter/usecases/decrement_counter_usecase.dart';
import '../../../application/counter/usecases/reset_counter_usecase.dart';
import '../../../domain/counter/repositories/counter_repository.dart';
import '../../../infrastructure/counter/datasources/counter_local_datasource.dart';
import '../../../infrastructure/counter/repositories/counter_repository_impl.dart';
import '../controllers/counter_controller.dart';

/// Counter Binding - Dependency Injection
///
/// In DDD with GetX:
/// - Bindings wire up the dependency graph
/// - They follow dependency inversion principle
/// - Infrastructure implements domain interfaces
/// - Dependencies flow: UI → Application → Domain ← Infrastructure
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    // Infrastructure layer (data source)
    Get.lazyPut<CounterLocalDataSource>(
      () => CounterLocalDataSource(Get.find<GetStorage>()),
    );

    // Infrastructure layer (repository implementation)
    Get.lazyPut<CounterRepository>(
      () => CounterRepositoryImpl(Get.find<CounterLocalDataSource>()),
    );

    // Application layer (use cases)
    Get.lazyPut(() => GetCounterUseCase(Get.find<CounterRepository>()));
    Get.lazyPut(() => IncrementCounterUseCase(Get.find<CounterRepository>()));
    Get.lazyPut(() => DecrementCounterUseCase(Get.find<CounterRepository>()));
    Get.lazyPut(() => ResetCounterUseCase(Get.find<CounterRepository>()));

    // Presentation layer (controller)
    Get.lazyPut(
      () => CounterController(
        getCounterUseCase: Get.find(),
        incrementCounterUseCase: Get.find(),
        decrementCounterUseCase: Get.find(),
        resetCounterUseCase: Get.find(),
      ),
    );
  }
}
