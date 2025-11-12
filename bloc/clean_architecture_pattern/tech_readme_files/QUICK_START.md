# Clean Architecture - Quick Start Guide

## 🎯 What is Clean Architecture?

Clean Architecture is a software design philosophy by Robert C. Martin (Uncle Bob) that separates code into layers with strict dependency rules. The goal: **business logic independent of frameworks, UI, and databases**.

## 📦 Project Structure

```
lib/
├── core/                          # Shared utilities
│   ├── di/
│   │   └── injection_container.dart   # Dependency injection
│   ├── error/
│   │   ├── exceptions.dart            # Data layer exceptions
│   │   └── failures.dart              # Domain layer failures
│   └── usecases/
│       └── usecase.dart               # Base use case class
│
└── features/                      # Feature modules
    ├── counter/
    │   ├── domain/                # Business logic (pure Dart)
    │   │   ├── entities/
    │   │   │   └── counter.dart       # Counter entity
    │   │   ├── repositories/
    │   │   │   └── counter_repository.dart  # Repository interface
    │   │   └── usecases/
    │   │       ├── get_counter.dart
    │   │       ├── increment_counter.dart
    │   │       ├── decrement_counter.dart
    │   │       └── reset_counter.dart
    │   │
    │   ├── data/                  # Data management
    │   │   ├── models/
    │   │   │   └── counter_model.dart     # Model with JSON
    │   │   ├── datasources/
    │   │   │   └── counter_local_datasource.dart
    │   │   └── repositories/
    │   │       └── counter_repository_impl.dart
    │   │
    │   └── presentation/          # UI & State
    │       ├── cubit/
    │       │   ├── counter_cubit.dart
    │       │   └── counter_state.dart
    │       └── pages/
    │           └── counter_page.dart
    │
    └── notes/                     # Same structure for notes feature
        ├── domain/
        ├── data/
        └── presentation/
```

## 🚀 Quick Run

```bash
# Navigate to project
cd clean_architecture_pattern

# Get dependencies
flutter pub get

# Run app
flutter run -d chrome
# or
flutter run -d windows
# or
flutter run  # Your connected device
```

## 🏗️ Layer Breakdown

### 1. Domain Layer (Core Business)

**Location**: `lib/features/{feature}/domain/`

**Contains**:
- **Entities**: Pure data classes (Counter, Note)
- **Use Cases**: Single business operations (IncrementCounter, AddNote)
- **Repository Interfaces**: Contracts for data access

**Rules**:
- ✅ Pure Dart (no Flutter)
- ✅ No external dependencies (except dartz, equatable)
- ✅ Framework-agnostic
- ✅ No implementation details

**Example Entity**:
```dart
class Counter extends Equatable {
  final int value;
  const Counter({required this.value});
  
  @override
  List<Object?> get props => [value];
}
```

**Example Use Case**:
```dart
class IncrementCounter implements UseCase<Counter, NoParams> {
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

### 2. Data Layer (Data Management)

**Location**: `lib/features/{feature}/data/`

**Contains**:
- **Models**: Entities + JSON serialization
- **Data Sources**: Storage implementations (local/remote)
- **Repository Implementations**: Implement domain interfaces

**Rules**:
- ✅ Implements domain interfaces
- ✅ Handles JSON serialization
- ✅ Converts exceptions to Failures
- ✅ Framework-specific code allowed

**Example Model**:
```dart
class CounterModel extends Counter {
  const CounterModel({required super.value});

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  Map<String, dynamic> toJson() => {'value': value};
}
```

**Example Repository**:
```dart
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;
  
  CounterRepositoryImpl(this.localDataSource);
  
  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final model = await localDataSource.getCounter();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

### 3. Presentation Layer (UI & State)

**Location**: `lib/features/{feature}/presentation/`

**Contains**:
- **Cubits/BLoCs**: State management, calls use cases
- **States**: State classes (loading, loaded, error)
- **Pages/Widgets**: UI components

**Rules**:
- ✅ Depends only on domain layer
- ✅ Uses BLoC/Cubit for state
- ✅ Calls use cases (not repositories directly)

**Example Cubit**:
```dart
class CounterCubit extends Cubit<CounterState> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  
  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
  }) : super(CounterInitial());
  
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

**Example View**:
```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        if (state is CounterLoaded) {
          return Text('${state.counter.value}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 🔗 Dependency Flow

```
Presentation → Domain ← Data
     │            │        │
   Cubit      Use Cases  Repository
     │            │      Implementation
     │            │           │
     └────────────┼───────────┘
                  │
          Repository Interface
```

**Key Rule**: Dependencies point **inward** (toward domain)

## 🔧 Dependency Injection

### Using get_it

**Setup** (`lib/core/di/injection_container.dart`):
```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit (Factory - new instance each time)
  sl.registerFactory(() => CounterCubit(
    getCounter: sl(),
    incrementCounter: sl(),
  ));
  
  // Use Cases (Lazy Singleton)
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));
  
  // Repository (Lazy Singleton)
  sl.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(sl()),
  );
  
  // Data Source (Lazy Singleton)
  sl.registerLazySingleton<CounterLocalDataSource>(
    () => CounterLocalDataSourceImpl(sl()),
  );
  
  // External (SharedPreferences, etc.)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

**Usage**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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

## 📊 Data Flow Example

### Incrementing Counter

```
1. USER TAPS BUTTON
   ↓
2. View: context.read<CounterCubit>().increment()
   ↓
3. Cubit: await incrementCounter(NoParams())
   ↓
4. Use Case: 
   - Get current counter from repository
   - Increment value
   - Save to repository
   - Return Either<Failure, Counter>
   ↓
5. Repository (Data):
   - Convert entity to model
   - Call data source
   - Handle exceptions → Failures
   - Return Either<Failure, Counter>
   ↓
6. Data Source:
   - Save to SharedPreferences/HydratedStorage
   - Throw exception on error
   ↓
7. Cubit: emit(CounterLoaded(counter))
   ↓
8. View: BlocBuilder rebuilds with new value
```

## 🧪 Testing

### Unit Test (Use Case)

```dart
test('should increment counter', () async {
  // Arrange
  when(() => mockRepository.getCounter())
      .thenAnswer((_) async => Right(Counter(value: 5)));
  when(() => mockRepository.saveCounter(any()))
      .thenAnswer((_) async => Right(Counter(value: 6)));

  // Act
  final result = await useCase(NoParams());

  // Assert
  expect(result, Right(Counter(value: 6)));
});
```

### BLoC Test

```dart
blocTest<CounterCubit, CounterState>(
  'emits [Loading, Loaded] on increment',
  build: () {
    when(() => mockIncrement(NoParams()))
        .thenAnswer((_) async => Right(Counter(value: 1)));
    return CounterCubit(
      getCounter: mockGet,
      incrementCounter: mockIncrement,
    );
  },
  act: (cubit) => cubit.increment(),
  expect: () => [
    CounterLoading(),
    CounterLoaded(Counter(value: 1)),
  ],
);
```

## 📚 Key Packages

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Value equality
  dartz: ^0.10.1                # Functional programming (Either)
  get_it: ^7.6.0                # Dependency injection
  shared_preferences: ^2.2.2    # Local storage

dev_dependencies:
  bloc_test: ^9.1.5             # BLoC testing
  mocktail: ^1.0.0              # Mocking
```

## ✅ Benefits

| Benefit | Description |
|---------|-------------|
| **Testability** | Each layer tested independently |
| **Maintainability** | Clear structure, easy to navigate |
| **Scalability** | Add features without affecting others |
| **Flexibility** | Swap implementations (DB, API) easily |
| **Team Collaboration** | Different teams work on different layers |
| **Reusability** | Domain logic can be reused (web, desktop) |

## ⚠️ When to Use Clean Architecture

### ✅ Good For:
- Large applications
- Long-term projects
- Team projects
- Enterprise apps
- Apps with complex business logic
- Apps targeting multiple platforms

### ❌ Overkill For:
- Simple apps (counter, todo)
- Prototypes
- MVPs
- Learning Flutter basics

## 🎯 Quick Reference

### Adding a New Feature

1. **Create folders**: `domain/`, `data/`, `presentation/`
2. **Domain**: Entity → Repository interface → Use cases
3. **Data**: Model → Data source → Repository implementation
4. **Presentation**: State classes → Cubit → Page
5. **DI**: Register in `injection_container.dart`
6. **Test**: Unit test use cases, BLoC test cubit

### Error Handling

```dart
// Domain
abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Data
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

// Repository converts Exception → Failure
try {
  final result = await dataSource.getData();
  return Right(result);
} on CacheException catch (e) {
  return Left(CacheFailure(e.message));
}
```

---

**Clean Architecture ensures your Flutter app is robust, testable, and ready to scale! 🚀**

For deeper understanding, read:
- `ARCHITECTURE.md` - Detailed layer explanation
- `PROJECT_SUMMARY.md` - Complete project overview
