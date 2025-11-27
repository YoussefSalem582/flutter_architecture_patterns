# Domain-Driven Design (DDD) with Riverpod - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Layer Details](#layer-details)
3. [Data Flow](#data-flow)
4. [Dependency Injection](#dependency-injection)
5. [Error Handling](#error-handling)
6. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

### The DDD Principle

Domain-Driven Design (DDD) focuses on the core domain logic and domain model. In this architecture, we organize the project into four main layers:

```
┌───────────────────────────────────────────────────────────┐
│                    Presentation Layer                      │
│         (UI, Widgets, Riverpod Providers)                 │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Application Layer                      │  │
│  │      (Application Services / Notifiers)             │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │              Domain Layer                     │  │  │
│  │  │      (Entities, Value Objects, Failures)      │  │  │
│  │  │      (Repository Interfaces)                  │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Infrastructure Layer                   │  │
│  │  - Repository Implementations                       │  │
│  │  - Data Transfer Objects (DTOs)                     │  │
│  │  - Data Sources (API, DB)                           │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Dependency Direction

```
Presentation → Application → Domain ← Infrastructure
```
*   **Domain** is the core and depends on nothing.
*   **Application** orchestrates the domain logic.
*   **Infrastructure** implements the interfaces defined in Domain.
*   **Presentation** interacts with Application.

---

## Layer Details

### 1. Domain Layer (The Heart)

**Location**: `lib/domain/`

**Responsibilities**:
- Define **Entities** (Mutable/Immutable business objects with identity).
- Define **Value Objects** (Immutable objects defined by attributes).
- Define **Repository Interfaces** (Contracts for data persistence).
- Define **Failures** (Domain errors).

**Key Characteristics**:
- ✅ Pure Dart.
- ✅ No dependencies on Flutter, Riverpod, or Data sources.
- ✅ Contains business rules and logic.

**Example Entity**: `lib/domain/counter/counter.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter.freezed.dart';

@freezed
class Counter with _$Counter {
  const factory Counter({
    required int value,
  }) = _Counter;
  
  // Domain logic can go here
  const Counter._();
  
  Counter increment() => copyWith(value: value + 1);
}
```

**Example Repository Interface**: `lib/domain/counter/i_counter_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import 'counter.dart';

abstract class ICounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Unit>> saveCounter(Counter counter);
}
```

### 2. Infrastructure Layer (The Implementation)

**Location**: `lib/infrastructure/`

**Responsibilities**:
- Implement Repository Interfaces.
- Define **DTOs** (Data Transfer Objects) for serialization.
- Handle external data sources (APIs, Local Storage).

**Key Characteristics**:
- ✅ Depends on Domain.
- ✅ Handles JSON conversion.
- ✅ Catches exceptions and maps them to Domain Failures.

**Example DTO**: `lib/infrastructure/counter/counter_dtos.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/counter/counter.dart';

part 'counter_dtos.freezed.dart';
part 'counter_dtos.g.dart';

@freezed
class CounterDto with _$CounterDto {
  const factory CounterDto({
    required int value,
  }) = _CounterDto;

  factory CounterDto.fromDomain(Counter counter) {
    return CounterDto(value: counter.value);
  }

  factory CounterDto.fromJson(Map<String, dynamic> json) =>
      _$CounterDtoFromJson(json);
      
  const CounterDto._();
  
  Counter toDomain() => Counter(value: value);
}
```

**Example Repository Implementation**: `lib/infrastructure/counter/counter_repository.dart`
```dart
class CounterRepository implements ICounterRepository {
  final SharedPreferences _prefs;
  
  CounterRepository(this._prefs);

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      // ... implementation using DTOs
    } catch (e) {
      return left(const Failure.cacheError());
    }
  }
}
```

### 3. Application Layer (The Orchestrator)

**Location**: `lib/application/`

**Responsibilities**:
- Coordinate the application activity.
- Bridge between Presentation and Domain.
- Often implemented as **StateNotifiers** in Riverpod.

**Key Characteristics**:
- ✅ Depends on Domain and Repository Interfaces.
- ✅ Does NOT depend on Infrastructure details.
- ✅ Manages state for the UI.

**Example Notifier**: `lib/application/counter/counter_notifier.dart`
```dart
class CounterNotifier extends StateNotifier<AsyncValue<Counter>> {
  final ICounterRepository _repository;

  CounterNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> increment() async {
    state.whenData((counter) async {
      final newCounter = counter.increment(); // Domain logic
      final result = await _repository.saveCounter(newCounter);
      
      result.fold(
        (f) => state = AsyncValue.error(f, StackTrace.current),
        (_) => state = AsyncValue.data(newCounter),
      );
    });
  }
}
```

### 4. Presentation Layer (The UI)

**Location**: `lib/presentation/`

**Responsibilities**:
- Render the UI.
- Listen to Application Layer state changes.
- Dispatch user events to Application Layer.

**Key Characteristics**:
- ✅ Uses `ConsumerWidget` / `ConsumerStatefulWidget`.
- ✅ Watches Providers.

---

## Data Flow

```
1. User Interaction (Presentation)
   ↓
2. Call Application Service/Notifier (Application)
   ↓
3. Execute Domain Logic (Domain Entity)
   ↓
4. Call Repository Interface (Domain)
   ↓
5. Repository Implementation (Infrastructure)
   ↓
6. Convert Domain -> DTO -> JSON (Infrastructure)
   ↓
7. Save to Data Source (Infrastructure)
   ↓
8. Return Result (Either<Failure, Unit>)
   ↓
9. Update State (Application)
   ↓
10. Rebuild UI (Presentation)
```

---

## Dependency Injection

We use **Riverpod** for DI.

**File**: `lib/presentation/core/providers.dart` (or similar)

```dart
// Infrastructure Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final counterRepositoryProvider = Provider<ICounterRepository>((ref) {
  return CounterRepository(ref.watch(sharedPreferencesProvider));
});

// Application Providers
final counterNotifierProvider = StateNotifierProvider<CounterNotifier, AsyncValue<Counter>>((ref) {
  return CounterNotifier(ref.watch(counterRepositoryProvider));
});
```

---

## Error Handling

We use `dartz`'s `Either<L, R>` type for functional error handling.
- **Left (L)**: Failure (Domain Error)
- **Right (R)**: Success (Value or Unit)

Exceptions in the Infrastructure layer are caught and converted into `Failure` objects defined in the Domain layer.

---

## Testing Strategy

1.  **Domain**: Unit test Entities and Value Objects.
2.  **Application**: Unit test Notifiers by mocking Repository Interfaces.
3.  **Infrastructure**: Integration test Repositories with real/mocked data sources.
4.  **Presentation**: Widget test UI components.

---

**DDD with Riverpod allows for rich domain modeling and clear separation of technical concerns!**
