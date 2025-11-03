# Counter Notes App - MVC Pattern with GetX

A Flutter application demonstrating the **Model-View-Controller (MVC)** architecture pattern using **GetX** for state management and navigation.

## 📱 App Overview

Counter Notes App is a simple yet comprehensive example of MVC pattern implementation with two main features:

1. **Counter Screen**: Increment, decrement, and reset a counter
2. **Notes Screen**: Add, delete, and list simple text notes

## 🏗️ Architecture: MVC Pattern

### Model Layer (`lib/models/`)
- **Purpose**: Holds data classes and data structures
- **Files**:
  - `counter_model.dart` - Counter data structure with value and methods
  - `note_model.dart` - Note data structure with id, content, and timestamp

### View Layer (`lib/views/`)
- **Purpose**: Contains UI widgets only (no business logic)
- **Files**:
  - `counter_view.dart` - UI for counter screen
  - `notes_view.dart` - UI for notes screen

### Controller Layer (`lib/controllers/`)
- **Purpose**: Manages business logic and state using GetX
- **Files**:
  - `counter_controller.dart` - Counter logic and state management
  - `notes_controller.dart` - Notes logic and CRUD operations
  - `theme_controller.dart` - Theme switching logic

## 🎯 Key Features

### Counter Screen
- ➕ Increment counter
- ➖ Decrement counter
- 🔄 Reset counter to zero
- 📊 Real-time counter display
- 💬 Snackbar notifications

### Notes Screen
- ✏️ Add new notes
- 🗑️ Delete individual notes
- 🧹 Clear all notes with confirmation
- 📝 Display note count
- ⏰ Timestamp with relative time display

### Global Features
- 🌓 Light/Dark theme switching
- 🚀 Smooth navigation transitions
- 📱 Responsive UI design
- 🎨 Material Design 3

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.6.6  # GetX for state management and navigation
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point and GetX configuration
├── models/                        # Model layer - Data structures
│   ├── counter_model.dart
│   └── note_model.dart
├── views/                         # View layer - UI widgets
│   ├── counter_view.dart
│   └── notes_view.dart
└── controllers/                   # Controller layer - Business logic
    ├── counter_controller.dart
    ├── notes_controller.dart
    └── theme_controller.dart
```

## 🎓 Understanding MVC with GetX

### How GetX Fits into MVC

1. **Model (M)**: Pure data classes
   ```dart
   class CounterModel {
     int value;
     void increment() => value++;
   }
   ```

2. **Controller (C)**: GetX Controllers manage state
   ```dart
   class CounterController extends GetxController {
     final _counter = CounterModel().obs;
     void increment() {
       _counter.value.increment();
       _counter.refresh();
     }
   }
   ```

3. **View (V)**: Widgets observe controller state
   ```dart
   class CounterView extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       final controller = Get.put(CounterController());
       return Obx(() => Text('${controller.counterValue}'));
     }
   }
   ```

### Key GetX Features Used

- **Reactive State Management**: `.obs` and `Obx()` for reactive updates
- **Dependency Injection**: `Get.put()` and `Get.find()` for controller management
- **Navigation**: `Get.toNamed()` and `Get.back()` for route navigation
- **Dialogs & Snackbars**: `Get.snackbar()` and `Get.defaultDialog()`
- **Theme Management**: `Get.changeTheme()` for dynamic theme switching

## 🔍 Code Highlights

### Separation of Concerns

✅ **Good Practice - Following MVC**:
- Models contain only data and data operations
- Controllers handle all business logic
- Views only contain UI code and observe controllers

❌ **Bad Practice - Avoiding**:
- No business logic in views
- No UI code in controllers
- No direct state manipulation in models

### GetX Controller Lifecycle

```dart
class NotesController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Initialize data when controller is created
  }

  @override
  void onClose() {
    // Clean up resources when controller is disposed
    super.onClose();
  }
}
```

## 🎨 UI/UX Features

- **Material Design 3** with dynamic theming
- **Smooth transitions** between screens
- **Responsive cards** and layouts
- **Interactive buttons** with icons
- **Real-time updates** with reactive state
- **User feedback** through snackbars and dialogs

## 📚 Learning Outcomes

By studying this project, you'll learn:

1. ✅ How to structure a Flutter app using MVC pattern
2. ✅ How to use GetX for state management
3. ✅ How to separate concerns (Model, View, Controller)
4. ✅ How to implement reactive programming with GetX
5. ✅ How to handle navigation with GetX routes
6. ✅ How to manage themes dynamically
7. ✅ How to keep business logic out of UI code

## 🔧 Extending the App

Ideas for further development:

- 💾 Add local storage (SharedPreferences or Hive)
- 🔍 Implement note search functionality
- 🏷️ Add note categories or tags
- ✏️ Enable note editing
- 📤 Add export/import functionality
- 🔐 Implement authentication
- ☁️ Add cloud synchronization

## 📖 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [MVC Pattern Guide](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
- [Material Design 3](https://m3.material.io/)

## 📝 License

This project is created for educational purposes to demonstrate MVC pattern with GetX in Flutter.

---

**Built with** ❤️ **using Flutter & GetX**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
