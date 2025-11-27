# Clean Architecture with Riverpod - Project Summary

## 📋 Overview

This Counter & Notes application demonstrates **Clean Architecture** with **Riverpod** state management in Flutter. It serves as a reference implementation for building scalable, testable, and maintainable Flutter applications using modern Riverpod patterns.

## 🎯 What's Been Implemented

### Features
✅ Counter with increment/decrement/reset  
✅ Notes with add/delete/clear all  
✅ Data persistence (SharedPreferences)  
✅ Error handling with Either<Failure, Success>  
✅ Dependency injection with Riverpod Providers  
✅ Complete test coverage  
✅ Theme switching (light/dark)  

### Architecture Layers
✅ **Domain Layer** - Pure business logic (No Riverpod dependency)  
✅ **Data Layer** - Data management & storage  
✅ **Presentation Layer** - UI & state with Riverpod Notifiers  
✅ **Core** - Shared utilities  

## 📁 Complete Project Structure

```
lib/
│
├── core/                              # Shared across features
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
│   │   │       └── ...
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
│   │       ├── providers/
│   │       │   └── counter_provider.dart  # StateNotifier & Provider definition
│   │       ├── pages/
│   │       │   └── counter_page.dart      # Counter screen (ConsumerWidget)
│   │       └── widgets/
│   │           └── ...
│   │
│   ├── notes/                         # Notes Feature (same structure)
│   │   ├── domain/ ...
│   │   ├── data/ ...
│   │   └── presentation/ ...
│   │
│   └── theme/                         # Theme Feature
│       └── ...
│
└── main.dart                          # App entry point & ProviderScope
```

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│                                                              │
│  ┌────────────┐      ┌────────────┐      ┌────────────┐    │
│  │  Counter   │      │   Notes    │      │   Theme    │    │
│  │  Notifier  │      │  Notifier  │      │  Notifier  │    │
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
   └─ onPressed: () => ref.read(counterProvider.notifier).increment()

3. NOTIFIER (counter_provider.dart)
   ├─ state = AsyncValue.loading()
   └─ final result = await incrementCounter(NoParams())

4. USE CASE (increment_counter.dart)
   ├─ Calls: repository.getCounter()
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
   ├─ Saves to SharedPreferences
   └─ Throws CacheException on error

7. RETURN PATH
   ├─ Data Source → Repository (exception handling)
   ├─ Repository → Use Case (Either<Failure, Success>)
   ├─ Use Case → Notifier (Either<Failure, Success>)
   └─ Notifier processes result:
       • Success: state = AsyncValue.data(counter)
       • Failure: state = AsyncValue.error(failure)

8. VIEW UPDATES
   ├─ ref.watch(counterProvider) detects state change
   ├─ Rebuilds UI with new counter value
   └─ User sees updated counter
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  flutter_riverpod: ^2.4.9
  
  # Functional Programming
  dartz: ^0.10.1                  # Either, Option, etc.
  equatable: ^2.0.5               # Value equality
  
  # Local Storage
  shared_preferences: ^2.2.2      # Simple key-value

dev_dependencies:
  # Testing
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
| Presentation | UI & state | Domain & Riverpod |

### 3. Testability

```dart
// Domain (Unit Tests)
test('increment counter use case', () {
  // Test business logic without UI or storage
});

// Presentation (Provider Tests)
test('notifier emits correct states', () {
  // Test state management with mocked use cases
});

// Data (Repository Tests)
test('repository converts exceptions to failures', () {
  // Test data handling with mocked data sources
});
```

## 🔧 Dependency Injection Setup

### Provider Registration Pattern

```dart
// lib/main.dart

// 1. Define abstract providers (or throw UnimplementedError)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// 2. Define dependent providers
final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CounterRepositoryImpl(CounterLocalDataSourceImpl(prefs));
});

final incrementUseCaseProvider = Provider<IncrementCounter>((ref) {
  return IncrementCounter(ref.watch(counterRepositoryProvider));
});

// 3. Override in ProviderScope
void main() async {
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 📚 Code Examples

### Domain Entity (Pure Dart)

```dart
class Counter extends Equatable {
  final int value;
  const Counter({required this.value});
  @override
  List<Object?> get props => [value];
}
```

### Use Case Pattern

```dart
class IncrementCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;
  IncrementCounter(this.repository);
  
  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    // Business logic here
  }
}
```

### Riverpod Notifier

```dart
class CounterNotifier extends StateNotifier<AsyncValue<Counter>> {
  final IncrementCounter incrementCounter;
  
  CounterNotifier({required this.incrementCounter}) 
      : super(const AsyncValue.loading());
  
  Future<void> increment() async {
    final result = await incrementCounter(NoParams());
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (counter) => state = AsyncValue.data(counter),
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
| **Flexibility** | Swap storage easily |
| **Independence** | Business logic independent of Riverpod |

## 🚀 Quick Commands

```bash
# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📖 Documentation Files

- **`ARCHITECTURE.md`** - Detailed architecture explanation
- **`QUICK_START.md`** - Quick setup and running guide
- **`PROJECT_SUMMARY.md`** - This file, complete project overview

---

**This project demonstrates production-ready Clean Architecture with Riverpod in Flutter! 🚀**
