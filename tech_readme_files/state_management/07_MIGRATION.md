# 7️⃣ Migration Guide

**Read Time:** ⏱️ 10 minutes

Step-by-step guide for migrating between BLoC and GetX.

---

## 🔄 BLoC to GetX Migration

### Why Migrate?
- ✅ Reduce boilerplate code (40-60% reduction)
- ✅ Faster development speed
- ✅ Simpler architecture
- ✅ Built-in routing and DI

### Migration Difficulty: ⭐⭐ Moderate

---

### Step 1: Add GetX Dependencies

```yaml
# pubspec.yaml
dependencies:
  # Remove or keep BLoC temporarily
  # flutter_bloc: ^8.1.3  # Can coexist during migration
  # hydrated_bloc: ^9.1.2
  
  # Add GetX
  get: ^4.6.6
  get_storage: ^2.1.1
```

Run: `flutter pub get`

---

### Step 2: Convert State Classes to Reactive Variables

**Before (BLoC):**
```dart
// State classes
abstract class CounterState extends Equatable {}

class CounterInitial extends CounterState {
  @override
  List<Object> get props => [];
}

class CounterLoaded extends CounterState {
  final int count;
  CounterLoaded(this.count);
  @override
  List<Object> get props => [count];
}

class CounterLoading extends CounterState {
  @override
  List<Object> get props => [];
}

class CounterError extends CounterState {
  final String message;
  CounterError(this.message);
  @override
  List<Object> get props => [message];
}
```

**After (GetX):**
```dart
// No separate state classes needed
class CounterController extends GetxController {
  final count = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // State is managed through reactive variables
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isInitial => count.value == 0 && !isLoading.value;
}
```

---

### Step 3: Convert Cubit/Bloc to Controller

**Before (BLoC):**
```dart
class CounterCubit extends Cubit<CounterState> {
  final CounterRepository repository;
  
  CounterCubit({required this.repository}) : super(CounterInitial());
  
  Future<void> loadCounter() async {
    emit(CounterLoading());
    try {
      final count = await repository.getCount();
      emit(CounterLoaded(count));
    } catch (e) {
      emit(CounterError(e.toString()));
    }
  }
  
  void increment() {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      emit(CounterLoaded(currentState.count + 1));
    }
  }
}
```

**After (GetX):**
```dart
class CounterController extends GetxController {
  final CounterRepository repository;
  
  CounterController({required this.repository});
  
  final count = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }
  
  Future<void> loadCounter() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      count.value = await repository.getCount();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  void increment() => count.value++;
}
```

---

### Step 4: Convert BlocBuilder to Obx

**Before (BLoC):**
```dart
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) {
    if (state is CounterLoading) {
      return CircularProgressIndicator();
    }
    if (state is CounterLoaded) {
      return Text('${state.count}');
    }
    if (state is CounterError) {
      return Text('Error: ${state.message}');
    }
    return Container();
  },
)
```

**After (GetX):**
```dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  if (controller.hasError) {
    return Text('Error: ${controller.errorMessage}');
  }
  return Text('${controller.count}');
})
```

---

### Step 5: Convert BlocListener to Workers

**Before (BLoC):**
```dart
BlocListener<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state is CounterLoaded && state.count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  child: Container(),
)
```

**After (GetX):**
```dart
class CounterController extends GetxController {
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Listen for specific values
    ever(count, (value) {
      if (value == 10) {
        Get.snackbar('Milestone', 'Reached 10!');
      }
    });
  }
}
```

---

### Step 6: Convert Navigation

**Before (BLoC):**
```dart
// Push
Navigator.of(context).pushNamed('/details');

// Push with arguments
Navigator.of(context).pushNamed(
  '/details',
  arguments: {'id': 123},
);

// Pop
Navigator.of(context).pop();
```

**After (GetX):**
```dart
// Push
Get.toNamed('/details');

// Push with arguments
Get.toNamed('/details', arguments: {'id': 123});

// Pop
Get.back();

// Named routes with bindings
GetPage(
  name: '/details',
  page: () => DetailsView(),
  binding: DetailsBinding(),
)
```

---

### Step 7: Convert Dependency Injection

**Before (BLoC with get_it):**
```dart
// Setup
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<CounterRepository>(
    CounterRepositoryImpl(),
  );
  getIt.registerFactory<CounterCubit>(
    () => CounterCubit(repository: getIt()),
  );
}

// Usage
final cubit = getIt<CounterCubit>();
```

**After (GetX):**
```dart
// Setup with Bindings
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounterRepository>(() => CounterRepositoryImpl());
    Get.lazyPut(() => CounterController(repository: Get.find()));
  }
}

// Usage
final controller = Get.find<CounterController>();

// Or in widget
final controller = Get.put(CounterController(repository: Get.find()));
```

---

### Step 8: Convert State Persistence

**Before (BLoC):**
```dart
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  
  @override
  int? fromJson(Map<String, dynamic> json) {
    return json['value'] as int;
  }
  
  @override
  Map<String, dynamic>? toJson(int state) {
    return {'value': state};
  }
}
```

**After (GetX):**
```dart
class CounterController extends GetxController {
  final _storage = GetStorage();
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load from storage
    count.value = _storage.read('count') ?? 0;
    
    // Save on change
    ever(count, (value) {
      _storage.write('count', value);
    });
  }
}
```

---

### Migration Checklist

- [ ] Add GetX dependencies
- [ ] Convert state classes to reactive variables
- [ ] Convert Cubits/Blocs to Controllers
- [ ] Replace BlocBuilder with Obx
- [ ] Replace BlocListener with workers
- [ ] Update navigation calls
- [ ] Set up Bindings for DI
- [ ] Convert state persistence
- [ ] Update tests
- [ ] Remove BLoC dependencies (when done)

---

## 🔄 GetX to BLoC Migration

### Why Migrate?
- ✅ Better type safety
- ✅ Explicit state management
- ✅ Superior testing infrastructure
- ✅ Better for large teams

### Migration Difficulty: ⭐⭐⭐ Complex

---

### Step 1: Add BLoC Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  hydrated_bloc: ^9.1.2
  equatable: ^2.0.5
  
  # Keep GetX temporarily for gradual migration
  # get: ^4.6.6
```

---

### Step 2: Define State Classes

**Before (GetX):**
```dart
class CounterController extends GetxController {
  final count = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
}
```

**After (BLoC):**
```dart
// Define all possible states
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

---

### Step 3: Create Cubit/Bloc

**After (BLoC):**
```dart
class CounterCubit extends Cubit<CounterState> {
  final CounterRepository repository;
  
  CounterCubit({required this.repository}) 
      : super(const CounterInitial());
  
  Future<void> loadCounter() async {
    emit(const CounterLoading());
    try {
      final count = await repository.getCount();
      emit(CounterLoaded(count));
    } catch (e) {
      emit(CounterError(e.toString()));
    }
  }
  
  void increment() {
    if (state is CounterLoaded) {
      final currentCount = (state as CounterLoaded).count;
      emit(CounterLoaded(currentCount + 1));
    }
  }
}
```

---

### Step 4: Convert Obx to BlocBuilder

**Before (GetX):**
```dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  return Text('${controller.count}');
})
```

**After (BLoC):**
```dart
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) {
    if (state is CounterLoading) {
      return CircularProgressIndicator();
    }
    if (state is CounterLoaded) {
      return Text('${state.count}');
    }
    return Container();
  },
)
```

---

### Step 5: Convert Workers to BlocListener

**Before (GetX):**
```dart
ever(count, (value) {
  if (value == 10) {
    Get.snackbar('Milestone', 'Reached 10!');
  }
});
```

**After (BLoC):**
```dart
BlocListener<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state is CounterLoaded && state.count == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reached 10!')),
      );
    }
  },
  child: Container(),
)
```

---

### Step 6: Set Up Dependency Injection

**After (BLoC with get_it):**
```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(),
  );
  
  // Cubits
  getIt.registerFactory<CounterCubit>(
    () => CounterCubit(repository: getIt()),
  );
}

// In main.dart
void main() {
  setupDependencies();
  runApp(MyApp());
}
```

---

### Migration Checklist

- [ ] Add BLoC dependencies
- [ ] Define state classes for each feature
- [ ] Create Cubits/Blocs
- [ ] Replace Obx with BlocBuilder
- [ ] Replace workers with BlocListener
- [ ] Set up dependency injection (get_it)
- [ ] Update navigation (if using GetX routing)
- [ ] Convert storage (GetStorage → HydratedBloc)
- [ ] Update all tests
- [ ] Remove GetX dependencies (when done)

---

## 🎯 Migration Strategy

### Gradual Migration (Recommended)

**Week 1-2:**
- Set up new state manager
- Migrate 1-2 simple features
- Test thoroughly

**Week 3-4:**
- Migrate complex features
- Update tests
- Fix any issues

**Week 5-6:**
- Complete remaining features
- Remove old dependencies
- Final testing

---

### Big Bang Migration (Not Recommended)

Migrating everything at once is risky:
- ❌ High chance of bugs
- ❌ Difficult to test
- ❌ Team disruption
- ❌ Longer downtime

Only do this for very small apps (< 10 screens)

---

## 💡 Migration Tips

### 1. Test Each Migration
```dart
// Write tests before migrating
test('counter increments', () {
  // This test should pass with both implementations
});
```

### 2. Use Feature Flags
```dart
const useBLoC = true;

Widget build(BuildContext context) {
  return useBLoC 
    ? BlocBuilder<CounterCubit, CounterState>(...)
    : Obx(() => ...);
}
```

### 3. Migrate by Feature
Don't migrate by layer. Migrate complete features:
- ✅ Counter feature (all layers)
- ✅ Notes feature (all layers)
- ❌ All controllers first (incomplete features)

### 4. Keep Both Temporarily
You can run BLoC and GetX side-by-side during migration

---

## ⚠️ Common Pitfalls

### BLoC → GetX

**Pitfall 1:** Forgetting to dispose
```dart
// GetX controllers need disposal
@override
void onClose() {
  // Clean up
  super.onClose();
}
```

**Pitfall 2:** Not using .value
```dart
// Wrong
Text('${controller.count}')

// Correct
Text('${controller.count.value}')
```

---

### GetX → BLoC

**Pitfall 1:** Missing state checks
```dart
// Wrong - will crash if state is not CounterLoaded
final count = (state as CounterLoaded).count;

// Correct
if (state is CounterLoaded) {
  final count = state.count;
}
```

**Pitfall 2:** Forgetting Equatable
```dart
// Wrong - will rebuild unnecessarily
class CounterLoaded extends CounterState {
  final int count;
  CounterLoaded(this.count);
}

// Correct
class CounterLoaded extends CounterState {
  final int count;
  CounterLoaded(this.count);
  
  @override
  List<Object> get props => [count];
}
```

---

## 📊 Migration Time Estimates

| App Size | To GetX | To Riverpod | To BLoC |
|----------|---------|-------------|---------|
| **Small (5-10 screens)** | 1 week | 1-2 weeks | 2 weeks |
| **Medium (10-50 screens)** | 2-4 weeks | 3-5 weeks | 4-8 weeks |
| **Large (50+ screens)** | 1-3 months | 2-4 months | 2-4 months |

---

## ✅ Post-Migration Checklist

- [ ] All features working correctly
- [ ] All tests passing
- [ ] Performance verified
- [ ] Memory usage checked
- [ ] Build size acceptable
- [ ] Team trained on new approach
- [ ] Documentation updated
- [ ] Old dependencies removed
- [ ] CI/CD updated
- [ ] Code review completed

---

## 🎓 Key Takeaways

### Migration is Possible
- ✅ Both directions are feasible
- ✅ Can be done gradually
- ✅ Doesn't require full rewrite

### Plan Carefully
- ✅ Estimate time correctly
- ✅ Test thoroughly
- ✅ Migrate feature-by-feature
- ✅ Keep team informed

### Consider Alternatives
- ✅ Hybrid approach
- ✅ Keep current solution if working
- ✅ Migrate only new features

---

**[← Previous: Decision Guide](./06_DECISION_GUIDE.md)** | **[Back to Navigation](../STATE_MANAGEMENT_COMPARISON.md)**

---

**Last Updated:** November 12, 2025
