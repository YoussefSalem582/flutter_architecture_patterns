# 3️⃣ Architecture Pattern Integration

**Read Time:** ⏱️ 15 minutes

This document shows how BLoC and GetX integrate with different architecture patterns through side-by-side code examples.

---

## 📚 Patterns Covered

1. [MVC Pattern](#mvc-pattern)
2. [MVVM Pattern](#mvvm-pattern)
3. [Clean Architecture](#clean-architecture)
4. [DDD (Domain-Driven Design)](#ddd-domain-driven-design)

---

## 1️⃣ MVC Pattern

### With BLoC

**Structure:**
```
lib/
├── models/          # M - Data models
│   └── counter_model.dart
├── views/           # V - UI
│   └── counter_view.dart
└── cubits/          # C - Business logic (Cubit as Controller)
    └── counter_cubit.dart
```

**Model:**
```dart
// models/counter_model.dart
class CounterModel extends Equatable {
  final int value;
  
  const CounterModel({this.value = 0});
  
  CounterModel increment() => CounterModel(value: value + 1);
  CounterModel decrement() => CounterModel(value: value - 1);
  CounterModel reset() => const CounterModel(value: 0);
  
  @override
  List<Object> get props => [value];
}
```

**Controller (Cubit):**
```dart
// cubits/counter_cubit.dart
class CounterCubit extends HydratedCubit<CounterModel> {
  CounterCubit() : super(const CounterModel());
  
  void increment() => emit(state.increment());
  void decrement() => emit(state.decrement());
  void reset() => emit(state.reset());
  
  @override
  CounterModel? fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }
  
  @override
  Map<String, dynamic>? toJson(CounterModel state) {
    return {'value': state.value};
  }
}
```

**View:**
```dart
// views/counter_view.dart
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: Scaffold(
        body: Center(
          child: BlocBuilder<CounterCubit, CounterModel>(
            builder: (context, state) {
              return Text('${state.value}', style: TextStyle(fontSize: 48));
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => context.read<CounterCubit>().increment(),
              child: Icon(Icons.add),
            ),
            SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () => context.read<CounterCubit>().decrement(),
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Lines of Code:** ~70

---

### With GetX

**Structure:**
```
lib/
├── models/          # M - Data models
│   └── counter_model.dart
├── views/           # V - UI
│   └── counter_view.dart
└── controllers/     # C - Business logic
    └── counter_controller.dart
```

**Model:**
```dart
// models/counter_model.dart
class CounterModel {
  final int value;
  
  CounterModel({this.value = 0});
  
  CounterModel increment() => CounterModel(value: value + 1);
  CounterModel decrement() => CounterModel(value: value - 1);
  CounterModel reset() => CounterModel(value: 0);
}
```

**Controller:**
```dart
// controllers/counter_controller.dart
class CounterController extends GetxController {
  final _storage = GetStorage();
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    count.value = _storage.read('count') ?? 0;
    ever(count, (_) => _storage.write('count', count.value));
  }
  
  void increment() => count.value++;
  void decrement() => count.value--;
  void reset() => count.value = 0;
}
```

**View:**
```dart
// views/counter_view.dart
class CounterView extends StatelessWidget {
  final controller = Get.put(CounterController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('${controller.count}', 
                           style: TextStyle(fontSize: 48))),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.increment,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: controller.decrement,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

**Lines of Code:** ~45

**Reduction:** 36% less code with GetX

---

## 2️⃣ MVVM Pattern

### With BLoC

**Structure:**
```
lib/
├── models/          # M - Data entities
│   └── counter_model.dart
├── views/           # V - UI
│   └── counter_view.dart
└── viewmodels/      # VM - Presentation logic (Cubit as ViewModel)
    └── counter_viewmodel.dart
```

**ViewModel (Cubit):**
```dart
// viewmodels/counter_viewmodel.dart
abstract class CounterState extends Equatable {}

class CounterInitial extends CounterState {
  @override
  List<Object> get props => [];
}

class CounterLoading extends CounterState {
  @override
  List<Object> get props => [];
}

class CounterLoaded extends CounterState {
  final int count;
  CounterLoaded(this.count);
  @override
  List<Object> get props => [count];
}

class CounterError extends CounterState {
  final String message;
  CounterError(this.message);
  @override
  List<Object> get props => [message];
}

class CounterViewModel extends Cubit<CounterState> {
  CounterViewModel() : super(CounterInitial());
  
  void loadCounter() async {
    emit(CounterLoading());
    try {
      // Simulate loading
      await Future.delayed(Duration(milliseconds: 500));
      emit(CounterLoaded(0));
    } catch (e) {
      emit(CounterError(e.toString()));
    }
  }
  
  void increment() {
    if (state is CounterLoaded) {
      final current = (state as CounterLoaded).count;
      emit(CounterLoaded(current + 1));
    }
  }
  
  void decrement() {
    if (state is CounterLoaded) {
      final current = (state as CounterLoaded).count;
      emit(CounterLoaded(current - 1));
    }
  }
}
```

**View:**
```dart
// views/counter_view.dart
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterViewModel()..loadCounter(),
      child: Scaffold(
        body: BlocBuilder<CounterViewModel, CounterState>(
          builder: (context, state) {
            if (state is CounterLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is CounterLoaded) {
              return Center(
                child: Text('${state.count}', style: TextStyle(fontSize: 48)),
              );
            }
            if (state is CounterError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Container();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<CounterViewModel>().increment(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

**Lines of Code:** ~95

---

### With GetX

**ViewModel (Controller):**
```dart
// viewmodels/counter_viewmodel.dart
class CounterViewModel extends GetxController {
  final count = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }
  
  void loadCounter() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(milliseconds: 500));
      count.value = 0;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  void increment() => count.value++;
  void decrement() => count.value--;
}
```

**View:**
```dart
// views/counter_view.dart
class CounterView extends StatelessWidget {
  final viewModel = Get.put(CounterViewModel());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage.isNotEmpty) {
          return Center(child: Text('Error: ${viewModel.errorMessage}'));
        }
        return Center(
          child: Text('${viewModel.count}', style: TextStyle(fontSize: 48)),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**Lines of Code:** ~55

**Reduction:** 42% less code with GetX

---

## 3️⃣ Clean Architecture

### With BLoC

**Structure:**
```
lib/
├── core/
│   └── error/failures.dart
├── features/counter/
│   ├── data/
│   │   ├── models/counter_model.dart
│   │   ├── datasources/counter_local_datasource.dart
│   │   └── repositories/counter_repository_impl.dart
│   ├── domain/
│   │   ├── entities/counter.dart
│   │   ├── repositories/counter_repository.dart
│   │   └── usecases/increment_counter.dart
│   └── presentation/
│       ├── cubit/counter_cubit.dart
│       └── views/counter_view.dart
```

**Domain Entity:**
```dart
// domain/entities/counter.dart
class Counter extends Equatable {
  final int value;
  const Counter({required this.value});
  
  @override
  List<Object> get props => [value];
}
```

**Use Case:**
```dart
// domain/usecases/increment_counter.dart
class IncrementCounter {
  final CounterRepository repository;
  IncrementCounter(this.repository);
  
  Future<Either<Failure, Counter>> call() async {
    return await repository.incrementCounter();
  }
}
```

**Cubit (Presentation):**
```dart
// presentation/cubit/counter_cubit.dart
class CounterCubit extends Cubit<CounterState> {
  final IncrementCounter incrementUseCase;
  final DecrementCounter decrementUseCase;
  
  CounterCubit({
    required this.incrementUseCase,
    required this.decrementUseCase,
  }) : super(CounterInitial());
  
  Future<void> increment() async {
    emit(CounterLoading());
    final result = await incrementUseCase();
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }
}
```

**Lines of Code:** ~150 (for counter feature)

---

### With GetX

**Controller (Presentation):**
```dart
// presentation/controllers/counter_controller.dart
class CounterController extends GetxController {
  final IncrementCounterUseCase incrementUseCase;
  final DecrementCounterUseCase decrementUseCase;
  
  CounterController({
    required this.incrementUseCase,
    required this.decrementUseCase,
  });
  
  final counter = Rx<Counter?>(null);
  final isLoading = false.obs;
  final error = ''.obs;
  
  Future<void> increment() async {
    isLoading.value = true;
    final result = await incrementUseCase.execute();
    result.fold(
      (failure) => error.value = failure.message,
      (value) => counter.value = value,
    );
    isLoading.value = false;
  }
}
```

**Binding:**
```dart
// presentation/bindings/counter_binding.dart
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CounterController(
      incrementUseCase: Get.find(),
      decrementUseCase: Get.find(),
    ));
  }
}
```

**Lines of Code:** ~120 (for counter feature)

**Reduction:** 20% less code with GetX

---

## 4️⃣ DDD Pattern

### With BLoC

**Domain Layer (Pure Dart):**
```dart
// domain/counter/entities/counter_entity.dart
class CounterEntity extends Equatable {
  final String id;
  final CounterValue value;
  
  const CounterEntity({required this.id, required this.value});
  
  CounterEntity increment() {
    return CounterEntity(id: id, value: value.increment());
  }
  
  @override
  List<Object> get props => [id, value];
}

// domain/counter/value_objects/counter_value.dart
class CounterValue extends Equatable {
  final int number;
  
  const CounterValue._(this.number);
  
  factory CounterValue(int value) {
    if (value < 0) {
      throw ArgumentError('Counter cannot be negative');
    }
    return CounterValue._(value);
  }
  
  CounterValue increment() => CounterValue._(number + 1);
  CounterValue decrement() => number == 0 ? this : CounterValue._(number - 1);
  
  @override
  List<Object> get props => [number];
}
```

**Application Layer (Use Cases):**
```dart
// application/counter/usecases/increment_counter_usecase.dart
class IncrementCounterUseCase {
  final CounterRepository repository;
  
  IncrementCounterUseCase(this.repository);
  
  Future<Either<Failure, CounterEntity>> execute() async {
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (counter) async {
        final updatedCounter = counter.increment();
        final saveResult = await repository.saveCounter(updatedCounter);
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right(updatedCounter),
        );
      },
    );
  }
}
```

**Presentation Layer (Cubit):**
```dart
// presentation/counter/cubit/counter_cubit.dart
class CounterCubit extends Cubit<CounterState> {
  final IncrementCounterUseCase incrementUseCase;
  
  CounterCubit({required this.incrementUseCase}) 
      : super(const CounterInitial());
  
  Future<void> increment() async {
    final result = await incrementUseCase.execute();
    result.fold(
      (failure) => emit(CounterError(failure)),
      (entity) => emit(CounterLoaded(entity)),
    );
  }
}
```

**Lines of Code:** ~200 (for counter feature)

---

### With GetX

Same domain and application layers (framework-independent), different presentation:

**Presentation Layer (Controller):**
```dart
// presentation/counter/controllers/counter_controller.dart
class CounterController extends GetxController {
  final IncrementCounterUseCase incrementUseCase;
  final DecrementCounterUseCase decrementUseCase;
  final ResetCounterUseCase resetUseCase;
  
  CounterController({
    required this.incrementUseCase,
    required this.decrementUseCase,
    required this.resetUseCase,
  });
  
  final counter = Rx<CounterEntity?>(null);
  final isLoading = false.obs;
  final error = Rx<Failure?>(null);
  
  Future<void> increment() async {
    isLoading.value = true;
    error.value = null;
    
    final result = await incrementUseCase.execute();
    result.fold(
      (failure) => error.value = failure,
      (entity) => counter.value = entity,
    );
    
    isLoading.value = false;
  }
}
```

**Lines of Code:** ~170 (for counter feature)

**Reduction:** 15% less code with GetX

---

## 📊 Summary Comparison

| Pattern | BLoC Lines | GetX Lines | Reduction |
|---------|-----------|-----------|-----------|
| **MVC** | ~70 | ~45 | 36% |
| **MVVM** | ~95 | ~55 | 42% |
| **Clean** | ~150 | ~120 | 20% |
| **DDD** | ~200 | ~170 | 15% |

**Key Observations:**
- ✅ GetX consistently requires less code
- ✅ More complex architectures = smaller difference
- ✅ BLoC provides more explicit type safety
- ✅ GetX provides faster development

---

## 💡 Key Takeaways

### BLoC Strengths:
- ✅ Explicit state definitions
- ✅ Better compile-time safety
- ✅ Clear separation of concerns
- ✅ Excellent for complex state machines

### GetX Strengths:
- ✅ Less boilerplate code
- ✅ Faster to implement
- ✅ Built-in DI and routing
- ✅ Easier to learn and use

### Both Work Well With:
- ✅ All architecture patterns
- ✅ Clean Architecture principles
- ✅ Domain-Driven Design
- ✅ Separation of concerns

---

**[← Previous: How They Work](./02_HOW_THEY_WORK.md)** | **[Next: Performance →](./04_PERFORMANCE.md)**

---

**Last Updated:** November 12, 2025
