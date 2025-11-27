# Clean Architecture with Riverpod - Quick Start Guide

## 🎯 What is Clean Architecture?

Clean Architecture is a software design philosophy that separates code into layers with strict dependency rules. The goal: **business logic independent of frameworks, UI, and databases**.

## 📦 Project Structure

```
lib/
├── core/                          # Shared utilities
│   ├── error/                     # Failures & Exceptions
│   └── usecases/                  # Base UseCase class
│
└── features/                      # Feature modules
    ├── counter/
    │   ├── domain/                # Business logic (pure Dart)
    │   │   ├── entities/          # Data objects
    │   │   ├── repositories/      # Interfaces
    │   │   └── usecases/          # Business operations
    │   │
    │   ├── data/                  # Data management
    │   │   ├── models/            # JSON serialization
    │   │   ├── datasources/       # Local/Remote storage
    │   │   └── repositories/      # Implementation
    │   │
    │   └── presentation/          # UI & State
    │       ├── providers/         # Riverpod Notifiers
    │       └── pages/             # ConsumerWidgets
```

## 🚀 Quick Run

```bash
# Navigate to project
cd riverpod/clean_architeture_pattern

# Get dependencies
flutter pub get

# Run app
flutter run
```

## 🏗️ Layer Breakdown

### 1. Domain Layer (Core Business)

**Location**: `lib/features/{feature}/domain/`

**Contains**:
- **Entities**: Pure data classes (Counter, Note)
- **Use Cases**: Single business operations
- **Repository Interfaces**: Contracts for data access

**Rules**:
- ✅ Pure Dart (no Flutter, no Riverpod)
- ✅ Framework-agnostic

**Example Use Case**:
```dart
class IncrementCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;
  IncrementCounter(this.repository);
  
  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    // Logic to increment counter
  }
}
```

### 2. Data Layer (Data Management)

**Location**: `lib/features/{feature}/data/`

**Contains**:
- **Models**: Entities + JSON serialization
- **Data Sources**: Storage implementations
- **Repository Implementations**: Implement domain interfaces

**Rules**:
- ✅ Implements domain interfaces
- ✅ Handles JSON serialization

**Example Repository**:
```dart
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource dataSource;
  // ... implementation
}
```

### 3. Presentation Layer (UI & State)

**Location**: `lib/features/{feature}/presentation/`

**Contains**:
- **Providers**: StateNotifiers / Notifiers
- **Pages**: ConsumerWidgets

**Rules**:
- ✅ Depends only on domain layer
- ✅ Uses Riverpod for state
- ✅ Calls use cases

**Example Provider**:
```dart
final counterProvider = StateNotifierProvider<CounterNotifier, AsyncValue<Counter>>((ref) {
  return CounterNotifier(
    incrementCounter: ref.watch(incrementUseCaseProvider),
  );
});
```

**Example View**:
```dart
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterProvider);
    return state.when(
      data: (counter) => Text('${counter.value}'),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

## 🔗 Dependency Flow

```
Presentation → Domain ← Data
     │            │        │
  Notifier    Use Cases  Repository
     │            │      Implementation
     │            │           │
     └────────────┼───────────┘
                  │
          Repository Interface
```

## 🔧 Dependency Injection

### Using Riverpod

**Setup** (`lib/main.dart`):
```dart
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

## 📊 Data Flow Example

### Incrementing Counter

```
1. USER TAPS BUTTON
   ↓
2. View: ref.read(counterProvider.notifier).increment()
   ↓
3. Notifier: await incrementCounter(NoParams())
   ↓
4. Use Case: 
   - Get current -> Increment -> Save
   - Return Either<Failure, Counter>
   ↓
5. Repository (Data):
   - Convert entity to model -> Save to DataSource
   - Return Either<Failure, Counter>
   ↓
6. Notifier: state = AsyncValue.data(counter)
   ↓
7. View: ConsumerWidget rebuilds with new value
```

## 🧪 Testing

### Unit Test (Use Case)

```dart
test('should increment counter', () async {
  when(() => mockRepo.getCounter()).thenAnswer((_) async => Right(Counter(value: 5)));
  final result = await useCase(NoParams());
  expect(result, Right(Counter(value: 6)));
});
```

### Provider Test

```dart
test('emits AsyncData on increment', () async {
  final container = ProviderContainer(overrides: [ ... ]);
  await container.read(counterProvider.notifier).increment();
  expect(container.read(counterProvider), AsyncValue.data(Counter(value: 1)));
});
```

## 📚 Key Packages

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  equatable: ^2.0.5             # Value equality
  dartz: ^0.10.1                # Functional programming
  shared_preferences: ^2.2.2    # Local storage
```

## ✅ Benefits

| Benefit | Description |
|---------|-------------|
| **Testability** | Each layer tested independently |
| **Maintainability** | Clear structure, easy to navigate |
| **Scalability** | Add features without affecting others |
| **Flexibility** | Swap implementations easily |

---

**Clean Architecture ensures your Flutter app is robust, testable, and ready to scale! 🚀**
