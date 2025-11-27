# MVVM Architecture Pattern with Riverpod

## Overview

This project demonstrates the **MVVM (Model-View-ViewModel)** architecture pattern in Flutter using **Riverpod**.

## Architecture Components

### 1. Model Layer (`/models`)

**Purpose**: Represents the data structures.

**Characteristics**:
- Pure Dart classes.
- Immutable.
- No business logic.

### 2. ViewModel Layer (`/viewmodels`)

**Purpose**: Exposes streams of data relevant to the View.

**Characteristics**:
- Implemented as **StateNotifier** or **Notifier**.
- Exposes state that the View consumes.
- Handles business logic.
- **Difference from MVC Controller**: In MVVM, the ViewModel is often more focused on transforming model data for the View, though in Flutter/Riverpod, Controller and ViewModel implementations often look similar (StateNotifier).

**Example**:
```dart
class CounterViewModel extends StateNotifier<CounterModel> {
  CounterViewModel() : super(const CounterModel(value: 0));
  // ... logic
}
```

### 3. View Layer (`/views`)

**Purpose**: Displays UI.

**Characteristics**:
- **ConsumerWidget**.
- Binds to ViewModel state via `ref.watch`.

---

## Data Flow

```
View (User Action) -> ViewModel (Method Call) -> Model (Update) -> ViewModel (State Change) -> View (Rebuild)
```

## Key Riverpod Features

*   **Providers**: Used to inject ViewModels.
*   **Overrides**: Used for dependency injection (e.g., injecting SharedPreferences into ViewModels).

## Dependency Injection

In this project, we use `ProviderScope` overrides in `main.dart` to inject dependencies like `SharedPreferences` into our ViewModels.

```dart
// main.dart
runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ),
);
```

---

**MVVM with Riverpod provides a reactive, testable architecture.**
