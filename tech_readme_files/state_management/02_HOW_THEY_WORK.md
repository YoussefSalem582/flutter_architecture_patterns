# 2️⃣ How They Work

**Read Time:** ⏱️ 10 minutes

---

## 🏗️ BLoC Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                       UI LAYER                          │
│         BlocBuilder / BlocListener / BlocConsumer       │
│                    (Widgets)                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Listens to Stream
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    BLOC / CUBIT                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - Receives Events (Bloc) or                    │  │
│  │    Method Calls (Cubit)                         │  │
│  │  - Processes Business Logic                     │  │
│  │  - Emits New States                             │  │
│  └─────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Emits via Stream
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                  STATE STREAM                           │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - StreamController under the hood              │  │
│  │  - Immutable State Objects                      │  │
│  │  - State History Tracking                       │  │
│  │  - Time-Travel Debugging                        │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Event/Method → BLoC Logic → Emit State → Stream → UI Updates
```

---

## 🔧 BLoC: Core Concepts

### 1. **States** (What the UI Shows)

States represent the UI's condition at any moment:

```dart
// Explicit state definitions
abstract class CounterState extends Equatable {
  const CounterState();
}

class CounterInitial extends CounterState {
  const CounterInitial();
  @override
  List<Object> get props => [];
}

class CounterLoading extends CounterState {
  const CounterLoading();
  @override
  List<Object> get props => [];
}

class CounterLoaded extends CounterState {
  final int count;
  const CounterLoaded(this.count);
  @override
  List<Object> get props => [count];
}

class CounterError extends CounterState {
  final String message;
  const CounterError(this.message);
  @override
  List<Object> get props => [message];
}
```

**Benefits:**
- ✅ Clear representation of all possible states
- ✅ Easy to test each state
- ✅ Type-safe
- ✅ Compile-time safety

---

### 2. **Events** (Bloc Only - What Happens)

Events represent user actions:

```dart
abstract class CounterEvent extends Equatable {}

class IncrementPressed extends CounterEvent {
  @override
  List<Object> get props => [];
}

class DecrementPressed extends CounterEvent {
  @override
  List<Object> get props => [];
}

class ResetPressed extends CounterEvent {
  @override
  List<Object> get props => [];
}
```

---

### 3. **Bloc** (Event Handler)

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterInitial()) {
    // Register event handlers
    on<IncrementPressed>(_onIncrement);
    on<DecrementPressed>(_onDecrement);
    on<ResetPressed>(_onReset);
  }
  
  void _onIncrement(IncrementPressed event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      emit(CounterLoaded(currentState.count + 1));
    } else {
      emit(const CounterLoaded(1));
    }
  }
  
  void _onDecrement(DecrementPressed event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      if (currentState.count > 0) {
        emit(CounterLoaded(currentState.count - 1));
      }
    }
  }
  
  void _onReset(ResetPressed event, Emitter<CounterState> emit) {
    emit(const CounterLoaded(0));
  }
}
```

---

### 4. **Cubit** (Simplified Bloc - No Events)

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => state > 0 ? emit(state - 1) : null;
  void reset() => emit(0);
}
```

**Cubit vs Bloc:**
- Cubit: Simpler, direct methods, no events
- Bloc: More complex, events for every action, better traceability

---

### 5. **UI Integration**

```dart
// BlocBuilder - Rebuilds on state changes
BlocBuilder<CounterCubit, int>(
  builder: (context, count) {
    return Text('Count: $count');
  },
)

// BlocListener - Executes side effects
BlocListener<CounterCubit, int>(
  listener: (context, count) {
    if (count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  child: Container(),
)

// BlocConsumer - Both builder and listener
BlocConsumer<CounterCubit, int>(
  listener: (context, count) {
    // Side effects
  },
  builder: (context, count) {
    // UI
    return Text('$count');
  },
)
```

---

### 6. **Streams Under the Hood**

```dart
// BLoC uses Dart Streams
Stream<CounterState> get stream => _stateController.stream;

// When you emit()
void emit(CounterState state) {
  _stateController.add(state);  // Adds to stream
}

// UI listens to stream
stream.listen((state) {
  // Update UI
});
```

---

## ⚡ GetX Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                       UI LAYER                          │
│            Obx() / GetX<T>() / GetBuilder<T>()         │
│                    (Widgets)                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Observes Reactive Variables
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                   CONTROLLER                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - GetxController                                │  │
│  │  - Reactive Variables (.obs)                     │  │
│  │  - Business Logic Methods                        │  │
│  │  - Automatic Dependency Management               │  │
│  └─────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Notifies Observers
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│              REACTIVE VARIABLES (Rx)                    │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - RxInt, RxString, RxBool, Rx<T>               │  │
│  │  - Observer Pattern (not streams)                │  │
│  │  - Automatic Listener Registration              │  │
│  │  - Smart Rebuilds                                │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Controller Method → Update .obs Variable → Notify Observers → UI Updates
```

---

## 🔧 GetX: Core Concepts

### 1. **Reactive Variables** (.obs)

```dart
// Create reactive variables
final count = 0.obs;              // RxInt
final name = 'John'.obs;          // RxString
final isLoading = false.obs;      // RxBool
final user = User().obs;          // Rx<User>
final items = <String>[].obs;     // RxList

// Update values
count.value = 10;
name.value = 'Jane';
isLoading.value = true;
user.value = User(name: 'Alice');
items.add('New Item');

// Get values
print(count.value);  // 10
```

**Behind the Scenes:**
```dart
// .obs creates a reactive wrapper
class Rx<T> {
  T _value;
  final _listeners = <Function>[];
  
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    _notifyListeners();  // Tells all observers
  }
  
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
```

---

### 2. **Controllers**

```dart
class CounterController extends GetxController {
  // Reactive variables
  final count = 0.obs;
  final isLoading = false.obs;
  
  // Business logic methods
  void increment() {
    count.value++;
  }
  
  void decrement() {
    if (count.value > 0) {
      count.value--;
    }
  }
  
  void reset() {
    count.value = 0;
  }
  
  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    print('Controller initialized');
    // Load initial data
  }
  
  @override
  void onReady() {
    super.onReady();
    print('Controller ready');
    // Called after build
  }
  
  @override
  void onClose() {
    // Cleanup
    print('Controller disposed');
    super.onClose();
  }
}
```

---

### 3. **Observers** (UI Updates)

```dart
// Obx - Automatically rebuilds when observed variables change
Obx(() => Text('${controller.count}'))

// Multiple variables
Obx(() {
  return Column(
    children: [
      Text('Count: ${controller.count}'),
      Text('Name: ${controller.name}'),
    ],
  );
})

// GetX widget - with controller injection
GetX<CounterController>(
  init: CounterController(),
  builder: (controller) {
    return Text('${controller.count}');
  },
)

// GetBuilder - Manual updates (better performance)
GetBuilder<CounterController>(
  builder: (controller) {
    return Text('${controller.count}');
  },
)
// Call controller.update() to rebuild
```

---

### 4. **Dependency Injection**

```dart
// Put instance (created immediately)
Get.put(CounterController());

// Lazy put (created when first used)
Get.lazyPut(() => CounterController());

// Put async
Get.putAsync(() async => await CounterController.init());

// Permanent (survives route changes)
Get.put(UserController(), permanent: true);

// Find instance
final controller = Get.find<CounterController>();

// Delete instance
Get.delete<CounterController>();

// Check if exists
if (Get.isRegistered<CounterController>()) {
  // Controller exists
}
```

---

### 5. **Bindings** (Organized DI)

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy injection
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ProductController());
    Get.lazyPut(() => CartController());
  }
}

// Use in routing
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)
```

---

### 6. **Reactive Streams** (Workers)

```dart
class UserController extends GetxController {
  final user = User().obs;
  final isOnline = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // ever - Called every time variable changes
    ever(user, (_) {
      print('User changed: ${user.value.name}');
    });
    
    // once - Called only the first time variable changes
    once(isOnline, (_) {
      print('User came online!');
    });
    
    // debounce - Wait for pause in changes (good for search)
    debounce(user, (_) {
      print('User settled: ${user.value.name}');
    }, time: Duration(seconds: 1));
    
    // interval - Ignore changes within interval
    interval(user, (_) {
      print('User updated (max once per second)');
    }, time: Duration(seconds: 1));
  }
}
```

---

## 🌊 Riverpod Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                       UI LAYER                          │
│           Consumer / ConsumerWidget / ConsumerStateful  │
│                    (Widgets)                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Watches Providers (ref.watch)
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                   PROVIDERS                             │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - StateProvider / FutureProvider / StreamProvider │
│  │  - StateNotifierProvider / NotifierProvider      │
│  │  - AsyncNotifierProvider                         │
│  │  - Global State Management                       │
│  └─────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Manages State
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                     STATE                               │
│  ┌─────────────────────────────────────────────────┐  │
│  │  - Immutable State Objects                      │  │
│  │  - AsyncValue (Loading, Error, Data)            │  │
│  │  - Cached & Disposed Automatically              │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → ref.read(provider.notifier).method() → Update State → Notify Consumers → UI Updates
```

---

## 🔧 Riverpod: Core Concepts

### 1. **Providers** (The Source of Truth)

Providers are global constants that declare how to create state.

```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Complex state logic
final counterNotifierProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

// Async data
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});

// Stream data
final chatProvider = StreamProvider<List<Message>>((ref) {
  return chatStream();
});
```

---

### 2. **Notifiers** (Business Logic)

```dart
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0; // Initial state

  void increment() => state++;
  void decrement() => state--;
}
```

---

### 3. **Consumers** (UI Integration)

```dart
// ConsumerWidget - Most common
class CounterView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch: Rebuilds when state changes
    final count = ref.watch(counterProvider);
    
    return Scaffold(
      body: Text('$count'),
      floatingActionButton: FloatingActionButton(
        // Read: Access without listening (for callbacks)
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

### 4. **AsyncValue** (Handling Loading/Error)

Riverpod handles async states gracefully:

```dart
final userAsync = ref.watch(userProvider);

return userAsync.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

### 5. **Modifiers** (Power Features)

```dart
// .autoDispose - Cleans up state when not used
final autoDisposeProvider = StateProvider.autoDispose((ref) => 0);

// .family - Pass arguments to providers
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  return await fetchUser(userId);
});
```

---

## 🔄 Comparison of Mechanisms

### BLoC (Streams)
- **Mechanism:** `StreamController` + `StreamBuilder`
- **Pros:** Powerful, standard Dart streams
- **Cons:** Verbose, requires closing streams (handled by Bloc)

### GetX (Observer)
- **Mechanism:** `ValueNotifier`-like observables (`.obs`)
- **Pros:** Simple, granular updates
- **Cons:** Global mutable state, less safe

### Riverpod (Providers)
- **Mechanism:** `ProviderElement` tree (independent of Widget tree)
- **Pros:** Compile-time safe, composable, no `BuildContext` needed
- **Cons:** "Global" variables (but scoped internally), learning curve

---

## 📊 Comparison Summary

| Aspect | BLoC | GetX | Riverpod |
|--------|------|------|----------|
| **Mechanism** | Dart Streams | Observer Pattern | Provider Graph |
| **State Definition** | Explicit classes | Reactive variables | Providers & Notifiers |
| **Events** | Required (Bloc) | Not needed | Methods on Notifier |
| **Code Verbosity** | High | Low | Moderate |
| **Type Safety** | Excellent | Good | Excellent |
| **Learning Curve** | Steep | Gentle | Moderate |
| **Debugging** | State history | Current state | DevTools support |
| **Performance** | Excellent | Excellent | Excellent |

---

## 🎓 Key Takeaways

### BLoC:
- 📊 **Stream-based** reactive programming
- 🎯 **Explicit state** definitions
- 🏢 **Ideal** for enterprise & strict architecture

### GetX:
- 👁️ **Observer pattern** for reactivity
- ⚡ **Implicit state** with .obs variables
- 🏃 **Ideal** for rapid development & MVPs

### Riverpod:
- 🌊 **Provider-based** state management
- 🛡️ **Compile-time safety** & no context dependency
- 🧩 **Ideal** for scalable, modern apps

---

**All three achieve the same goal: Reactive UI that updates when state changes!**

The choice depends on your team, project, and preferences.

---

**[← Previous: Overview](./01_OVERVIEW.md)** | **[Next: Architecture Integration →](./03_ARCHITECTURE_INTEGRATION.md)**

---

**Last Updated:** November 27, 2025
