# Counter Notes App - MVVM Architecture with GetX

A Flutter application demonstrating the **MVVM (Model-View-ViewModel)** architecture pattern using **GetX** for reactive state management, dependency injection, and routing.

## 📱 Features

### 1. Counter Screen
- ➕ Increment counter
- ➖ Decrement counter  
- 🔄 Reset counter to zero
- Real-time UI updates using GetX observables

### 2. Notes Screen
- ➕ Add new text notes
- 📝 View all notes with timestamps
- 🗑️ Delete individual notes
- 🗑️ Delete all notes with confirmation
- Real-time list updates using reactive observables

### 3. Additional Features
- 🌓 Dark/Light theme toggle
- 🎨 Material Design 3 UI
- ✨ Smooth page transitions
- 📱 Responsive design

## 🏗️ Architecture Overview

This project follows the **MVVM (Model-View-ViewModel)** pattern:

```
┌─────────────────────────────────────────────────────────┐
│                         View                            │
│  (UI Layer - Displays data and handles user input)     │
│  • home_view.dart                                       │
│  • counter_view.dart                                    │
│  • notes_view.dart                                      │
└───────────────────┬─────────────────────────────────────┘
                    │ Observes (.obs)
                    │ Binds to ViewModel
┌───────────────────▼─────────────────────────────────────┐
│                      ViewModel                          │
│  (Business Logic + Reactive State with GetX)            │
│  • counter_viewmodel.dart                               │
│  • notes_viewmodel.dart                                 │
└───────────────────┬─────────────────────────────────────┘
                    │ Uses
                    │ Manages
┌───────────────────▼─────────────────────────────────────┐
│                        Model                            │
│  (Data Structures - Plain Dart classes)                 │
│  • counter_model.dart                                   │
│  • note_model.dart                                      │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point with GetMaterialApp
├── bindings/                      # GetX Dependency Injection
│   ├── counter_binding.dart       # Counter ViewModel binding
│   └── notes_binding.dart         # Notes ViewModel binding
├── config/                        # App configuration
│   └── app_themes.dart            # Light & Dark themes
├── models/                        # Data Models
│   ├── counter_model.dart         # Counter data structure
│   └── note_model.dart            # Note data structure
├── routes/                        # Navigation
│   ├── app_routes.dart            # Route names
│   └── app_pages.dart             # Page definitions with bindings
├── viewmodels/                    # Business Logic Layer
│   ├── counter_viewmodel.dart     # Counter logic with .obs
│   └── notes_viewmodel.dart       # Notes logic with .obs
└── views/                         # UI Layer
    ├── home_view.dart             # Landing page
    ├── counter_view.dart          # Counter screen
    └── notes_view.dart            # Notes screen
```

## 🔑 Key MVVM Concepts Demonstrated

### 1. **Model** (Data Layer)
Pure Dart classes representing data structures:
```dart
class CounterModel {
  final int value;
  CounterModel({required this.value});
}
```

### 2. **ViewModel** (Business Logic Layer)
Contains reactive state and business logic using GetX:
```dart
class CounterViewModel extends GetxController {
  // Reactive observable
  final _counter = CounterModel(value: 0).obs;
  
  // Getter
  int get counterValue => _counter.value.value;
  
  // Business logic methods
  void increment() { /* ... */ }
}
```

### 3. **View** (UI Layer)
Displays data and reacts to ViewModel changes using `Obx`:
```dart
class CounterView extends GetView<CounterViewModel> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${controller.counterValue}'));
  }
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)

### Installation

1. **Navigate to the project directory:**
   ```bash
   cd mvvm_architeture_pattern
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6  # State management, DI, and routing
```

## 🎯 How MVVM Works with GetX

### Reactive State Management

**1. Define Observable in ViewModel:**
```dart
final _counter = CounterModel(value: 0).obs;
```

**2. Update State:**
```dart
void increment() {
  _counter.value = _counter.value.copyWith(value: counterValue + 1);
  // UI automatically updates!
}
```

**3. Observe in View:**
```dart
Obx(() => Text('${controller.counterValue}'))
```

### Dependency Injection with Bindings

**1. Create Binding:**
```dart
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounterViewModel>(() => CounterViewModel());
  }
}
```

**2. Register with Route:**
```dart
GetPage(
  name: AppRoutes.counter,
  page: () => const CounterView(),
  binding: CounterBinding(),
)
```

**3. Access in View:**
```dart
class CounterView extends GetView<CounterViewModel> {
  // controller is automatically injected
}
```

## 🎨 Features Breakdown

### Counter Feature
- **Model:** `CounterModel` - holds integer value
- **ViewModel:** `CounterViewModel` - manages counter state with `.obs`
- **View:** `CounterView` - displays counter and buttons
- **Binding:** `CounterBinding` - injects ViewModel

### Notes Feature
- **Model:** `NoteModel` - holds id, content, and timestamp
- **ViewModel:** `NotesViewModel` - manages list of notes with `.obs`
- **View:** `NotesView` - displays notes list with add/delete
- **Binding:** `NotesBinding` - injects ViewModel

### Theme Feature
- Light and dark themes using Material Design 3
- Toggle button in AppBar
- Automatic system theme detection

## 📚 Learning Resources

### MVVM Pattern
- **Model:** Data structures and business entities
- **View:** UI components that display data
- **ViewModel:** Bridge between Model and View, contains business logic

### GetX Features Used
- **Reactive State (.obs):** Observable variables for reactive UI
- **GetX Controller:** Base class for ViewModels
- **Bindings:** Dependency injection
- **GetX Navigation:** Route management with bindings
- **Obx Widget:** Reactive widget that rebuilds on state change
- **GetView:** Base View class with automatic controller injection

## 🔄 Data Flow

```
User Action (View)
    ↓
ViewModel Method Call
    ↓
Update Observable (.obs)
    ↓
Automatic UI Update (Obx)
```

## 🎓 Best Practices Demonstrated

1. ✅ **Separation of Concerns:** Clear separation between UI, logic, and data
2. ✅ **Reactive Programming:** Automatic UI updates with observables
3. ✅ **Dependency Injection:** Loose coupling using GetX bindings
4. ✅ **Clean Code:** Well-organized folder structure
5. ✅ **Immutability:** Models use `copyWith` pattern
6. ✅ **Type Safety:** Strong typing throughout the app
7. ✅ **Code Reusability:** ViewModels can be reused and tested

## 🧪 Testing

The architecture makes testing easier:

- **Unit Tests:** Test ViewModels independently
- **Widget Tests:** Test Views with mock ViewModels
- **Integration Tests:** Test complete features

## 📝 Notes

- This is a learning project demonstrating MVVM with GetX
- Focus is on architecture patterns, not complex features
- Code is well-commented for educational purposes
- Perfect for understanding reactive state management

## 🤝 Contributing

This is a study project, but suggestions are welcome!

## 📄 License

This project is for educational purposes.

---

**Built with ❤️ using Flutter and GetX**

*MVVM Architecture Pattern Demo*
