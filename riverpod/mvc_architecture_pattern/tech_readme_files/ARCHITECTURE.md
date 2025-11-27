# MVC Architecture Pattern with Riverpod

## Overview

This project demonstrates the **MVC (Model-View-Controller)** architecture pattern in Flutter using **Riverpod** for state management and dependency injection.

## Architecture Components

### 1. Model Layer (`/models`)

**Purpose**: Represents the data structures.

**Characteristics**:
- Pure Dart classes.
- Immutable data structures.
- Contains `toJson()` and `fromJson()` methods.
- No business logic.

**Example**:
```dart
class CounterModel {
  final int value;
  const CounterModel({required this.value});
  // ... copyWith, toJson, fromJson
}
```

### 2. Controller Layer (`/controllers`)

**Purpose**: Handles business logic and manages state.

**Characteristics**:
- Implemented as **StateNotifier** or **Notifier**.
- Contains methods to manipulate data (increment, add note).
- Updates state, which triggers View rebuilds.
- Handles data persistence (optional).

**Example**:
```dart
class CounterController extends StateNotifier<CounterModel> {
  CounterController() : super(const CounterModel(value: 0));

  void increment() {
    state = state.copyWith(value: state.value + 1);
  }
}
```

### 3. View Layer (`/views`)

**Purpose**: Displays UI and handles user interactions.

**Characteristics**:
- **ConsumerWidget** or **ConsumerStatefulWidget**.
- Listens to Controllers via `ref.watch`.
- Calls Controller methods via `ref.read`.
- No business logic.

**Example**:
```dart
class CounterView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterControllerProvider);
    return Text('${counter.value}');
  }
}
```

---

## Data Flow

```
1. User Interaction (View)
   ↓
2. Call Controller Method (ref.read)
   ↓
3. Controller Updates State (state = ...)
   ↓
4. View Rebuilds (ref.watch detects change)
```

## Key Riverpod Features Used

*   **StateNotifierProvider**: To expose Controllers.
*   **ConsumerWidget**: To build the UI.
*   **ref.watch**: To listen to state changes.
*   **ref.read**: To access Controller methods without listening.

## Benefits

*   **Separation of Concerns**: Logic is separated from UI.
*   **Testability**: Controllers can be unit tested easily.
*   **Simplicity**: Easier to understand than Clean Architecture for smaller apps.

---

**MVC with Riverpod offers a balanced approach between structure and simplicity!**
