# Counter Notes App - Quick Start Guide

## 🎯 Project Summary

This is a Flutter application demonstrating the **MVVM (Model-View-ViewModel)** architecture pattern with **BLoC/Cubit** for reactive state management.

## 📦 What's Been Built

### ✅ Complete Features
1. **Counter Screen** - Increment, decrement, reset with reactive updates
2. **Notes Screen** - Add, delete notes with real-time list updates  
3. **Home Screen** - Navigation hub with theme toggle
4. **Dark/Light Themes** - Material Design 3 with theme switching
5. **Persistent Storage** - State survives app restarts (HydratedBloc)

### ✅ Architecture Implementation

```
lib/
├── models/              # Data structures (CounterModel, NoteModel)
├── cubits/              # Business logic (ViewModels) with emit()
├── views/               # UI screens with BlocBuilder
├── config/              # App themes
└── main.dart            # App entry point with BlocProvider
```

## 🚀 How to Run

1. **Install dependencies:**
   ```bash
   cd mvvm_architecture_pattern
   flutter pub get
   ```

2. **Run on your preferred platform:**
   ```bash
   flutter run -d chrome        # Web
   flutter run -d windows       # Windows (requires Visual Studio)
   flutter run                  # Your connected device
   ```

## 🔍 Key MVVM + BLoC Concepts Demonstrated

### 1. Model (Data Layer)
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
- Pure Dart classes with Equatable
- Immutable with `const` constructors
- `copyWith()` for creating modified copies
- No business logic

### 2. ViewModel (Logic Layer - Cubit)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/counter_model.dart';

class CounterCubit extends Cubit<CounterModel> {
  CounterCubit() : super(const CounterModel(value: 0));
  
  int get counterValue => state.value;
  
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
- Extends `Cubit<State>`
- Uses `emit()` to update state
- Contains all business logic
- No UI code

### 3. ViewModel with Persistence (HydratedCubit)
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/counter_model.dart';

class CounterCubit extends HydratedCubit<CounterModel> {
  CounterCubit() : super(const CounterModel(value: 0));
  
  void increment() {
    emit(state.copyWith(value: state.value + 1));
  }
  
  // Auto-persistence methods
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
- Extends `HydratedCubit<State>`
- Automatically persists state
- Implements `toJson` / `fromJson`

### 4. View (UI Layer)
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
        // Reactive UI - rebuilds when state changes
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
        // Call cubit method without rebuilding
        onPressed: () => context.read<CounterCubit>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
- `StatelessWidget` (BLoC handles state)
- `BlocBuilder<Cubit, State>` for reactive UI
- `context.read<Cubit>()` to call methods
- No business logic

### 5. Dependency Injection (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistence storage (optional)
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
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
```
- `MultiBlocProvider` provides all cubits
- `BlocBuilder` for theme reactivity
- Automatic disposal

## 📱 App Flow

```
User taps button → View calls Cubit method via context.read() → 
Cubit emits new state → BLoC notifies listeners → 
BlocBuilder rebuilds → UI updates automatically
```

### Detailed Flow Example

```
1. User taps increment button
   ↓
2. onPressed: () => context.read<CounterCubit>().increment()
   ↓
3. Cubit: emit(state.copyWith(value: state.value + 1))
   ↓
4. BLoC detects state change
   ↓
5. BlocBuilder rebuilds with new state
   ↓
6. UI displays new counter value
```

## 🎨 Features to Try

1. **Counter Screen:**
   - Tap increment/decrement buttons
   - Watch the counter update reactively
   - Try the reset button
   - Restart app to see persistence

2. **Notes Screen:**
   - Add notes using text field
   - Delete individual notes
   - Try "Delete All" button
   - Notes persist across app restarts

3. **Theme Toggle:**
   - Click theme icon in AppBar
   - Watch app switch between light/dark mode
   - Theme preference persists

## 📚 Learning Points

### Why MVVM?
- ✅ **Separation of Concerns** - UI, logic, and data are separate
- ✅ **Testability** - Cubits can be unit tested easily
- ✅ **Reusability** - Cubits can be shared across screens
- ✅ **Maintainability** - Clear structure and responsibilities

### Why BLoC/Cubit?
- ✅ **Reactive** - Automatic UI updates with `emit()`
- ✅ **Predictable** - Immutable state pattern
- ✅ **Testable** - `bloc_test` package for easy testing
- ✅ **Powerful** - Handles complex state logic
- ✅ **DevTools** - Excellent debugging support
- ✅ **Persistence** - HydratedBloc for auto-save/restore

### BLoC vs GetX

| Feature | BLoC/Cubit | GetX |
|---------|-----------|------|
| Syntax | `emit(state)` | `.obs` + `Obx()` |
| Learning Curve | Medium | Easy |
| Boilerplate | Medium | Low |
| Type Safety | Excellent | Good |
| Testing | `bloc_test` package | Standard testing |
| DevTools | Excellent | Good |
| Persistence | HydratedBloc | GetStorage |
| Architecture | Enforced | Flexible |

## 🔧 Project Structure Explained

### Models (`/models`)
- `counter_model.dart` - Counter value with Equatable
- `note_model.dart` - Note with id, content, timestamp

### Cubits (`/cubits` - ViewModels)
- `counter_cubit.dart` - Counter state and logic
- `notes_cubit.dart` - Notes list state and operations
- `theme_cubit.dart` - Theme state and switching

### Views (`/views`)
- `home_view.dart` - Landing page with navigation
- `counter_view.dart` - Counter display with BlocBuilder
- `notes_view.dart` - Notes list with BlocBuilder/BlocListener

### Config (`/config`)
- `app_themes.dart` - Light and dark theme definitions

## 🧪 Testing the Architecture

The MVVM + BLoC pattern makes testing easy:

**Test Cubits (Unit Tests with bloc_test):**
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

**Test Views (Widget Tests):**
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

## 📖 Further Reading

- **README.md** - Full project documentation
- **ARCHITECTURE.md** - Detailed MVVM + BLoC architecture
- **BLoC Documentation** - https://bloclibrary.dev/
- **HydratedBloc** - https://pub.dev/packages/hydrated_bloc

## 🎯 Key Takeaways

1. **MVVM separates concerns** - Model (data), View (UI), ViewModel (logic/Cubit)
2. **Cubit manages state** - Extends Cubit<State>, uses emit() to update
3. **BlocBuilder rebuilds UI** - Automatically rebuilds when state changes
4. **Immutable state** - Always emit new state objects
5. **HydratedCubit persists** - Auto-save/restore with toJson/fromJson
6. **No setState()!** - BLoC handles all state updates
7. **Type-safe** - Compile-time safety with strong typing
8. **Testable** - Easy to test with bloc_test package

## 🎨 Common BLoC Patterns

### Pattern 1: Simple State

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
}

// UI
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)
```

### Pattern 2: Complex State (Model)

```dart
class CounterCubit extends Cubit<CounterModel> {
  CounterCubit() : super(const CounterModel(value: 0));
  
  void increment() {
    emit(state.copyWith(value: state.value + 1));
  }
}

// UI
BlocBuilder<CounterCubit, CounterModel>(
  builder: (context, model) => Text('${model.value}'),
)
```

### Pattern 3: List State

```dart
class NotesCubit extends Cubit<List<Note>> {
  NotesCubit() : super([]);
  
  void addNote(String content) {
    final note = Note(content: content);
    emit([...state, note]);  // Create new list
  }
  
  void deleteNote(String id) {
    emit(state.where((note) => note.id != id).toList());
  }
}

// UI
BlocBuilder<NotesCubit, List<Note>>(
  builder: (context, notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(notes[index].content),
      ),
    );
  },
)
```

### Pattern 4: Side Effects

```dart
BlocListener<NotesCubit, List<Note>>(
  listener: (context, notes) {
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notes cleared')),
      );
    }
  },
  child: MyNotesWidget(),
)
```

### Pattern 5: Builder + Listener

```dart
BlocConsumer<NotesCubit, List<Note>>(
  listener: (context, notes) {
    // Side effects (snackbar, navigation)
  },
  builder: (context, notes) {
    // UI updates
    return ListView(...);
  },
)
```

## 🔧 Common Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d windows

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build
flutter clean
flutter pub get
```

## 🐛 Troubleshooting

### Issue: Provider not found error
**Error:** `Could not find the correct Provider<CounterCubit>`

**Solution:** Ensure BlocProvider is above widget in tree:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => CounterCubit()),
  ],
  child: MyApp(),
)
```

### Issue: State not updating
**Solution:** Always emit new state objects:
```dart
// ❌ Wrong - Mutates state
state.add(item);
emit(state);

// ✅ Correct - New state
emit([...state, item]);
```

### Issue: HydratedBloc not persisting
**Solution:** Initialize storage before runApp:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(const MyApp());
}
```

### Issue: Tests failing
**Solution:** Use `pumpAndSettle()` after actions:
```dart
await tester.tap(find.byIcon(Icons.add));
await tester.pumpAndSettle();  // Wait for animations
expect(find.text('1'), findsOneWidget);
```

---

**Happy Learning! 🚀**

This project is designed to teach MVVM architecture with BLoC/Cubit.  
Explore the code, experiment with changes, and build upon it!

**Next Steps:**
1. Run the app and try all features
2. Read ARCHITECTURE.md for deep dive
3. Modify cubits and see changes
4. Add your own features
5. Write tests using bloc_test
