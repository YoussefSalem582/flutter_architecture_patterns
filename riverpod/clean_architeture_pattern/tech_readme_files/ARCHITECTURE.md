# Clean Architecture with Riverpod - Technical Documentation

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
│         (Riverpod Providers + ConsumerWidgets)            │
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
│  │  - Data Sources (Local/Remote)                      │  │
│  │  - Models (with JSON serialization)                 │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Core Principles

1. **Dependency Rule**: Source code dependencies point inward only
2. **Independence**: Business logic is independent of frameworks, UI, databases
3. **Testability**: Each layer can be tested in isolation
4. **Flexibility**: Easy to swap implementations without changing business logic

### Dependency Direction

```
Presentation → Domain ← Data
     ↓
  Providers use UseCases
     ↓
  UseCases use Repository Interfaces
     ↓
  Repository Implementations (Data layer) implement Interfaces (Domain layer)
```

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
- ✅ Minimal external dependencies (dartz, equatable only)
- ✅ Contains abstract classes and interfaces
- ✅ Independent of other layers
- ✅ Framework-agnostic (no Riverpod, no GetX)

#### Entities

**Purpose**: Represent core business objects

**File**: `lib/features/counter/domain/entities/counter.dart`

```dart
import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final int value;

  const Counter({required this.value});

  @override
  List<Object?> get props => [value];
}
```

#### Use Cases

**Purpose**: Encapsulate a single business operation

**Base Class**: `lib/core/usecases/usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

**Example**: `lib/features/counter/domain/usecases/increment_counter.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

class IncrementCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;

  IncrementCounter(this.repository);

  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (current) async {
        final incremented = Counter(value: current.value + 1);
        return await repository.saveCounter(incremented);
      },
    );
  }
}
```

#### Repository Interfaces

**Purpose**: Define contracts for data access

**File**: `lib/features/counter/domain/repositories/counter_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/counter.dart';

abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Counter>> saveCounter(Counter counter);
}
```

---

### 2. Data Layer (Data Management)

**Location**: `lib/features/{feature}/data/`

**Responsibilities**:
- Implement repository interfaces
- Handle data sources (local storage, APIs)
- Convert between models and entities
- Handle JSON serialization

**Key Characteristics**:
- ✅ Depends only on Domain layer
- ✅ Implements repository interfaces from Domain
- ✅ Contains data source logic
- ✅ Handles JSON serialization
- ✅ Converts exceptions to Failures

#### Models

**Purpose**: Data transfer objects with serialization

**File**: `lib/features/counter/data/models/counter_model.dart`

```dart
import '../../domain/entities/counter.dart';

class CounterModel extends Counter {
  const CounterModel({required super.value});

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  Counter toEntity() => Counter(value: value);
  
  factory CounterModel.fromEntity(Counter counter) {
    return CounterModel(value: counter.value);
  }
}
```

#### Data Sources

**Purpose**: Interact with external data providers

**File**: `lib/features/counter/data/datasources/counter_local_datasource.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../models/counter_model.dart';

abstract class CounterLocalDataSource {
  Future<CounterModel> getCounter();
  Future<void> saveCounter(CounterModel counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl(this.sharedPreferences);

  static const String counterKey = 'COUNTER_KEY';

  @override
  Future<CounterModel> getCounter() async {
    final jsonString = sharedPreferences.getString(counterKey);
    if (jsonString != null) {
      return CounterModel.fromJson(json.decode(jsonString));
    } else {
      return const CounterModel(value: 0);
    }
  }

  @override
  Future<void> saveCounter(CounterModel counter) async {
    await sharedPreferences.setString(
      counterKey,
      json.encode(counter.toJson()),
    );
  }
}
```

#### Repository Implementation

**Purpose**: Implement domain repository interface

**File**: `lib/features/counter/data/repositories/counter_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';
import '../models/counter_model.dart';

class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  CounterRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final counterModel = await localDataSource.getCounter();
      return Right(counterModel.toEntity());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Counter>> saveCounter(Counter counter) async {
    try {
      final counterModel = CounterModel.fromEntity(counter);
      await localDataSource.saveCounter(counterModel);
      return Right(counter);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

---

### 3. Presentation Layer (UI & State)

**Location**: `lib/features/{feature}/presentation/`

**Responsibilities**:
- Display UI
- Manage state with Riverpod Providers
- Handle user interactions
- Call use cases

**Key Characteristics**:
- ✅ Depends only on Domain layer
- ✅ Uses Riverpod for state management
- ✅ Reactive UI with ConsumerWidget
- ✅ Dependency injection with Providers

#### Providers

**File**: `lib/features/counter/presentation/providers/counter_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../../../core/usecases/usecase.dart';

// State Notifier
class CounterNotifier extends StateNotifier<AsyncValue<Counter>> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;

  CounterNotifier({
    required this.getCounter,
    required this.incrementCounter,
  }) : super(const AsyncValue.loading()) {
    loadCounter();
  }

  Future<void> loadCounter() async {
    final result = await getCounter(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (counter) => AsyncValue.data(counter),
    );
  }

  Future<void> increment() async {
    final result = await incrementCounter(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (counter) => AsyncValue.data(counter),
    );
  }
}

// Provider Definition
final counterProvider = StateNotifierProvider<CounterNotifier, AsyncValue<Counter>>((ref) {
  // Dependencies are injected via the main ProviderScope overrides or global providers
  throw UnimplementedError('Provider was not initialized');
});
```

#### Views

**File**: `lib/features/counter/presentation/pages/counter_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: counterState.when(
          data: (counter) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                onPressed: () => ref.read(counterProvider.notifier).increment(),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
```

---

## Data Flow

### Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ USER ACTION (View)                                          │
│ - Button tap                                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ NOTIFIER (Presentation)                                     │
│ - ref.read(counterProvider.notifier).increment()            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ USE CASE (Domain)                                           │
│ - await incrementCounter(NoParams())                        │
│ - Returns Either<Failure, Counter>                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ REPOSITORY INTERFACE (Domain)                               │
│ - CounterRepository.saveCounter(counter)                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ REPOSITORY IMPLEMENTATION (Data)                            │
│ - Converts entity to model                                  │
│ - Calls data source                                         │
│ - Converts exceptions to Failures                           │
│ - Returns Either<Failure, Counter>                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ DATA SOURCE (Data)                                          │
│ - Saves to SharedPreferences                                │
│ - Throws exceptions on error                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (Return path)
┌─────────────────────────────────────────────────────────────┐
│ NOTIFIER EMITS NEW STATE                                    │
│ - state = AsyncValue.data(counter)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ VIEW REBUILDS (ConsumerWidget)                              │
│ - Displays new counter value                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependency Injection

### Using Riverpod Providers

**File**: `lib/main.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Define Providers for Dependencies
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final counterLocalDataSourceProvider = Provider<CounterLocalDataSource>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return CounterLocalDataSourceImpl(sharedPrefs);
});

final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  final localDataSource = ref.watch(counterLocalDataSourceProvider);
  return CounterRepositoryImpl(localDataSource);
});

final getCounterUseCaseProvider = Provider<GetCounter>((ref) {
  final repository = ref.watch(counterRepositoryProvider);
  return GetCounter(repository);
});

final incrementCounterUseCaseProvider = Provider<IncrementCounter>((ref) {
  final repository = ref.watch(counterRepositoryProvider);
  return IncrementCounter(repository);
});

// 2. Override in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        // Inject UseCases into the Notifier Provider
        counterProvider.overrideWith((ref) => CounterNotifier(
          getCounter: ref.watch(getCounterUseCaseProvider),
          incrementCounter: ref.watch(incrementCounterUseCaseProvider),
        )),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Error Handling

### Failures

**File**: `lib/core/error/failures.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}
```

---

## Testing Strategy

### Unit Tests (Use Cases)

```dart
test('should increment counter from repository', () async {
  // Arrange
  when(() => mockRepository.getCounter())
      .thenAnswer((_) async => const Right(Counter(value: 5)));
  when(() => mockRepository.saveCounter(any()))
      .thenAnswer((_) async => const Right(Counter(value: 6)));

  // Act
  final result = await useCase(NoParams());

  // Assert
  expect(result, const Right(Counter(value: 6)));
});
```

### Provider Tests

```dart
test('emits [AsyncData] when increment succeeds', () async {
  final container = ProviderContainer(
    overrides: [
      // Override dependencies with mocks
      getCounterUseCaseProvider.overrideWithValue(mockGetCounter),
      incrementCounterUseCaseProvider.overrideWithValue(mockIncrementCounter),
    ],
  );

  // Read the notifier
  final notifier = container.read(counterProvider.notifier);

  // Act
  await notifier.increment();

  // Assert
  expect(
    container.read(counterProvider),
    const AsyncValue.data(Counter(value: 1)),
  );
});
```

---

## Best Practices

1. ✅ **Keep Domain layer pure** - No Flutter, no Riverpod
2. ✅ **Use Providers for DI** - Chain providers for dependencies
3. ✅ **Test each layer independently** - Mock repositories/use cases
4. ✅ **Use Either for error handling** - Functional approach
5. ✅ **Single responsibility** - One use case per action
6. ✅ **Immutable entities** - const constructors, final fields
7. ✅ **Separate models from entities** - Models have serialization
8. ✅ **Repository pattern** - Abstract interfaces in domain
9. ✅ **StateNotifier in presentation** - Manage UI state
10. ✅ **AsyncValue** - Handle loading/error states gracefully

---

**Clean Architecture with Riverpod provides a robust, scalable, and testable foundation for Flutter apps!** 🚀
