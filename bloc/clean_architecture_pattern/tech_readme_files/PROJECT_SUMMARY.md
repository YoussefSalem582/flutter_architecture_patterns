# Clean Architecture - Project Summary

## 📋 Overview

This Counter & Notes application demonstrates **Clean Architecture** with **BLoC** state management in Flutter. It's designed as a reference implementation for building scalable, testable, and maintainable Flutter applications.

## 🎯 What's Been Implemented

### Features
✅ Counter with increment/decrement/reset  
✅ Notes with add/delete/clear all  
✅ Data persistence (SharedPreferences / HydratedStorage)  
✅ Error handling with Either<Failure, Success>  
✅ Dependency injection with get_it  
✅ Complete test coverage  
✅ Theme switching (light/dark)  

### Architecture Layers
✅ **Domain Layer** - Pure business logic  
✅ **Data Layer** - Data management & storage  
✅ **Presentation Layer** - UI & state with BLoC  
✅ **Core** - Shared utilities & DI  

## 📁 Complete Project Structure

```
lib/
│
├── core/                              # Shared across features
│   ├── di/
│   │   └── injection_container.dart       # Dependency injection setup
│   ├── error/
│   │   ├── exceptions.dart                # Data layer exceptions
│   │   └── failures.dart                  # Domain layer failures
│   ├── usecases/
│   │   └── usecase.dart                   # Base use case interface
│   └── utils/
│       └── constants.dart                 # App constants
│
├── features/                          # Feature modules
│   │
│   ├── counter/                       # Counter Feature
│   │   │
│   │   ├── domain/                    # Business logic (pure Dart)
│   │   │   ├── entities/
│   │   │   │   └── counter.dart           # Counter entity (immutable)
│   │   │   ├── repositories/
│   │   │   │   └── counter_repository.dart  # Repository contract
│   │   │   └── usecases/
│   │   │       ├── get_counter.dart       # Retrieve counter
│   │   │       ├── increment_counter.dart  # Increment counter
│   │   │       ├── decrement_counter.dart  # Decrement counter
│   │   │       └── reset_counter.dart      # Reset counter
│   │   │
│   │   ├── data/                      # Data management
│   │   │   ├── models/
│   │   │   │   └── counter_model.dart     # Model with JSON serialization
│   │   │   ├── datasources/
│   │   │   │   └── counter_local_datasource.dart  # Local storage
│   │   │   └── repositories/
│   │   │       └── counter_repository_impl.dart   # Repository implementation
│   │   │
│   │   └── presentation/              # UI & State
│   │       ├── cubit/
│   │       │   ├── counter_cubit.dart     # State management
│   │       │   └── counter_state.dart     # State classes
│   │       ├── pages/
│   │       │   └── counter_page.dart      # Counter screen
│   │       └── widgets/
│   │           ├── counter_display.dart   # Counter value display
│   │           └── counter_controls.dart  # Increment/decrement buttons
│   │
│   ├── notes/                         # Notes Feature (same structure)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── note.dart
│   │   │   ├── repositories/
│   │   │   │   └── notes_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_notes.dart
│   │   │       ├── add_note.dart
│   │   │       ├── delete_note.dart
│   │   │       └── clear_all_notes.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── note_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── notes_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── notes_repository_impl.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── notes_cubit.dart
│   │       │   └── notes_state.dart
│   │       ├── pages/
│   │       │   └── notes_page.dart
│   │       └── widgets/
│   │           ├── notes_list.dart
│   │           ├── note_item.dart
│   │           └── add_note_field.dart
│   │
│   └── theme/                         # Theme Feature
│       ├── domain/
│       │   └── usecases/
│       │       └── toggle_theme.dart
│       ├── data/
│       │   └── repositories/
│       │       └── theme_repository_impl.dart
│       └── presentation/
│           ├── cubit/
│           │   └── theme_cubit.dart
│           └── widgets/
│               └── theme_toggle_button.dart
│
└── main.dart                          # App entry point
```

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│                                                              │
│  ┌────────────┐      ┌────────────┐      ┌────────────┐    │
│  │  Counter   │      │   Notes    │      │   Theme    │    │
│  │   Cubit    │      │   Cubit    │      │   Cubit    │    │
│  └──────┬─────┘      └──────┬─────┘      └──────┬─────┘    │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│                  ┌──────────▼──────────┐                    │
│                  │     Use Cases       │                    │
│                  │  (Business Logic)   │                    │
│                  └──────────┬──────────┘                    │
└─────────────────────────────┼────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────┐
│                       DOMAIN LAYER                           │
│                      (Pure Dart)                             │
│                                                              │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐    │
│  │   Counter    │   │     Note     │   │  Repository  │    │
│  │   Entity     │   │   Entity     │   │  Interfaces  │    │
│  └──────────────┘   └──────────────┘   └──────┬───────┘    │
│                                                │             │
└────────────────────────────────────────────────┼─────────────┘
                                                 │
┌────────────────────────────────────────────────▼─────────────┐
│                        DATA LAYER                            │
│                                                              │
│  ┌────────────────┐         ┌────────────────┐             │
│  │  Repository    │◄────────┤  Data Sources  │             │
│  │ Implementation │         │  (Local/API)   │             │
│  └────────┬───────┘         └────────────────┘             │
│           │                                                 │
│  ┌────────▼───────┐                                        │
│  │     Models     │ (with JSON serialization)             │
│  └────────────────┘                                        │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Complete Data Flow

### Example: Incrementing Counter

```
1. USER ACTION
   └─ User taps increment button

2. VIEW (counter_page.dart)
   └─ onPressed: () => context.read<CounterCubit>().increment()

3. CUBIT (counter_cubit.dart)
   ├─ emit(CounterLoading())
   └─ final result = await incrementCounter(NoParams())

4. USE CASE (increment_counter.dart)
   ├─ Calls: repository.getCounter() → get current value
   ├─ Business logic: Counter(value: current.value + 1)
   ├─ Calls: repository.saveCounter(incremented)
   └─ Returns: Either<Failure, Counter>

5. REPOSITORY (counter_repository_impl.dart)
   ├─ Converts entity → model
   ├─ Calls: localDataSource.saveCounter(model)
   ├─ Catches exceptions → converts to Failures
   └─ Returns: Either<Failure, Counter>

6. DATA SOURCE (counter_local_datasource.dart)
   ├─ Converts model → JSON
   ├─ Saves to SharedPreferences/HydratedStorage
   └─ Throws CacheException on error

7. RETURN PATH
   ├─ Data Source → Repository (exception handling)
   ├─ Repository → Use Case (Either<Failure, Success>)
   ├─ Use Case → Cubit (Either<Failure, Success>)
   └─ Cubit processes result:
       • Success: emit(CounterLoaded(counter))
       • Failure: emit(CounterError(failure.message))

8. VIEW UPDATES
   ├─ BlocBuilder detects state change
   ├─ Rebuilds UI with new counter value
   └─ User sees updated counter
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Functional Programming
  dartz: ^0.10.1                  # Either, Option, etc.
  
  # Dependency Injection
  get_it: ^7.6.0                  # Service locator
  
  # Local Storage
  shared_preferences: ^2.2.2      # Simple key-value
  # OR
  hydrated_bloc: ^9.1.2           # BLoC-specific storage
  path_provider: ^2.1.1           # Storage paths

dev_dependencies:
  # Testing
  bloc_test: ^9.1.5               # BLoC testing utilities
  mocktail: ^1.0.0                # Mocking
  flutter_test:
    sdk: flutter
```

## 🎯 Clean Architecture Principles Applied

### 1. Dependency Rule
```
Presentation → Domain ← Data
```
- Domain is independent (pure Dart)
- Data implements domain interfaces
- Presentation uses domain use cases

### 2. Separation of Concerns

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| Domain | Business logic | None (pure Dart) |
| Data | Data management | Domain only |
| Presentation | UI & state | Domain only |

### 3. Testability

```dart
// Domain (Unit Tests)
test('increment counter use case', () {
  // Test business logic without UI or storage
});

// Presentation (BLoC Tests)
blocTest('cubit emits correct states', () {
  // Test state management with mocked use cases
});

// Data (Repository Tests)
test('repository converts exceptions to failures', () {
  // Test data handling with mocked data sources
});
```

### 4. Independence

- ✅ Business logic doesn't know about Flutter
- ✅ Business logic doesn't know about BLoC
- ✅ Business logic doesn't know about storage mechanism
- ✅ Easy to change: UI framework, state management, database

## 🧪 Testing Strategy

### Test Pyramid

```
        ┌─────────┐
        │   E2E   │  ← Integration tests (few)
        ├─────────┤
        │ Widget  │  ← Widget tests (some)
        ├─────────┤
        │  Unit   │  ← Unit tests (many)
        └─────────┘
```

### Coverage by Layer

```dart
// 1. Domain Layer (High Priority)
// - Use case unit tests
// - Entity tests
test('increment counter from 5 to 6', () {
  // Arrange
  when(() => mockRepo.getCounter()).thenAnswer(
    (_) async => Right(Counter(value: 5))
  );
  // Act & Assert
  final result = await incrementCounter(NoParams());
  expect(result, Right(Counter(value: 6)));
});

// 2. Presentation Layer (Medium Priority)
// - Cubit/BLoC tests
blocTest<CounterCubit, CounterState>(
  'emits [Loading, Loaded] on success',
  build: () => CounterCubit(mockIncrement),
  act: (cubit) => cubit.increment(),
  expect: () => [CounterLoading(), CounterLoaded(Counter(value: 1))],
);

// 3. Data Layer (Medium Priority)
// - Repository implementation tests
// - Data source tests
test('repository returns failure on cache exception', () async {
  when(() => mockDataSource.getCounter()).thenThrow(CacheException());
  final result = await repository.getCounter();
  expect(result, Left(CacheFailure()));
});

// 4. Widget Tests (Low Priority)
// - Critical user flows only
testWidgets('tapping increment updates counter', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  expect(find.text('1'), findsOneWidget);
});
```

## 🔧 Dependency Injection Setup

### Registration Pattern

```dart
// lib/core/di/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // ========== Features - Counter ==========
  
  // Presentation (Factory - new each time)
  sl.registerFactory(() => CounterCubit(
    getCounter: sl(),
    incrementCounter: sl(),
    decrementCounter: sl(),
    resetCounter: sl(),
  ));
  
  // Domain - Use Cases (Singleton)
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));
  sl.registerLazySingleton(() => DecrementCounter(sl()));
  sl.registerLazySingleton(() => ResetCounter(sl()));
  
  // Domain - Repository Interface → Data Implementation (Singleton)
  sl.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(localDataSource: sl()),
  );
  
  // Data - Data Source (Singleton)
  sl.registerLazySingleton<CounterLocalDataSource>(
    () => CounterLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // ========== Features - Notes ========== 
  // (Similar structure)
  
  // ========== Core - External ==========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

## 📚 Code Examples

### Domain Entity (Pure Dart)

```dart
import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final int value;
  
  const Counter({required this.value});
  
  // Business logic methods (optional)
  Counter increment() => Counter(value: value + 1);
  Counter decrement() => Counter(value: value - 1);
  Counter reset() => const Counter(value: 0);
  
  @override
  List<Object?> get props => [value];
}
```

### Use Case Pattern

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class IncrementCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;
  
  IncrementCounter(this.repository);
  
  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    final current = await repository.getCounter();
    
    return current.fold(
      (failure) => Left(failure),
      (counter) => repository.saveCounter(counter.increment()),
    );
  }
}
```

### Repository Pattern

```dart
// Domain (Interface)
abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Counter>> saveCounter(Counter counter);
}

// Data (Implementation)
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;
  
  CounterRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final model = await localDataSource.getCounter();
      return Right(model); // Model extends Counter entity
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

### BLoC/Cubit Pattern

```dart
class CounterCubit extends Cubit<CounterState> {
  final IncrementCounter incrementCounter;
  
  CounterCubit({required this.incrementCounter}) : super(CounterInitial());
  
  Future<void> increment() async {
    emit(CounterLoading());
    
    final result = await incrementCounter(NoParams());
    
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }
}
```

## ✅ Benefits Demonstrated

| Benefit | How It's Achieved |
|---------|-------------------|
| **Testability** | Each layer tested independently with mocks |
| **Maintainability** | Clear structure, easy to find code |
| **Scalability** | Add features without touching existing code |
| **Flexibility** | Swap storage (SharedPrefs ↔ Hive ↔ SQLite) easily |
| **Team Work** | Different teams work on different layers |
| **Reusability** | Domain logic reusable across platforms |
| **Independence** | Business logic independent of frameworks |

## 🚀 Quick Commands

```bash
# Run app
flutter run -d chrome

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Generate coverage report (HTML)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📖 Documentation Files

- **`ARCHITECTURE.md`** - Detailed architecture explanation, layer-by-layer
- **`QUICK_START.md`** - Quick setup and running guide
- **`PROJECT_SUMMARY.md`** - This file, complete project overview

---

## 🎓 Learning Outcomes

After studying this project, you'll understand:

1. ✅ How to structure a Flutter app with Clean Architecture
2. ✅ How to separate business logic from UI and data
3. ✅ How to use BLoC with Clean Architecture
4. ✅ How to implement repository pattern
5. ✅ How to use dependency injection with get_it
6. ✅ How to handle errors functionally with Either
7. ✅ How to write testable code
8. ✅ How to organize large Flutter projects

---

**This project demonstrates production-ready Clean Architecture with BLoC in Flutter! 🚀**

Perfect for:
- Learning Clean Architecture
- Reference for new projects
- Team training
- Architectural discussions
- Interview preparation
