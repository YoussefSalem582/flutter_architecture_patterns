# MVC Architecture Pattern with Riverpod - Project Overview

## 📁 Project Structure

```
mvc_architecture_pattern/
│
├── lib/
│   ├── controllers/           # CONTROLLER LAYER (Logic & State)
│   │   ├── counter_controller.dart
│   │   ├── notes_controller.dart
│   │   └── theme_controller.dart
│   │
│   ├── models/                # MODEL LAYER (Data)
│   │   ├── counter_model.dart
│   │   └── note_model.dart
│   │
│   ├── views/                 # VIEW LAYER (UI)
│   │   ├── home_view.dart
│   │   ├── counter_view.dart
│   │   └── notes_view.dart
│   │
│   └── main.dart              # Entry Point & ProviderScope
```

## 🏗️ MVC Pattern Flow

```
USER INTERACTION
       │
       ▼
┌──────────────────┐
│   VIEW LAYER     │  • CounterView / NotesView
│   (UI Only)      │  • Displays data using ref.watch()
│                  │  • Forwards events using ref.read()
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ CONTROLLER LAYER │  • CounterController / NotesController
│ (Business Logic) │  • Processes actions
│                  │  • Updates state
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   MODEL LAYER    │  • CounterModel / NoteModel
│   (Data)         │  • Pure data structures
└──────────────────┘
```

## 🔑 Key Features

*   **State Management**: Riverpod `StateNotifier` is used as the Controller.
*   **Dependency Injection**: Riverpod Providers inject controllers into views.
*   **Reactive UI**: `ConsumerWidget` rebuilds automatically when state changes.

## 🚀 Extending the App

To add a new feature (e.g., Todo):
1.  Create `TodoModel` in `models/`.
2.  Create `TodoController` (StateNotifier) in `controllers/`.
3.  Create `TodoView` (ConsumerWidget) in `views/`.
4.  Define `todoControllerProvider` global provider.

---

**Simple, clean, and effective MVC implementation with Riverpod.**
