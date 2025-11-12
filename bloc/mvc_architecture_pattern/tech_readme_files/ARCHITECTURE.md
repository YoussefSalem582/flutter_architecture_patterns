# MVC Architecture Documentation

## 📐 Architecture Overview

This document explains how the MVC (Model-View-Controller) pattern is implemented in the Counter Notes App using **BLoC/Cubit**.

## 🏗️ MVC Pattern Structure

```
┌─────────────────────────────────────────────────────────┐
│                         USER                            │
│                    (Interacts with)                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      VIEW LAYER                         │
│  ┌──────────────────┐      ┌─────────────────────┐    │
│  │  CounterView     │      │    NotesView        │    │
│  │  - UI Widgets    │      │    - UI Widgets     │    │
│  │  - BlocBuilder   │      │    - BlocBuilder    │    │
│  │  - No Logic      │      │    - No Logic       │    │
│  └──────────────────┘      └─────────────────────┘    │
└────────────┬────────────────────────┬───────────────────┘
             │ Observes/Calls         │
             ▼                        ▼
┌─────────────────────────────────────────────────────────┐
│                   CONTROLLER LAYER                      │
│  ┌──────────────────────┐   ┌───────────────────────┐  │
│  │ CounterCubit         │   │  NotesCubit           │  │
│  │ - Business Logic     │   │  - Business Logic     │  │
│  │ - State Management   │   │  - State Management   │  │
│  │ - Cubit (BLoC)       │   │  - Cubit (BLoC)       │  │
│  │ - HydratedBloc       │   │  - HydratedBloc       │  │
│  └──────────┬───────────┘   └──────────┬────────────┘  │
│             │ Updates                   │ Updates       │
│  ┌──────────────────────────────────────────────────┐  │
│  │           ThemeCubit                             │  │
│  │           - Global State Management              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────┬────────────────────────┬──────────────────┘
              │ Manipulates            │
              ▼                        ▼
┌─────────────────────────────────────────────────────────┐
│                     MODEL LAYER                         │
│  ┌──────────────────┐      ┌─────────────────────┐    │
│  │  CounterModel    │      │    NoteModel        │    │
│  │  - int value     │      │    - String id      │    │
│  │  - increment()   │      │    - String content │    │
│  │  - decrement()   │      │    - DateTime       │    │
│  │  - reset()       │      │    - toJson()       │    │
│  │  - Equatable     │      │    - Equatable      │    │
│  └──────────────────┘      └─────────────────────┘    │
│            Pure Data Classes - No Dependencies         │
└─────────────┬───────────────────────┬───────────────────┘
              │ Persisted via         │
              ▼                       ▼
┌─────────────────────────────────────────────────────────┐
│                   STORAGE LAYER                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              HydratedBloc                        │  │
│  │  - Auto-saves counter state                      │  │
│  │  - Auto-saves notes list                         │  │
│  │  - Persists data across app restarts            │  │
│  │  - Uses path_provider for storage location      │  │
│  └──────────────────────────────────────────────────┘  │
│            Local Persistent Storage                    │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### Counter Feature Flow

1. **User Action**: User taps "Increment" button in `CounterView`
2. **View → Cubit**: View calls `counterCubit.increment()`
3. **Cubit → Model**: Cubit updates `CounterModel.value`
4. **Cubit → Storage**: HydratedBloc automatically persists state
5. **Cubit Emits State**: Cubit emits new `CounterState`
6. **Cubit → User**: Cubit triggers snackbar via BlocListener
7. **View Updates**: `BlocBuilder` automatically rebuilds with new value
8. **User Sees Change**: UI reflects the updated counter value
9. **Data Persists**: Counter value survives app restart

### Notes Feature Flow

1. **User Action**: User enters text and taps "Add" in `NotesView`
2. **View → Cubit**: View calls `notesCubit.addNote(content)`
3. **Cubit Validation**: Cubit validates input
4. **Cubit → Model**: Cubit creates new `NoteModel`
5. **Cubit Updates List**: Cubit adds note to notes list
6. **Cubit → Storage**: HydratedBloc automatically persists state
7. **Cubit Emits State**: Cubit emits new `NotesState`
8. **View Updates**: `BlocBuilder` rebuilds ListView with new note
9. **User Sees Change**: UI shows the new note in the list
10. **Data Persists**: Notes survive app restart

### App Initialization Flow

1. **main()**: App starts with `WidgetsFlutterBinding.ensureInitialized()`
2. **Storage Init**: HydratedBloc initializes storage directory
3. **Hydration**: HydratedBloc restores previous state
4. **App Starts**: `runApp()` launches the app
5. **Cubit Init**: Cubits load hydrated state automatically
6. **UI Renders**: Views display persisted data

## 📦 Layer Responsibilities

### Model Layer (Data)

**Purpose**: Define data structures and basic operations

**Characteristics**:
- ✅ Pure Dart classes
- ✅ No dependencies on Flutter or BLoC
- ✅ Contains data fields
- ✅ Implements Equatable for value comparison
- ✅ Contains data manipulation methods
- ❌ No UI code
- ❌ No state management
- ❌ No business logic

**Example - CounterModel**:
```dart
class CounterModel extends Equatable {
  final int value;
  
  const CounterModel({this.value = 0});
  
  CounterModel increment() => CounterModel(value: value + 1);
  CounterModel decrement() => CounterModel(value: value - 1);
  CounterModel reset() => const CounterModel(value: 0);
  
  @override
  List<Object?> get props => [value];
}
```

### View Layer (Presentation)

**Purpose**: Display UI and capture user interactions

**Characteristics**:
- ✅ StatelessWidget (preferred with BLoC)
- ✅ Observes cubit state with `BlocBuilder()`
- ✅ Responds to events with `BlocListener()`
- ✅ Calls cubit methods
- ✅ UI/UX code only
- ❌ No business logic
- ❌ No state management
- ❌ No direct model manipulation

**Example - CounterView**:
```dart
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CounterCubit, CounterModel>(
        builder: (context, counter) {
          return Text('${counter.value}');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterCubit>().increment(),
      ),
    );
  }
}
```

### Controller Layer (Business Logic)

**Purpose**: Manage state and implement business logic

**Characteristics**:
- ✅ Extends Cubit or HydratedCubit
- ✅ Contains business logic
- ✅ Manages state by emitting new states
- ✅ Manipulates models
- ✅ Provides methods for views
- ✅ Handles data persistence with HydratedBloc
- ❌ No UI widgets
- ❌ No direct BuildContext usage (except for navigation)

**Example - CounterCubit with HydratedBloc**:
```dart
class CounterCubit extends HydratedCubit<CounterModel> {
  CounterCubit() : super(const CounterModel());
  
  void increment() {
    emit(state.increment()); // Auto-persists
  }
  
  void decrement() {
    emit(state.decrement()); // Auto-persists
  }
  
  void reset() {
    emit(state.reset()); // Auto-persists
  }
  
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

## 🎯 BLoC Integration in MVC

### 1. State Management

**State Classes**:
```dart
// Models serve as states
class CounterModel extends Equatable {
  final int value;
  const CounterModel({this.value = 0});
  
  @override
  List<Object?> get props => [value];
}

// For notes, use list of models
class NotesCubit extends HydratedCubit<List<NoteModel>> {
  NotesCubit() : super([]);
}
```

**State Observation**:
```dart
// Rebuild when state changes
BlocBuilder<CounterCubit, CounterModel>(
  builder: (context, counter) => Text('${counter.value}'),
)

// Listen for side effects (snackbars, navigation)
BlocListener<CounterCubit, CounterModel>(
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Counter: ${state.value}')),
    );
  },
  child: Container(),
)
```

### 2. Dependency Injection

**Cubit Registration**:
```dart
// In main.dart - Provide cubits globally
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => CounterCubit()),
    BlocProvider(create: (_) => NotesCubit()),
    BlocProvider(create: (_) => ThemeCubit()),
  ],
  child: MaterialApp(...),
)

// In View - Access cubit
context.read<CounterCubit>().increment();

// In BlocBuilder - Observe state
BlocBuilder<CounterCubit, CounterModel>(...)
```

### 3. Navigation

**Route Navigation**:
```dart
// Navigate to named route
Navigator.pushNamed(context, '/notes');

// Go back
Navigator.pop(context);
```

### 4. User Feedback

**Snackbars and Dialogs**:
```dart
// Show snackbar with BlocListener
BlocListener<CounterCubit, CounterModel>(
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated!')),
    );
  },
)

// Show dialog
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
  ),
);
```

### 5. Data Persistence

**HydratedBloc Integration**:
```dart
// Initialize in main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(MyApp());
}

// Extend HydratedCubit for auto-persistence
class CounterCubit extends HydratedCubit<CounterModel> {
  @override
  CounterModel? fromJson(Map<String, dynamic> json) {
    // Deserialize from storage
  }
  
  @override
  Map<String, dynamic>? toJson(CounterModel state) {
    // Serialize to storage
  }
}
```

## 🔧 Best Practices

### ✅ DO's

1. **Keep Views Dumb**: Views should only display data and forward events
2. **Cubit Logic**: All business logic goes in cubits
3. **Pure Models**: Models should be framework-agnostic and extend Equatable
4. **Emit States**: Use `emit()` to update state
5. **Dependency Injection**: Use `BlocProvider` and `context.read()`
6. **Named Routes**: Use MaterialApp's routing for navigation
7. **HydratedBloc**: Use for automatic data persistence
8. **BlocListener**: Use for side effects (snackbars, navigation)
9. **BlocBuilder**: Use for UI rebuilds
10. **Equatable**: Implement for efficient state comparison

### ❌ DON'Ts

1. **Logic in Views**: Don't put business logic in build() methods
2. **UI in Cubits**: Don't return widgets from cubits
3. **setState()**: Don't use setState() - use BLoC pattern
4. **Direct Model Access**: Don't let views directly modify models
5. **Tight Coupling**: Don't create hard dependencies between layers
6. **Context in Cubits**: Avoid passing BuildContext to cubit methods

## 📊 Comparison with Other Patterns

### MVC vs MVVM vs MVI

| Aspect | MVC (This App) | MVVM | MVI |
|--------|----------------|------|-----|
| **State Holder** | Cubit | Cubit (ViewModel) | Bloc (Events) |
| **State Updates** | Direct emission | Stream updates | Event-driven |
| **Complexity** | Low | Medium | High |
| **Testability** | Excellent | Excellent | Excellent |
| **Learning Curve** | Easy | Medium | Steep |
| **Persistence** | HydratedCubit | HydratedCubit | HydratedBloc |

## 🧪 Testing Strategy

### Unit Testing Cubits

```dart
test('Counter increment works', () {
  final cubit = CounterCubit();
  cubit.increment();
  expect(cubit.state.value, 1);
  cubit.close();
});

blocTest<CounterCubit, CounterModel>(
  'emits incremented state',
  build: () => CounterCubit(),
  act: (cubit) => cubit.increment(),
  expect: () => [CounterModel(value: 1)],
);
```

### Widget Testing Views

```dart
testWidgets('Counter view displays value', (tester) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => CounterCubit(),
      child: MaterialApp(home: CounterView()),
    ),
  );
  expect(find.text('0'), findsOneWidget);
});
```

## 📚 Further Reading

- [BLoC Documentation](https://bloclibrary.dev/)
- [HydratedBloc Documentation](https://pub.dev/packages/hydrated_bloc)
- [MVC Pattern on Wikipedia](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## 🎓 Key Takeaways

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **BLoC Integration**: Cubit simplifies state management in MVC
3. **Reactive Programming**: State emission enables automatic UI updates
4. **Maintainability**: Clear structure makes code easy to understand and modify
5. **Testability**: BLoC pattern makes testing straightforward
6. **Persistence**: HydratedBloc provides automatic data persistence

---

**Remember**: The goal of MVC with BLoC is to separate concerns and make your code more maintainable, testable, and scalable. HydratedBloc makes persistence effortless!
