# Counter Notes App - MVC Pattern with Riverpod

A Flutter application demonstrating the **Model-View-Controller (MVC)** architecture pattern using **Riverpod** for state management.

##  App Overview

Counter Notes App is a simple yet comprehensive example of MVC pattern implementation with two main features:

1. **Counter Screen**: Increment, decrement, and reset a counter
2. **Notes Screen**: Add, delete, and list simple text notes

##  Architecture: MVC Pattern

### Model Layer (lib/models/)
- **Purpose**: Holds data classes and data structures
- **Files**:
  - counter_model.dart - Counter data structure with value and methods
  - 
ote_model.dart - Note data structure with id, content, and timestamp

### View Layer (lib/views/)
- **Purpose**: Contains UI widgets only (no business logic)
- **Files**:
  - home_view.dart - Landing page with navigation
  - counter_view.dart - UI for counter screen
  - 
otes_view.dart - UI for notes screen

### Controller Layer (lib/controllers/)
- **Purpose**: Manages business logic and state using Riverpod StateNotifier
- **Files**:
  - counter_controller.dart - Counter logic and state management
  - 
otes_controller.dart - Notes logic and CRUD operations
  - 	heme_controller.dart - Theme switching logic

##  Key Features

### Counter Screen
-  Increment counter
-  Decrement counter
-  Reset counter to zero
-  Real-time counter display
-  Persistent storage (survives app restart)
-  Snackbar notifications

### Notes Screen
-  Add new notes
-  Delete individual notes
-  Clear all notes with confirmation
-  Display note count
-  Timestamp with relative time display
-  Persistent storage (survives app restart)

### Global Features
-  Light/Dark theme switching
-  Smooth navigation transitions
-  Responsive UI design
-  Material Design 3

##  Dependencies

`yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.4.9  # Riverpod for state management
  shared_preferences: ^2.2.2 # Local persistent storage
  equatable: ^2.0.5         # Value equality
``r

##  Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)

### Installation

1. **Install dependencies**:
   `ash
   flutter pub get
   ` 

2. **Run the app**:
   `ash
   flutter pub run
   ` 

##  Project Structure

` 
lib/
 main.dart                      # App entry point and Riverpod configuration
 models/                        # Model layer - Data structures
    counter_model.dart
    note_model.dart
 views/                         # View layer - UI widgets
    home_view.dart
    counter_view.dart
    notes_view.dart
 controllers/                   # Controller layer - Business logic
     counter_controller.dart
     notes_controller.dart
     theme_controller.dart
` 

##  Understanding MVC with Riverpod

### How Riverpod Fits into MVC

1. **Model (M)**: Pure data classes
   `dart
   class CounterModel {
     final int value;
     const CounterModel({this.value = 0});
   }
   ` 

2. **Controller (C)**: StateNotifier manages state
   `dart
   class CounterController extends StateNotifier<CounterModel> {
     CounterController() : super(const CounterModel());
     
     void increment() {
       state = CounterModel(value: state.value + 1);
     }
   }
   
   final counterProvider = StateNotifierProvider<CounterController, CounterModel>((ref) {
     return CounterController();
   });
   ` 

3. **View (V)**: ConsumerWidgets observe provider state
   `dart
   class CounterView extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final counter = ref.watch(counterProvider);
       return Text('');
     }
   }
   ` 

### Key Riverpod Features Used

- **StateNotifier**: For managing complex state logic
- **Providers**: For dependency injection and state access
- **ConsumerWidget**: For reactive UI updates
- **ref.watch**: To listen to state changes
- **ref.read**: To access methods without listening
- **ref.listen**: To perform side effects (snackbars)

### Separation of Concerns

 **Good Practice - Following MVC**:
- Models contain only data and data operations
- Controllers handle all business logic
- Views only contain UI code and observe providers

##  License

This project is created for educational purposes to demonstrate MVC pattern with Riverpod in Flutter.

---

**Built with**  **using Flutter & Riverpod**
