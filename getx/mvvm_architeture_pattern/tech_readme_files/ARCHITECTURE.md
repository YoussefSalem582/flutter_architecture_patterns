# MVVM Architecture Pattern with GetX

## Overview

This project demonstrates the MVVM (Model-View-ViewModel) architecture pattern in Flutter using GetX for reactive state management.

## Architecture Components

### 1. Model Layer (`/models`)

**Purpose:** Represents the data structures and business entities.

**Characteristics:**
- Pure Dart classes with no Flutter dependencies
- Immutable data structures
- Contains `toJson()` and `fromJson()` methods for serialization
- Implements `copyWith()` for creating modified copies
- No business logic, only data representation

**Files:**
- `counter_model.dart` - Represents counter data
- `note_model.dart` - Represents note data with id, content, and timestamp

**Example:**
```dart
class CounterModel {
  final int value;
  
  CounterModel({required this.value});
  
  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }
}
```

---

### 2. ViewModel Layer (`/viewmodels`)

**Purpose:** Contains business logic and reactive state management.

**Characteristics:**
- Extends `GetxController` from GetX
- Uses `.obs` (observables) for reactive state
- Contains business logic methods
- Communicates with Models
- Triggers UI updates automatically via observables
- No direct UI code or BuildContext

**Files:**
- `counter_viewmodel.dart` - Manages counter state and logic
- `notes_viewmodel.dart` - Manages notes list and operations

**Key Features:**
- **Reactive State:** Uses `.obs` to make data observable
- **Lifecycle Methods:** `onInit()`, `onClose()` for resource management
- **Business Logic:** All increment/decrement/add/delete logic lives here
- **State Updates:** Modifying observables automatically updates UI

**Example:**
```dart
class CounterViewModel extends GetxController {
  // Observable state
  final _counter = CounterModel(value: 0).obs;
  
  // Getter
  int get counterValue => _counter.value.value;
  
  // Business logic
  void increment() {
    _counter.value = _counter.value.copyWith(
      value: counterValue + 1
    );
  }
}
```

---

### 3. View Layer (`/views`)

**Purpose:** Displays UI and handles user interactions.

**Characteristics:**
- Extends `GetView<T>` for automatic controller injection
- Uses `Obx()` widget to observe reactive state
- No business logic - delegates to ViewModel
- Stateless widgets (GetX handles state)
- Calls ViewModel methods on user actions

**Files:**
- `home_view.dart` - Landing page with navigation
- `counter_view.dart` - Counter UI
- `notes_view.dart` - Notes list UI

**Key Widgets:**
- `GetView<T>` - Base class with automatic controller access
- `Obx(() => Widget)` - Reactive widget that rebuilds on state change
- Standard Flutter widgets for UI

**Example:**
```dart
class CounterView extends GetView<CounterViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Text('${controller.counterValue}')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
      ),
    );
  }
}
```

---

### 4. Bindings (`/bindings`)

**Purpose:** Dependency injection for ViewModels.

**Characteristics:**
- Extends `Bindings` from GetX
- Registers ViewModels when navigating to screens
- Uses `Get.lazyPut()` for lazy initialization
- Automatic disposal when leaving screen

**Files:**
- `counter_binding.dart` - Injects CounterViewModel
- `notes_binding.dart` - Injects NotesViewModel

**Example:**
```dart
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounterViewModel>(() => CounterViewModel());
  }
}
```

---

### 5. Routes (`/routes`)

**Purpose:** Navigation and routing configuration.

**Files:**
- `app_routes.dart` - Defines route names as constants
- `app_pages.dart` - Maps routes to pages with bindings and transitions

**Example:**
```dart
GetPage(
  name: AppRoutes.counter,
  page: () => const CounterView(),
  binding: CounterBinding(),
  transition: Transition.rightToLeft,
)
```

---

### 6. Config (`/config`)

**Purpose:** Application-wide configuration.

**Files:**
- `app_themes.dart` - Light and dark theme definitions

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
│ 2. Call ViewModel Method                             │
│    - controller.increment()                           │
│    - controller.addNote(text)                         │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 3. ViewModel Updates Observable                      │
│    - _counter.value = newValue                        │
│    - _notes.add(newNote)                              │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 4. GetX Notifies Observers                           │
│    - Automatic change detection                       │
└────────────────┬─────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────┐
│ 5. UI Updates (Obx widget rebuilds)                  │
│    - Only Obx widgets rebuild, not entire screen     │
└──────────────────────────────────────────────────────┘
```

---

## Key GetX Features Used

### 1. Reactive State Management

**`.obs` (Observable):**
```dart
final count = 0.obs;           // Observable primitive
final user = User().obs;        // Observable object
final items = <Item>[].obs;     // Observable list
```

**`Obx()` Widget:**
```dart
Obx(() => Text('$count'))  // Rebuilds when count changes
```

### 2. Dependency Injection

**Registration:**
```dart
Get.put(Controller());        // Immediate
Get.lazyPut(() => Controller());  // Lazy
```

**Access:**
```dart
final controller = Get.find<Controller>();
// Or use GetView<Controller> for automatic access
```

### 3. Navigation

**Navigate:**
```dart
Get.toNamed(AppRoutes.counter);  // Named route
Get.to(() => CounterView());      // Direct
Get.back();                       // Go back
```

**With Bindings:**
```dart
GetPage(
  name: '/counter',
  page: () => CounterView(),
  binding: CounterBinding(),
)
```

### 4. Theme Management

```dart
Get.changeThemeMode(ThemeMode.dark);
Get.isDarkMode;
```

### 5. Snackbars and Dialogs

```dart
Get.snackbar('Title', 'Message');
Get.defaultDialog(
  title: 'Title',
  middleText: 'Content',
);
```

---

## Benefits of MVVM with GetX

### 1. **Separation of Concerns**
- UI (View) is separated from business logic (ViewModel)
- Models contain only data structures
- Each layer has a single responsibility

### 2. **Testability**
- ViewModels can be unit tested without UI
- Views can be widget tested with mock ViewModels
- Models can be tested independently

### 3. **Reactive UI**
- Automatic UI updates when data changes
- No manual `setState()` calls
- Efficient rebuilds (only Obx widgets)

### 4. **Dependency Injection**
- Loose coupling between components
- Easy to swap implementations
- Automatic lifecycle management

### 5. **Code Reusability**
- ViewModels can be shared across platforms
- Models are pure Dart (no Flutter dependency)
- Business logic is centralized

### 6. **Maintainability**
- Clear architecture pattern
- Easy to locate code
- Scalable for large applications

---

## Comparison with Other Patterns

| Feature | MVVM + GetX | MVC | BLoC | Provider |
|---------|-------------|-----|------|----------|
| Learning Curve | Easy | Easy | Medium | Easy |
| Boilerplate | Low | Medium | High | Medium |
| Reactive | Yes | No | Yes | Yes |
| DI Built-in | Yes | No | No | No |
| Navigation | Built-in | Manual | Manual | Manual |
| State Management | Reactive | Manual | Streams | ChangeNotifier |

---

## Best Practices

### 1. **Keep Views Dumb**
- Views should only display data and handle user input
- No business logic in Views
- Delegate everything to ViewModel

### 2. **Keep Models Pure**
- No business logic in Models
- Only data structures and methods to manipulate them
- No Flutter dependencies

### 3. **Use Observables Wisely**
- Make data observable at the right level
- Avoid over-observing (performance)
- Use `Obx()` only where needed

### 4. **Proper Disposal**
- Use `onClose()` in ViewModels to clean up resources
- GetX handles disposal automatically with bindings

### 5. **Naming Conventions**
- Private observables: `_counter`
- Public getters: `counter` or `counterValue`
- Methods: `increment()`, `addNote()`, etc.

### 6. **Use Bindings**
- Always use bindings for dependency injection
- Don't use `Get.put()` directly in Views
- Lazy loading for better performance

---

## Testing Strategy

### Unit Tests (ViewModels)
```dart
test('increment increases counter', () {
  final vm = CounterViewModel();
  vm.increment();
  expect(vm.counterValue, 1);
});
```

### Widget Tests (Views)
```dart
testWidgets('displays counter value', (tester) async {
  Get.put(CounterViewModel());
  await tester.pumpWidget(CounterView());
  expect(find.text('0'), findsOneWidget);
});
```

---

## Conclusion

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Reactive UI updates
- ✅ Easy testing
- ✅ Minimal boilerplate
- ✅ Scalability
- ✅ Maintainability

Perfect for small to large Flutter applications!
