# MVVM Architecture Pattern with BLoC/Cubit

## Overview

This project demonstrates the MVVM (Model-View-ViewModel) architecture pattern in Flutter using **BLoC/Cubit** for reactive state management.

## Architecture Components

### 1. Model Layer (`/models`)

**Purpose:** Represents the data structures and business entities.

**Characteristics:**
- Pure Dart classes with no Flutter dependencies
- Immutable data structures using `Equatable`
- Contains `toJson()` and `fromJson()` methods for serialization
- Implements `copyWith()` for creating modified copies
- No business logic, only data representation
- Equatable for value equality comparison

**Files:**
- `counter_model.dart` - Represents counter data
- `note_model.dart` - Represents note data with id, content, and timestamp

**Example:**
```dart
import 'package:equatable/equatable.dart';

class CounterModel extends Equatable {
  final int value;
  
  const CounterModel({required this.value});
  
  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }
  
  @override
  List<Object?> get props => [value];
}
```

---

### 2. ViewModel Layer (`/viewmodels` or `/cubits`)

**Purpose:** Contains business logic and reactive state management.

**Characteristics:**
- Extends `Cubit<State>` or `HydratedCubit<State>` from BLoC
- Uses `emit()` to update state reactively
- Contains business logic methods
- Communicates with Models
- Triggers UI updates automatically via state emissions
- No direct UI code or BuildContext
- Optional persistence with HydratedCubit

**Files:**
- `counter_cubit.dart` - Manages counter state and logic
- `notes_cubit.dart` - Manages notes list and operations
- `theme_cubit.dart` - Manages app theme

**Key Features:**
- **Reactive State:** Uses `emit()` to update state
- **Lifecycle:** Constructor for initialization, `close()` for cleanup
- **Business Logic:** All increment/decrement/add/delete logic lives here
- **State Updates:** Emitting new state automatically updates UI
- **Persistence:** HydratedCubit auto-persists state (optional)

**Example:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/counter_model.dart';

class CounterCubit extends Cubit<CounterModel> {
  // Initial state
  CounterCubit() : super(const CounterModel(value: 0));
  
  // Getters
  int get counterValue => state.value;
  
  // Business logic
  void increment() {
    emit(state.copyWith(value: state.value + 1));
  }
  
  void decrement() {
    emit(state.copyWith(value: state.value - 1));
  }
  
  void reset() {
    emit(const CounterModel(value: 0));
  }
}
```

**With Persistence:**
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/counter_model.dart';

class CounterCubit extends HydratedCubit<CounterModel> {
  CounterCubit() : super(const CounterModel(value: 0));
  
  void increment() {
    emit(state.copyWith(value: state.value + 1));
  }
  
  // Persistence methods
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

---

### 3. View Layer (`/views`)

**Purpose:** Displays UI and handles user interactions.

**Characteristics:**
- `StatelessWidget` (BLoC handles state)
- Uses `BlocBuilder` to observe reactive state
- Uses `BlocListener` for side effects (navigation, snackbars)
- Uses `context.read<Cubit>()` to call ViewModel methods
- No business logic - delegates to ViewModel (Cubit)
- Reacts to state changes

**Files:**
- `home_view.dart` - Landing page with navigation
- `counter_view.dart` - Counter UI
- `notes_view.dart` - Notes list UI

**Key Widgets:**
- `BlocBuilder<Cubit, State>` - Rebuilds on state change
- `BlocListener<Cubit, State>` - Side effects without rebuild
- `BlocConsumer<Cubit, State>` - Builder + Listener combined
- `context.read<Cubit>()` - Access cubit to call methods
- `context.watch<Cubit>()` - Watch state reactively

**Example:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/counter_cubit.dart';
import '../models/counter_model.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        // Rebuilds when CounterCubit emits new state
        child: BlocBuilder<CounterCubit, CounterModel>(
          builder: (context, counterModel) {
            return Text(
              '${counterModel.value}',
              style: Theme.of(context).textTheme.displayLarge,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Call cubit method
        onPressed: () => context.read<CounterCubit>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**With Side Effects:**
```dart
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NotesCubit, List<Note>>(
        // Listener for side effects (snackbars, dialogs)
        listener: (context, notes) {
          if (notes.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All notes cleared')),
            );
          }
        },
        // Builder for UI updates
        builder: (context, notes) {
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(notes[index].content),
            ),
          );
        },
      ),
    );
  }
}
```

---

### 4. Dependency Injection (in `main.dart`)

**Purpose:** Provides ViewModels (Cubits) to widget tree.

**Characteristics:**
- Uses `BlocProvider` to inject single cubit
- Uses `MultiBlocProvider` for multiple cubits
- Automatic disposal when widget is removed from tree
- Lazy creation (only when first accessed)

**Example:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HydratedBloc if using persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit()),
        BlocProvider(create: (_) => NotesCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            themeMode: themeMode,
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
```

---

### 5. Routes (Optional - Standard Flutter Navigation)

**Purpose:** Navigation configuration.

**Standard Approach:**
```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeView(),
    '/counter': (context) => const CounterView(),
    '/notes': (context) => const NotesView(),
  },
)

// Navigate
Navigator.pushNamed(context, '/counter');
```

**With go_router (Recommended for large apps):**
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/counter',
      builder: (context, state) => const CounterView(),
    ),
  ],
);

MaterialApp.router(
  routerConfig: router,
)
```

---

### 6. Config (`/config`)

**Purpose:** Application-wide configuration.

**Files:**
- `app_themes.dart` - Light and dark theme definitions

**Example:**
```dart
class AppThemes {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  
  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
```

---

## Data Flow

```
┌──────────────────────────────────────────────────────┐
│ 1. User Interaction (View)                           │
│    - Button tap, text input, etc.                    │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 2. Call Cubit Method via context.read()              │
│    - context.read<CounterCubit>().increment()         │
│    - context.read<NotesCubit>().addNote(text)         │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 3. Cubit Updates State with emit()                   │
│    - emit(newCounterModel)                            │
│    - emit([...state, newNote])                        │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 4. BLoC Notifies Listeners                           │
│    - Automatic change detection                       │
│    - HydratedCubit auto-saves (if enabled)           │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 5. UI Updates (BlocBuilder rebuilds)                 │
│    - Only BlocBuilder widgets rebuild               │
│    - BlocListener triggers side effects             │
└──────────────────────────────────────────────────────┘
```

---

## Key BLoC Features Used

### 1. Reactive State Management

**Cubit (Simple BLoC):**
```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);  // Initial state
  
  void increment() => emit(state + 1);  // Emit new state
  void decrement() => emit(state - 1);
}
```

**HydratedCubit (With Persistence):**
```dart
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'];
  
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}
```

### 2. UI Updates

**BlocBuilder (Rebuild on State Change):**
```dart
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)
```

**BlocListener (Side Effects):**
```dart
BlocListener<CounterCubit, int>(
  listener: (context, count) {
    if (count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  child: MyWidget(),
)
```

**BlocConsumer (Builder + Listener):**
```dart
BlocConsumer<CounterCubit, int>(
  listener: (context, count) {
    // Side effects
  },
  builder: (context, count) {
    // UI
    return Text('$count');
  },
)
```

### 3. Accessing Cubits

**Read (Call methods, no rebuild):**
```dart
context.read<CounterCubit>().increment();
```

**Watch (Access state, triggers rebuild):**
```dart
final count = context.watch<CounterCubit>().state;
```

**Select (Watch specific property):**
```dart
final value = context.select((CounterCubit cubit) => cubit.state.value);
```

### 4. Dependency Injection

**Single Provider:**
```dart
BlocProvider(
  create: (context) => CounterCubit(),
  child: CounterView(),
)
```

**Multiple Providers:**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => CounterCubit()),
    BlocProvider(create: (_) => NotesCubit()),
  ],
  child: MyApp(),
)
```

### 5. Theme Management

```dart
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);
  
  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
  
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == json['theme'],
      orElse: () => ThemeMode.light,
    );
  }
  
  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme': state.name};
  }
}
```

---

## Benefits of MVVM with BLoC

### 1. **Separation of Concerns**
- UI (View) is separated from business logic (ViewModel/Cubit)
- Models contain only data structures
- Each layer has a single responsibility

### 2. **Testability**
- Cubits can be unit tested without UI
- Views can be widget tested with mock Cubits
- Models can be tested independently
- `bloc_test` package for easy cubit testing

### 3. **Reactive UI**
- Automatic UI updates when state changes
- No manual `setState()` calls
- Efficient rebuilds (only BlocBuilder widgets)

### 4. **Immutable State**
- State is immutable by design
- New state objects on every change
- Prevents accidental mutations
- Easy to track state changes

### 5. **Code Reusability**
- Cubits can be shared across platforms
- Models are pure Dart (no Flutter dependency)
- Business logic is centralized

### 6. **Maintainability**
- Clear architecture pattern
- Easy to locate code
- Scalable for large applications
- Enforced best practices

---

## Comparison with Other Patterns

| Feature | MVVM + BLoC | MVVM + GetX | MVC | Provider |
|---------|-------------|-------------|-----|----------|
| Learning Curve | Medium | Easy | Easy | Easy |
| Boilerplate | Medium | Low | Medium | Medium |
| Reactive | Yes | Yes | No | Yes |
| DI Built-in | Yes | Yes | No | Yes |
| Navigation | Manual/Package | Built-in | Manual | Manual |
| State Management | Cubit/emit() | .obs/Obx() | Manual | ChangeNotifier |
| Persistence | HydratedBloc | GetStorage | Manual | Manual |
| Testing | Excellent | Good | Good | Good |
| Type Safety | Excellent | Good | Good | Good |

---

## Best Practices

### 1. **Keep Views Dumb**
- Views should only display data and handle user input
- No business logic in Views
- Delegate everything to Cubit
- Use BlocBuilder/BlocListener appropriately

### 2. **Keep Models Pure**
- No business logic in Models
- Only data structures and methods to manipulate them
- No Flutter dependencies
- Use Equatable for value comparison

### 3. **Immutable State**
- Always emit new state objects
- Use `copyWith()` for partial updates
- Never mutate state directly
- Use `const` constructors when possible

### 4. **Proper Disposal**
- BlocProvider handles disposal automatically
- Override `close()` for custom cleanup
- Close streams, cancel timers, etc.

### 5. **Naming Conventions**
- Cubits: `CounterCubit`, `NotesCubit`
- Methods: `increment()`, `addNote()`, etc.
- States: Use model classes or primitives
- Clear, descriptive names

### 6. **Use Appropriate Widgets**
- `BlocBuilder` for UI updates
- `BlocListener` for side effects (navigation, snackbars)
- `BlocConsumer` when you need both
- `context.read()` for calling methods
- `context.watch()` for accessing state

### 7. **Error Handling**
- Use sealed classes or enums for state (advanced)
- Handle loading, success, error states
- Provide user feedback

---

## Testing Strategy

### Unit Tests (Cubits)

**Using bloc_test package:**
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  group('CounterCubit', () {
    blocTest<CounterCubit, CounterModel>(
      'emits incremented value when increment is called',
      build: () => CounterCubit(),
      act: (cubit) => cubit.increment(),
      expect: () => [const CounterModel(value: 1)],
    );
    
    blocTest<CounterCubit, CounterModel>(
      'emits [1, 2] when increment is called twice',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment();
        cubit.increment();
      },
      expect: () => [
        const CounterModel(value: 1),
        const CounterModel(value: 2),
      ],
    );
  });
}
```

### Widget Tests (Views)

```dart
testWidgets('displays counter value', (tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => CounterCubit(),
      child: const MaterialApp(home: CounterView()),
    ),
  );
  
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  expect(find.text('1'), findsOneWidget);
});
```

### Mock Cubits

```dart
class MockCounterCubit extends MockCubit<CounterModel> 
    implements CounterCubit {}

testWidgets('uses mock cubit', (tester) async {
  final mockCubit = MockCounterCubit();
  when(() => mockCubit.state).thenReturn(const CounterModel(value: 42));
  
  await tester.pumpWidget(
    BlocProvider<CounterCubit>.value(
      value: mockCubit,
      child: const CounterView(),
    ),
  );
  
  expect(find.text('42'), findsOneWidget);
});
```

---

## Conclusion

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Reactive UI updates
- ✅ Easy testing with bloc_test
- ✅ Type-safe state management
- ✅ Immutable state pattern
- ✅ Scalability
- ✅ Maintainability
- ✅ Optional persistence with HydratedBloc
- ✅ Excellent tooling and DevTools support

Perfect for small to large Flutter applications with strong architectural needs!
