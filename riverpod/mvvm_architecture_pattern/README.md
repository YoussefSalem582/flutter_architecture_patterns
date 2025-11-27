# Counter Notes App - MVVM Pattern with Riverpod

A Flutter application demonstrating the **Model-View-ViewModel (MVVM)** architecture pattern using **Riverpod** for state management.

##  App Overview

Counter Notes App is a simple yet comprehensive example of MVVM pattern implementation with two main features:

1. **Counter Screen**: Increment, decrement, and reset a counter
2. **Notes Screen**: Add, delete, and list simple text notes

##  Architecture: MVVM Pattern

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

### ViewModel Layer (lib/viewmodels/)
- **Purpose**: Exposes state to the View and handles business logic
- **Files**:
  - counter_viewmodel.dart - Counter logic and state management
  - 
otes_viewmodel.dart - Notes logic and CRUD operations
  - 	heme_viewmodel.dart - Theme switching logic

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
 viewmodels/                    # ViewModel layer - Business logic
     counter_viewmodel.dart
     notes_viewmodel.dart
     theme_viewmodel.dart
` 

##  Understanding MVVM with Riverpod

### How Riverpod Fits into MVVM

1. **Model (M)**: Pure data classes
   `dart
   class CounterModel {
     final int value;
     const CounterModel({this.value = 0});
   }
   ` 

2. **ViewModel (VM)**: StateNotifier exposes state
   `dart
   class CounterViewModel extends StateNotifier<CounterModel> {
     CounterViewModel() : super(const CounterModel());
     
     void increment() {
       state = CounterModel(value: state.value + 1);
     }
   }
   
   final counterViewModelProvider = StateNotifierProvider<CounterViewModel, CounterModel>((ref) {
     return CounterViewModel();
   });
   ` 

3. **View (V)**: ConsumerWidgets observe provider state
   `dart
   class CounterView extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final counter = ref.watch(counterViewModelProvider);
       return Text('');
     }
   }
   ` 

### Key Differences from MVC

- **ViewModel vs Controller**: In MVVM, the ViewModel is more focused on exposing the state specifically for the View to consume. It acts as a binder between Model and View.
- **Data Binding**: Riverpod's ef.watch acts as a one-way data binding mechanism, updating the View whenever the ViewModel's state changes.

##  License

This project is created for educational purposes to demonstrate MVVM pattern with Riverpod in Flutter.

---

**Built with**  **using Flutter & Riverpod**
