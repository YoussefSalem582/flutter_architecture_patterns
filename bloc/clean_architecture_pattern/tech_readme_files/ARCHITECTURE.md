# Clean Architecture with BLoC - Technical Documentation

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
│         (BLoC/Cubit + Views)                              │
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
  BLoC uses UseCases
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
- ✅ Framework-agnostic (no BLoC, no GetX)

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

**File**: `lib/features/notes/domain/entities/note.dart`

```dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;

  const Note({
    required this.id,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, content, timestamp];
}
```

**Key Points**:
- Immutable (final fields, const constructors)
- Extend Equatable for value equality
- No JSON serialization (that's in Data layer)
- Pure business logic only

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
    // Get current counter
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      // If error getting counter, return failure
      (failure) => Left(failure),
      // If success, increment and save
      (current) async {
        final incremented = Counter(value: current.value + 1);
        return await repository.saveCounter(incremented);
      },
    );
  }
}
```

**More Examples**:

```dart
// lib/features/counter/domain/usecases/get_counter.dart
class GetCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;
  
  GetCounter(this.repository);
  
  @override
  Future<Either<Failure, Counter>> call(NoParams params) {
    return repository.getCounter();
  }
}

// lib/features/notes/domain/usecases/add_note.dart
class AddNote implements UseCase<Note, AddNoteParams> {
  final NotesRepository repository;
  
  AddNote(this.repository);
  
  @override
  Future<Either<Failure, Note>> call(AddNoteParams params) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: params.content,
      timestamp: DateTime.now(),
    );
    
    return await repository.addNote(note);
  }
}

class AddNoteParams {
  final String content;
  
  AddNoteParams({required this.content});
}
```

**Key Points**:
- Single responsibility (one action per use case)
- Depend only on repository interfaces (not implementations)
- Return `Either<Failure, Success>` for functional error handling
- Accept parameters through `Params` classes
- No direct state management (BLoC is separate)

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

**File**: `lib/features/notes/domain/repositories/notes_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Note>> addNote(Note note);
  Future<Either<Failure, Unit>> deleteNote(String id);
  Future<Either<Failure, Unit>> clearAllNotes();
}
```

**Key Points**:
- Abstract class (no implementation)
- Define method signatures only
- Return types use Either<Failure, Success>
- Use dartz `Unit` for void operations

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

**File**: `lib/features/notes/data/models/note_model.dart`

```dart
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.content,
    required super.timestamp,
  });

  // JSON serialization
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Entity conversion
  Note toEntity() => Note(id: id, content: content, timestamp: timestamp);
  
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      content: note.content,
      timestamp: note.timestamp,
    );
  }
}
```

**Key Points**:
- Extends domain entity (inherits fields)
- Adds serialization methods (fromJson, toJson)
- Provides entity conversion methods
- Keeps domain entities clean

#### Data Sources

**Purpose**: Interact with external data providers

**File**: `lib/features/counter/data/datasources/counter_local_datasource.dart`

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/counter_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class CounterLocalDataSource {
  Future<CounterModel> getCounter();
  Future<void> saveCounter(CounterModel counter);
}

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final HydratedStorage storage;

  CounterLocalDataSourceImpl(this.storage);

  @override
  Future<CounterModel> getCounter() async {
    try {
      final data = await storage.read('counter');
      
      if (data == null) {
        return const CounterModel(value: 0);
      }
      
      return CounterModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to read counter from storage');
    }
  }

  @override
  Future<void> saveCounter(CounterModel counter) async {
    try {
      await storage.write('counter', counter.toJson());
    } catch (e) {
      throw CacheException('Failed to save counter to storage');
    }
  }
}
```

**Alternative - Shared Preferences:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  final SharedPreferences sharedPreferences;

  CounterLocalDataSourceImpl(this.sharedPreferences);

  static const String counterKey = 'COUNTER_KEY';

  @override
  Future<CounterModel> getCounter() async {
    try {
      final jsonString = sharedPreferences.getString(counterKey);
      
      if (jsonString == null) {
        return const CounterModel(value: 0);
      }
      
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return CounterModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to read counter');
    }
  }

  @override
  Future<void> saveCounter(CounterModel counter) async {
    try {
      final jsonString = json.encode(counter.toJson());
      await sharedPreferences.setString(counterKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save counter');
    }
  }
}
```

**Key Points**:
- Abstract interface + implementation
- Single responsibility (one data source per storage type)
- Throw exceptions (not Either) - repository handles conversion
- Use constants for storage keys
- No business logic

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
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Counter>> saveCounter(Counter counter) async {
    try {
      final counterModel = CounterModel.fromEntity(counter);
      await localDataSource.saveCounter(counterModel);
      return Right(counter);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error occurred'));
    }
  }
}
```

**Key Points**:
- Implements domain repository interface
- Depends on data source interface (not implementation)
- Converts exceptions to Either<Failure, Success>
- Converts models to entities
- Error handling with try-catch

---

### 3. Presentation Layer (UI & State)

**Location**: `lib/features/{feature}/presentation/`

**Responsibilities**:
- Display UI
- Manage state with BLoC/Cubit
- Handle user interactions
- Call use cases

**Key Characteristics**:
- ✅ Depends only on Domain layer
- ✅ Uses BLoC/Cubit for state management
- ✅ Reactive UI with BlocBuilder
- ✅ Dependency injection with BlocProvider

#### BLoC/Cubit State Classes

**File**: `lib/features/counter/presentation/cubit/counter_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/counter.dart';

abstract class CounterState extends Equatable {
  const CounterState();
  
  @override
  List<Object?> get props => [];
}

class CounterInitial extends CounterState {}

class CounterLoading extends CounterState {}

class CounterLoaded extends CounterState {
  final Counter counter;
  
  const CounterLoaded(this.counter);
  
  @override
  List<Object?> get props => [counter];
}

class CounterError extends CounterState {
  final String message;
  
  const CounterError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

#### BLoC/Cubit

**File**: `lib/features/counter/presentation/cubit/counter_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/reset_counter.dart';
import 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;
  final ResetCounter resetCounter;

  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
    required this.resetCounter,
  }) : super(CounterInitial());

  Future<void> loadCounter() async {
    emit(CounterLoading());
    
    final result = await getCounter(NoParams());
    
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  Future<void> increment() async {
    final result = await incrementCounter(NoParams());
    
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  Future<void> decrement() async {
    final result = await decrementCounter(NoParams());
    
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  Future<void> reset() async {
    final result = await resetCounter(NoParams());
    
    result.fold(
      (failure) => emit(CounterError(failure.message)),
      (counter) => emit(CounterLoaded(counter)),
    );
  }
}
```

**Simplified Cubit (No State Classes)**:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';

class CounterCubit extends Cubit<Counter> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;

  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
  }) : super(const Counter(value: 0)) {
    loadCounter();
  }

  Future<void> loadCounter() async {
    final result = await getCounter(NoParams());
    result.fold(
      (failure) => {}, // Handle error
      (counter) => emit(counter),
    );
  }

  Future<void> increment() async {
    final result = await incrementCounter(NoParams());
    result.fold(
      (failure) => {}, // Handle error
      (counter) => emit(counter),
    );
  }
}
```

#### Views

**File**: `lib/features/counter/presentation/pages/counter_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          if (state is CounterLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CounterError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is CounterLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.counter.value}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () => context.read<CounterCubit>().decrement(),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: () => context.read<CounterCubit>().increment(),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          
          return const Center(child: Text('Unknown state'));
        },
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
│ CUBIT (Presentation)                                        │
│ - context.read<CounterCubit>().increment()                  │
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
│ - Saves to HydratedStorage / SharedPreferences             │
│ - Throws exceptions on error                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (Return path)
┌─────────────────────────────────────────────────────────────┐
│ CUBIT EMITS NEW STATE                                       │
│ - emit(CounterLoaded(counter))                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ VIEW REBUILDS (BlocBuilder)                                 │
│ - Displays new counter value                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependency Injection

### Using get_it (Service Locator)

**File**: `lib/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/counter/data/datasources/counter_local_datasource.dart';
import '../../features/counter/data/repositories/counter_repository_impl.dart';
import '../../features/counter/domain/repositories/counter_repository.dart';
import '../../features/counter/domain/usecases/get_counter.dart';
import '../../features/counter/domain/usecases/increment_counter.dart';
import '../../features/counter/presentation/cubit/counter_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== Features - Counter ==========
  
  // Cubit
  sl.registerFactory(
    () => CounterCubit(
      getCounter: sl(),
      incrementCounter: sl(),
      decrementCounter: sl(),
      resetCounter: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));
  sl.registerLazySingleton(() => DecrementCounter(sl()));
  sl.registerLazySingleton(() => ResetCounter(sl()));
  
  // Repository
  sl.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(sl()),
  );
  
  // Data Source
  sl.registerLazySingleton<CounterLocalDataSource>(
    () => CounterLocalDataSourceImpl(sl()),
  );
  
  // ========== Core ==========
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  final hydratedStorage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  sl.registerLazySingleton(() => hydratedStorage);
}
```

**Usage in main.dart**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.init(); // Initialize dependencies
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => di.sl<CounterCubit>()..loadCounter(),
        child: const CounterPage(),
      ),
    );
  }
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
  const CacheFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

### Exceptions

**File**: `lib/core/error/exceptions.dart`

```dart
class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
}

class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
}
```

---

## Testing Strategy

### Unit Tests (Use Cases)

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late IncrementCounter useCase;
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
    useCase = IncrementCounter(mockRepository);
  });

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
    verify(() => mockRepository.getCounter());
    verify(() => mockRepository.saveCounter(const Counter(value: 6)));
  });
}
```

### BLoC Tests

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  late CounterCubit cubit;
  late MockGetCounter mockGetCounter;
  late MockIncrementCounter mockIncrementCounter;

  setUp(() {
    mockGetCounter = MockGetCounter();
    mockIncrementCounter = MockIncrementCounter();
    cubit = CounterCubit(
      getCounter: mockGetCounter,
      incrementCounter: mockIncrementCounter,
    );
  });

  blocTest<CounterCubit, CounterState>(
    'emits [CounterLoading, CounterLoaded] when increment succeeds',
    build: () {
      when(() => mockIncrementCounter(NoParams()))
          .thenAnswer((_) async => const Right(Counter(value: 1)));
      return cubit;
    },
    act: (cubit) => cubit.increment(),
    expect: () => [
      isA<CounterLoading>(),
      const CounterLoaded(Counter(value: 1)),
    ],
  );
}
```

---

## Best Practices

1. ✅ **Keep Domain layer pure** - No Flutter, no frameworks
2. ✅ **Use dependency injection** - get_it or provider
3. ✅ **Test each layer independently** - Mock dependencies
4. ✅ **Use Either for error handling** - Functional approach with dartz
5. ✅ **Single responsibility** - One use case per action
6. ✅ **Immutable entities** - const constructors, final fields
7. ✅ **Separate models from entities** - Models have serialization
8. ✅ **Repository pattern** - Abstract interfaces in domain
9. ✅ **BLoC/Cubit in presentation** - Don't put BLoC in domain
10. ✅ **Clear folder structure** - features/{feature}/domain|data|presentation

---

**Clean Architecture with BLoC provides the most robust, testable, and maintainable Flutter applications!** 🚀
