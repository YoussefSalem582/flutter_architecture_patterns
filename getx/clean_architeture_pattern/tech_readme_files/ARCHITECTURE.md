# Clean Architecture - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Layer Details](#layer-details)
3. [Data Flow](#data-flow)
4. [Dependency Injection](#dependency-injection)
5. [Error Handling](#error-handling)
6. [Testing Strategy](#testing-strategy)
7. [Best Practices](#best-practices)

---

## Architecture Overview

### The Clean Architecture Principle

Clean Architecture, introduced by Robert C. Martin (Uncle Bob), organizes code into concentric layers with strict dependency rules:

```
┌───────────────────────────────────────────────────────────┐
│                    Presentation Layer                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Domain Layer (Core)                    │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │           Entities (Business Objects)         │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  │                                                      │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │        Use Cases (Business Logic)             │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  │                                                      │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │    Repository Interfaces (Contracts)          │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Data Layer                             │  │
│  │  - Repository Implementations                       │  │
│  │  - Data Sources                                     │  │
│  │  - Models                                           │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Core Principles

1. **Dependency Rule**: Source code dependencies point inward
2. **Independence**: Business logic is independent of frameworks, UI, databases
3. **Testability**: Each layer can be tested in isolation
4. **Flexibility**: Easy to swap implementations without changing business logic

---

## Layer Details

### 1. Domain Layer (Core Business Logic)

**Location**: `lib/features/{feature}/domain/`

**Responsibilities**:
- Define business entities
- Define business rules (use cases)
- Define repository contracts (interfaces)

**Key Characteristics**:
- ✅ Pure Dart code (no Flutter dependencies)
- ✅ No external package dependencies (except utility packages like Dartz, Equatable)
- ✅ Contains abstract classes and interfaces
- ✅ Independent of other layers

#### Entities

**Purpose**: Represent core business objects

**Example**: `counter.dart`
```dart
import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final int value;

  const Counter({required this.value});

  @override
  List<Object?> get props => [value];
}
```

**Key Points**:
- Immutable (final fields)
- Extend Equatable for value equality
- No JSON serialization logic (that's in Models)

#### Use Cases

**Purpose**: Encapsulate a single business operation

**Example**: `increment_counter.dart`
```dart
class IncrementCounter extends UseCase<Counter, NoParams> {
  final CounterRepository repository;

  IncrementCounter(this.repository);

  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (current) => repository.saveCounter(
        Counter(value: current.value + 1),
      ),
    );
  }
}
```

**Key Points**:
- Single responsibility (one action per use case)
- Depend only on repository interfaces
- Return `Either<Failure, Success>` for error handling
- Accept parameters through `Params` classes

#### Repository Interfaces

**Purpose**: Define contracts for data access

**Example**: `counter_repository.dart`
```dart
abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Counter>> saveCounter(Counter counter);
}
```

**Key Points**:
- Abstract class (no implementation)
- Define method signatures only
- Return types use Either for error handling

---

### 2. Data Layer (Data Management)

**Location**: `lib/features/{feature}/data/`

**Responsibilities**:
- Implement repository interfaces
- Handle data sources (local storage, APIs)
- Convert between models and entities

**Key Characteristics**:
- ✅ Depends only on Domain layer
- ✅ Implements repository interfaces from Domain
- ✅ Contains data source logic
- ✅ Handles JSON serialization

#### Models

**Purpose**: Data transfer objects with serialization

**Example**: `counter_model.dart`
```dart
class CounterModel extends Counter {
  const CounterModel({required super.value});

  // JSON serialization
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  // Entity conversion
  Counter toEntity() => Counter(value: value);
  
  factory CounterModel.fromEntity(Counter counter) {
    return CounterModel(value: counter.value);
  }
}
```

**Key Points**:
- Extends domain entity
- Adds serialization methods (fromJson, toJson)
- Provides entity conversion methods

#### Data Sources

**Purpose**: Interact with external data providers

**Example**: `counter_local_datasource.dart`
```dart
class CounterLocalDataSource {
  final GetStorage _storage;

  CounterLocalDataSource(this._storage);

  Future<CounterModel> getCounter() async {
    try {
      final data = _storage.read<Map<String, dynamic>>(StorageKeys.counter);
      if (data == null) {
        return const CounterModel(value: 0);
      }
      return CounterModel.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to read counter');
    }
  }

  Future<void> saveCounter(CounterModel counter) async {
    try {
      await _storage.write(StorageKeys.counter, counter.toJson());
    } catch (e) {
      throw StorageException('Failed to save counter');
    }
  }
}
```

**Key Points**:
- Single responsibility (one data source per storage type)
- Throw exceptions (not Either) - repository handles error conversion
- Use storage keys from constants

#### Repository Implementation

**Purpose**: Implement domain repository interface

**Example**: `counter_repository_impl.dart`
```dart
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final model = await localDataSource.getCounter();
      return Right(model.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Counter>> saveCounter(Counter counter) async {
    try {
      final model = CounterModel.fromEntity(counter);
      await localDataSource.saveCounter(model);
      return Right(counter);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error occurred'));
    }
  }
}
```

**Key Points**:
- Implements domain repository interface
- Depends on data source(s)
- Converts exceptions to Either<Failure, Success>
- Converts models to entities

---

### 3. Presentation Layer (UI & State)

**Location**: `lib/features/{feature}/presentation/`

**Responsibilities**:
- Display UI
- Manage reactive state
- Handle user interactions
- Call use cases

**Key Characteristics**:
- ✅ Depends only on Domain layer
- ✅ Uses GetX for state management
- ✅ Reactive UI with Obx widgets
- ✅ Dependency injection with bindings

#### Controllers

**Purpose**: Manage state and business logic calls

**Example**: `counter_controller.dart`
```dart
class CounterController extends GetxController {
  // Dependencies (injected via binding)
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
  final counter = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }

  Future<void> loadCounter() async {
    isLoading.value = true;
    final result = await getCounterUseCase(NoParams());
    result.fold(
      (failure) => _handleFailure(failure),
      (counterEntity) => counter.value = counterEntity.value,
    );
    isLoading.value = false;
  }

  Future<void> increment() async {
    final result = await incrementCounterUseCase(NoParams());
    result.fold(
      (failure) => _handleFailure(failure),
      (counterEntity) => counter.value = counterEntity.value,
    );
  }

  void _handleFailure(Failure failure) {
    errorMessage.value = _mapFailureToMessage(failure);
    Get.snackbar('Error', errorMessage.value);
  }
}
```

**Key Points**:
- Extend GetxController
- Use `.obs` for reactive state
- Call use cases (not repositories directly)
- Handle errors from Either type
- Lifecycle methods (onInit, onClose)

#### Views

**Purpose**: Display UI and react to state changes

**Example**: `counter_view.dart`
```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter Value:', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            
            // Reactive UI with Obx
            Obx(() => Text(
              '${controller.counter.value}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            )),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.decrement,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: controller.increment,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Key Points**:
- StatelessWidget (no setState needed)
- Use `Get.find<Controller>()` to get controller
- Wrap reactive widgets with `Obx()`
- Call controller methods for actions

#### Bindings

**Purpose**: Dependency injection setup

**Example**: `counter_binding.dart`
```dart
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<CounterLocalDataSource>(
      () => CounterLocalDataSource(Get.find<GetStorage>()),
    );

    // Repository
    Get.lazyPut<CounterRepository>(
      () => CounterRepositoryImpl(Get.find<CounterLocalDataSource>()),
    );

    // Use Cases
    Get.lazyPut(() => GetCounter(Get.find<CounterRepository>()));
    Get.lazyPut(() => IncrementCounter(Get.find<CounterRepository>()));
    Get.lazyPut(() => DecrementCounter(Get.find<CounterRepository>()));
    Get.lazyPut(() => ResetCounter(Get.find<CounterRepository>()));

    // Controller
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
```

**Key Points**:
- Extend Bindings class
- Use `lazyPut` for lazy initialization
- Register dependencies from bottom up (DataSource → Repository → UseCases → Controller)
- Dependencies automatically resolved by GetX

---

## Data Flow

### Read Flow (Get Counter)

```
┌──────────────┐
│     View     │  User opens counter screen
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Controller  │  onInit() calls loadCounter()
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Use Case   │  GetCounter.call(NoParams())
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Repository  │  getCounter() - implements interface
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Data Source  │  Read from GetStorage
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Model     │  CounterModel.fromJson()
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Entity     │  model.toEntity()
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Either    │  Right(Counter) or Left(Failure)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Controller  │  Updates counter.value (reactive)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     View     │  Obx rebuilds with new value
└──────────────┘
```

### Write Flow (Increment Counter)

```
┌──────────────┐
│     View     │  User taps increment button
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Controller  │  increment() method called
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Use Case   │  IncrementCounter.call(NoParams())
│              │  1. Get current counter
│              │  2. Increment value
│              │  3. Save new counter
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Repository  │  saveCounter(Counter)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Model     │  CounterModel.fromEntity()
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Data Source  │  Write to GetStorage (JSON)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Either    │  Right(Counter) or Left(Failure)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Controller  │  Updates counter.value
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     View     │  Obx rebuilds UI
└──────────────┘
```

---

## Dependency Injection

### GetX Dependency Injection

**Initialization**: `main.dart`
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize global dependencies
  await GetStorage.init();
  Get.put(GetStorage());  // Make GetStorage globally available
  
  runApp(const MyApp());
}
```

**Registration**: `bindings/{feature}_binding.dart`
```dart
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies in order
    Get.lazyPut<DataSource>(() => DataSourceImpl());
    Get.lazyPut<Repository>(() => RepositoryImpl(Get.find()));
    Get.lazyPut(() => UseCase(Get.find()));
    Get.lazyPut(() => Controller(useCase: Get.find()));
  }
}
```

**Usage**: `routes/app_pages.dart`
```dart
GetPage(
  name: AppRoutes.counter,
  page: () => const CounterView(),
  binding: CounterBinding(),  // Automatically injects dependencies
),
```

**Benefits**:
- ✅ Lazy initialization (only created when needed)
- ✅ Automatic disposal (cleaned up when not needed)
- ✅ Testable (easy to inject mocks)
- ✅ Decoupled (no direct instantiation)

---

## Error Handling

### Either Pattern with Dartz

**Purpose**: Functional error handling without exceptions in business logic

```dart
// Success path (Right)
return Right(counter);

// Error path (Left)
return Left(StorageFailure('Failed to save'));
```

### Failure Hierarchy

**Base Class**: `lib/core/error/failures.dart`
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

### Error Flow

```
Data Source (throws Exception)
       ↓
Repository (catches, returns Left<Failure>)
       ↓
Use Case (propagates Left<Failure>)
       ↓
Controller (handles with fold)
       ↓
View (displays error message)
```

### Example Error Handling

```dart
// In Repository
try {
  final result = await dataSource.getData();
  return Right(result);
} on CustomException catch (e) {
  return Left(StorageFailure(e.message));
} catch (e) {
  return Left(StorageFailure('Unexpected error'));
}

// In Controller
final result = await useCase(params);
result.fold(
  (failure) => _handleError(failure),  // Left
  (data) => _handleSuccess(data),      // Right
);
```

---

## Testing Strategy

### Unit Tests

**Domain Layer**:
```dart
test('should increment counter value', () {
  // Arrange
  final counter = Counter(value: 5);
  
  // Act
  final result = Counter(value: counter.value + 1);
  
  // Assert
  expect(result.value, 6);
});
```

**Use Cases** (with mocks):
```dart
class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late IncrementCounter useCase;
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
    useCase = IncrementCounter(mockRepository);
  });

  test('should increment counter successfully', () async {
    // Arrange
    when(() => mockRepository.getCounter())
        .thenAnswer((_) async => Right(Counter(value: 5)));
    when(() => mockRepository.saveCounter(any()))
        .thenAnswer((_) async => Right(Counter(value: 6)));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(Counter(value: 6)));
    verify(() => mockRepository.getCounter());
    verify(() => mockRepository.saveCounter(any()));
  });
}
```

**Data Layer**:
```dart
test('should save counter to local storage', () async {
  // Arrange
  final model = CounterModel(value: 10);
  when(() => mockStorage.write(any(), any()))
      .thenAnswer((_) async => Future.value());

  // Act
  await dataSource.saveCounter(model);

  // Assert
  verify(() => mockStorage.write(StorageKeys.counter, model.toJson()));
});
```

### Widget Tests

```dart
testWidgets('should display counter value', (tester) async {
  // Arrange
  Get.put(mockController);
  when(() => mockController.counter).thenReturn(5.obs);

  // Act
  await tester.pumpWidget(MaterialApp(home: CounterView()));

  // Assert
  expect(find.text('5'), findsOneWidget);
});
```

### Integration Tests

```dart
void main() {
  testWidgets('full counter flow', (tester) async {
    // Initialize app
    await GetStorage.init();
    await tester.pumpWidget(MyApp());

    // Navigate to counter
    await tester.tap(find.text('Counter'));
    await tester.pumpAndSettle();

    // Test increment
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
```

---

## Best Practices

### 1. Layer Independence
```dart
// ❌ Bad: Presentation importing Data
import 'package:app/features/counter/data/models/counter_model.dart';

// ✅ Good: Presentation importing Domain
import 'package:app/features/counter/domain/entities/counter.dart';
```

### 2. Use Cases
```dart
// ❌ Bad: Controller calling repository directly
class Controller extends GetxController {
  final CounterRepository repository;
  void increment() => repository.incrementCounter();
}

// ✅ Good: Controller calling use case
class Controller extends GetxController {
  final IncrementCounter incrementCounterUseCase;
  void increment() => incrementCounterUseCase(NoParams());
}
```

### 3. Error Handling
```dart
// ❌ Bad: Using try-catch in use case
try {
  final counter = await repository.getCounter();
  return counter;
} catch (e) {
  print(e);
}

// ✅ Good: Using Either
final result = await repository.getCounter();
return result.fold(
  (failure) => Left(failure),
  (counter) => Right(counter),
);
```

### 4. Reactive State
```dart
// ❌ Bad: Using setState in GetX
setState(() => counter++);

// ✅ Good: Using .obs
final counter = 0.obs;
counter.value++;
```

### 5. Dependency Injection
```dart
// ❌ Bad: Creating instances directly
class Controller extends GetxController {
  final repository = CounterRepositoryImpl();
}

// ✅ Good: Injecting dependencies
class Controller extends GetxController {
  final CounterRepository repository;
  Controller({required this.repository});
}
```

---

## Summary

This Clean Architecture implementation provides:

1. **Clear Separation**: Each layer has distinct responsibilities
2. **Testability**: Easy to test each layer independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the pattern
5. **Flexibility**: Swap implementations without changing business logic

**Key Takeaways**:
- Domain layer is the core (no dependencies)
- Data and Presentation depend on Domain
- Use cases encapsulate business logic
- Repositories define contracts, implementations provide data
- GetX provides state management and dependency injection
- Either pattern provides functional error handling

---

**For more information**, refer to:
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetX Documentation](https://pub.dev/packages/get)
- [Dartz Package](https://pub.dev/packages/dartz)
