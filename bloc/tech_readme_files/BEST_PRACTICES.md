# 🎯 Best Practices Guide for Flutter Architecture Patterns

This guide covers best practices for working with different architecture patterns in Flutter, based on the implementations in this repository.

## 📋 Table of Contents
- [General Flutter Best Practices](#general-flutter-best-practices)
- [MVC Best Practices](#mvc-best-practices)
- [MVVM Best Practices](#mvvm-best-practices)
- [Clean Architecture Best Practices](#clean-architecture-best-practices)
- [DDD Best Practices](#ddd-best-practices)
- [State Management with BLoC](#state-management-with-bloc)
- [Code Organization](#code-organization)
- [Testing Best Practices](#testing-best-practices)
- [Performance Optimization](#performance-optimization)
- [Security Best Practices](#security-best-practices)

---

## 🌟 General Flutter Best Practices

### 1. **Widget Composition**

✅ **DO**: Break down complex widgets into smaller, reusable components
```dart
// Good - Composable and reusable
class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 64),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}
```

❌ **DON'T**: Create monolithic widgets with deep nesting
```dart
// Bad - Too complex, hard to maintain
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            child: InkWell(
              onTap: () => Get.toNamed('/counter'),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // 50+ lines of nested widgets here...
                  ],
                ),
              ),
            ),
          ),
          // More complex nested widgets...
        ],
      ),
    );
  }
}
```

### 2. **Const Constructors**

✅ **DO**: Use const constructors wherever possible
```dart
// Good - Improves performance
const SizedBox(height: 16)
const Padding(padding: EdgeInsets.all(24.0))
const Text('Hello')
```

❌ **DON'T**: Miss optimization opportunities
```dart
// Bad - Unnecessary widget rebuilds
SizedBox(height: 16)
Padding(padding: EdgeInsets.all(24.0))
```

### 3. **Null Safety**

✅ **DO**: Use null-safe code
```dart
// Good
String? name;
int counter = 0;
List<Note> notes = [];

// Safe null checks
if (name != null) {
  print(name.length);
}

// Null-aware operators
String displayName = name ?? 'Anonymous';
```

❌ **DON'T**: Use late initialization without null checks
```dart
// Bad - Can cause runtime errors
late String name;
print(name.length); // Runtime error if not initialized
```

### 4. **Error Handling**

✅ **DO**: Handle errors gracefully
```dart
// Good
Future<void> saveNote(Note note) async {
  try {
    await repository.save(note);
    // Show success message using ScaffoldMessenger or a custom notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note saved')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save note: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

❌ **DON'T**: Ignore potential errors
```dart
// Bad
Future<void> saveNote(Note note) async {
  await repository.save(note); // What if this fails?
  Get.snackbar('Success', 'Note saved');
}
```

### 5. **Asset Management**

✅ **DO**: Organize assets properly
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
```

### 6. **Dependency Management**

✅ **DO**: Keep dependencies up to date
```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.3  # Specify versions
  hydrated_bloc: ^9.1.2
  equatable: ^2.0.5
```

❌ **DON'T**: Use outdated or unspecified versions
```yaml
# Bad
dependencies:
  flutter_bloc: any  # Don't use 'any'
```

---

## 📦 MVC Best Practices

### 1. **Clear Separation of Concerns**

✅ **DO**: Keep Model, View, and Controller separate
```dart
// Model - Data only
class CounterModel {
  int value;
  CounterModel({this.value = 0});
}

// Controller - Business logic (using Cubit)
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitial());
  
  final CounterModel _model = CounterModel();
  
  int get counter => _model.value;
  
  void increment() {
    _model.value++;
    emit(CounterUpdated(_model.value));
  }
}

// View - UI only
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        if (state is CounterUpdated) {
          return Text('${state.value}');
        }
        return Text('0');
      },
    );
  }
}
```

### 2. **Cubit/BLoC Lifecycle**

✅ **DO**: Clean up resources in close
```dart
class CounterCubit extends Cubit<CounterState> {
  late Timer _timer;

  CounterCubit() : super(CounterInitial()) {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // Update state
    });
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
```

### 3. **When to Use MVC**

✅ **Use MVC when:**
- Building small to medium apps (< 10 screens)
- Rapid prototyping
- Learning Flutter
- Simple business logic
- Personal projects

❌ **Avoid MVC when:**
- Complex business rules
- Multiple teams working
- High testability requirements
- Enterprise applications

---

## 🔄 MVVM Best Practices

### 1. **ViewModel Responsibilities**

✅ **DO**: Keep ViewModels focused on presentation logic
```dart
// Good - ViewModel handles presentation logic (using Cubit)
class CounterViewModel extends Cubit<CounterViewState> {
  CounterViewModel() : super(CounterViewState.initial());

  Future<void> increment() async {
    emit(state.copyWith(isLoading: true));
    try {
      final newValue = state.counter + 1;
      await _saveToStorage(newValue);
      emit(state.copyWith(counter: newValue, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _saveToStorage(int value) async {
    // Save using shared_preferences or hive
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', value);
  }
}

// State class
class CounterViewState extends Equatable {
  final int counter;
  final bool isLoading;
  final String errorMessage;

  const CounterViewState({
    required this.counter,
    required this.isLoading,
    required this.errorMessage,
  });

  factory CounterViewState.initial() => const CounterViewState(
    counter: 0,
    isLoading: false,
    errorMessage: '',
  );

  CounterViewState copyWith({
    int? counter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CounterViewState(
      counter: counter ?? this.counter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [counter, isLoading, errorMessage];
}
```

### 2. **State Management**

✅ **DO**: Use immutable states
```dart
// Good - Immutable state management
class NotesViewModel extends Cubit<NotesViewState> {
  NotesViewModel() : super(NotesViewState.initial());

  void addNote(Note note) {
    final updatedNotes = List<Note>.from(state.notes)..add(note);
    emit(state.copyWith(notes: updatedNotes));
  }

  // Computed properties in state
  bool get hasNotes => state.notes.isNotEmpty;
  int get notesCount => state.notes.length;
}

class NotesViewState extends Equatable {
  final List<Note> notes;
  final bool isLoading;

  const NotesViewState({
    required this.notes,
    required this.isLoading,
  });

  factory NotesViewState.initial() => const NotesViewState(
    notes: [],
    isLoading: false,
  );

  NotesViewState copyWith({
    List<Note>? notes,
    bool? isLoading,
  }) {
    return NotesViewState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [notes, isLoading];
}
```

❌ **DON'T**: Mutate state directly
```dart
// Bad - Mutable state
class NotesViewModel extends Cubit<NotesViewState> {
  void addNote(Note note) {
    state.notes.add(note); // DON'T mutate state directly!
  }
}
```

### 3. **View-ViewModel Binding**

✅ **DO**: Use BlocProvider for dependency injection
```dart
// Good - Dependency injection with BlocProvider
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterViewModel(),
      child: CounterView(),
    );
  }
}

// Or use MultiBlocProvider for multiple providers
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => CounterViewModel()),
    BlocProvider(create: (context) => ThemeCubit()),
  ],
  child: MyApp(),
)
```

### 4. **Reactive UI Updates**

✅ **DO**: Use BlocBuilder for automatic updates
```dart
// Good - Automatic UI updates
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterViewModel, CounterViewState>(
      builder: (context, state) {
        return Text('${state.counter}');
      },
    );
  }
}

// Or use BlocConsumer for side effects
BlocConsumer<CounterViewModel, CounterViewState>(
  listener: (context, state) {
    if (state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
  },
  builder: (context, state) {
    return Text('${state.counter}');
  },
)
```

### 5. **When to Use MVVM**

✅ **Use MVVM when:**
- Medium-sized apps (10-20 screens)
- Complex UI state
- Reactive programming preferred
- Two-way data binding needed
- Testable presentation logic required

❌ **Avoid MVVM when:**
- Very simple apps (use MVC)
- Enterprise apps with complex domains (use DDD)
- Team unfamiliar with reactive programming

---

## 🏛️ Clean Architecture Best Practices

### 1. **Layer Independence**

✅ **DO**: Keep layers independent
```dart
// Domain Layer - No Flutter dependencies
abstract class CounterRepository {
  Future<int> getCounter();
  Future<void> saveCounter(int value);
}

// Data Layer - Implements domain interface
class CounterRepositoryImpl implements CounterRepository {
  final SharedPreferences _prefs;

  CounterRepositoryImpl(this._prefs);

  @override
  Future<int> getCounter() async => _prefs.getInt('counter') ?? 0;

  @override
  Future<void> saveCounter(int value) async {
    await _prefs.setInt('counter', value);
  }
}

// Presentation Layer - Uses domain interface (BLoC)
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final GetCounterUseCase getCounterUseCase;
  final IncrementCounterUseCase incrementCounterUseCase;

  CounterBloc({
    required this.getCounterUseCase,
    required this.incrementCounterUseCase,
  }) : super(CounterInitial()) {
    on<IncrementCounter>(_onIncrement);
    on<LoadCounter>(_onLoad);
  }

  Future<void> _onIncrement(
    IncrementCounter event,
    Emitter<CounterState> emit,
  ) async {
    final result = await incrementCounterUseCase.execute();
    emit(CounterUpdated(result));
  }

  Future<void> _onLoad(
    LoadCounter event,
    Emitter<CounterState> emit,
  ) async {
    final result = await getCounterUseCase.execute();
    emit(CounterUpdated(result));
  }
}
```

### 2. **Dependency Rule**

✅ **DO**: Follow the dependency rule (inner layers don't depend on outer layers)
```
Presentation → Domain ← Data
     ↓            ↑        ↓
   Views      Use Cases  Repos
```

❌ **DON'T**: Let inner layers depend on outer layers
```dart
// Bad - Domain layer depending on infrastructure
class CounterUseCase {
  final SharedPreferences prefs; // Domain shouldn't know about SharedPreferences!
}
```

### 3. **Use Cases**

✅ **DO**: Create focused use cases
```dart
// Good - Single responsibility
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  int execute() {
    final current = repository.getCounter();
    return current + 1;
  }
}

class DecrementCounterUseCase {
  final CounterRepository repository;

  DecrementCounterUseCase(this.repository);

  int execute() {
    final current = repository.getCounter();
    return current - 1;
  }
}
```

❌ **DON'T**: Create god use cases
```dart
// Bad - Too many responsibilities
class CounterUseCase {
  void increment() {}
  void decrement() {}
  void reset() {}
  void saveToCloud() {}
  void loadFromCloud() {}
  void exportToFile() {}
  void importFromFile() {}
}
```

### 4. **Entity Purity**

✅ **DO**: Keep entities pure (no Flutter dependencies)
```dart
// Good - Pure Dart entity
class Note {
  final String id;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  Note copyWith({String? content}) {
    return Note(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}
```

### 5. **When to Use Clean Architecture**

✅ **Use Clean Architecture when:**
- Large applications (20+ screens)
- Multiple developers/teams
- High testability required
- Long-term maintenance planned
- Framework independence desired
- Multiple platform targets

❌ **Avoid Clean Architecture when:**
- Small apps (< 10 screens)
- Tight deadlines
- Solo developer on simple project
- Team lacks experience with layered architecture

---

## 🎯 DDD Best Practices

### 1. **Bounded Contexts**

✅ **DO**: Define clear bounded contexts
```dart
// Good - Separate contexts
// Counter Context
lib/
  domain/counter/
  application/counter/
  infrastructure/counter/
  presentation/counter/

// Notes Context
lib/
  domain/notes/
  application/notes/
  infrastructure/notes/
  presentation/notes/
```

### 2. **Value Objects**

✅ **DO**: Use value objects for domain concepts
```dart
// Good - Value object with validation
class NoteContent {
  final String value;

  NoteContent(String input) : value = _validate(input);

  static String _validate(String input) {
    if (input.isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (input.length > 500) {
      throw ArgumentError('Note content too long');
    }
    return input.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteContent && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

❌ **DON'T**: Use primitive types for domain concepts
```dart
// Bad - No validation, no domain meaning
class Note {
  String content; // Just a string, no validation
}
```

### 3. **Domain Entities**

✅ **DO**: Add behavior to entities
```dart
// Good - Entity with behavior
class Counter {
  final int value;

  Counter(this.value);

  Counter increment() {
    if (value >= 1000) {
      throw CounterLimitExceeded('Counter cannot exceed 1000');
    }
    return Counter(value + 1);
  }

  Counter decrement() {
    if (value <= -1000) {
      throw CounterLimitExceeded('Counter cannot go below -1000');
    }
    return Counter(value - 1);
  }

  Counter reset() => Counter(0);

  bool get isPositive => value > 0;
  bool get isNegative => value < 0;
}
```

❌ **DON'T**: Create anemic domain models
```dart
// Bad - Just data, no behavior (anemic model)
class Counter {
  int value;
  Counter(this.value);
}

// Business logic in service instead of entity
class CounterService {
  void increment(Counter counter) {
    counter.value++; // Logic should be in entity
  }
}
```

### 4. **Repository Pattern**

✅ **DO**: Use repositories for aggregate roots
```dart
// Good - Repository for aggregate root
abstract class NoteRepository {
  Future<Note?> findById(String id);
  Future<List<Note>> findAll();
  Future<void> save(Note note);
  Future<void> delete(String id);
}
```

### 5. **Application Services**

✅ **DO**: Orchestrate domain logic in application layer
```dart
// Good - Application service orchestrates use case
class AddNoteUseCase {
  final NoteRepository repository;

  AddNoteUseCase(this.repository);

  Future<void> execute(String content) async {
    // Validate with value object
    final noteContent = NoteContent(content);
    
    // Create domain entity
    final note = Note.create(
      content: noteContent,
      createdAt: DateTime.now(),
    );

    // Persist through repository
    await repository.save(note);
  }
}
```

### 6. **Domain Events**

✅ **DO**: Use domain events for side effects
```dart
// Good - Domain events for loose coupling
abstract class DomainEvent {}

class NoteCreated extends DomainEvent {
  final String noteId;
  final DateTime createdAt;
  
  NoteCreated(this.noteId, this.createdAt);
}

class Note {
  // ... entity code ...
  
  List<DomainEvent> get domainEvents => _events;
  final List<DomainEvent> _events = [];

  Note create(String content) {
    // ... creation logic ...
    _events.add(NoteCreated(id, createdAt));
    return this;
  }
}
```

### 7. **When to Use DDD**

✅ **Use DDD when:**
- Enterprise applications
- Complex business logic
- Domain experts involved
- Evolving requirements
- Multiple bounded contexts
- Long-term strategic project

❌ **Avoid DDD when:**
- Simple CRUD apps
- Small team/solo dev
- Tight budget/timeline
- No access to domain experts
- Simple business rules

---

## 🎮 State Management with BLoC

### 1. **Cubit vs BLoC**

✅ **DO**: Use Cubit for simple state management
```dart
// Cubit - Simpler, no events needed
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// In widget
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)
```

✅ **DO**: Use BLoC for complex state with events
```dart
// BLoC - Better for complex logic with events
abstract class CounterEvent {}
class IncrementCounter extends CounterEvent {}
class DecrementCounter extends CounterEvent {}
class ResetCounter extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementCounter>((event, emit) => emit(state + 1));
    on<DecrementCounter>((event, emit) => emit(state - 1));
    on<ResetCounter>((event, emit) => emit(0));
  }
}

// In widget
BlocBuilder<CounterBloc, int>(
  builder: (context, count) => Text('$count'),
)

// Trigger events
context.read<CounterBloc>().add(IncrementCounter());
```

### 2. **State Classes**

✅ **DO**: Use immutable state classes with Equatable
```dart
// Good - Immutable state with Equatable
class CounterState extends Equatable {
  final int value;
  final bool isLoading;
  final String? error;

  const CounterState({
    required this.value,
    this.isLoading = false,
    this.error,
  });

  CounterState copyWith({
    int? value,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      value: value ?? this.value,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [value, isLoading, error];
}
```

### 3. **Dependency Injection**

✅ **DO**: Use BlocProvider for dependency injection
```dart
// Good - Single provider
BlocProvider(
  create: (context) => CounterCubit(),
  child: CounterView(),
)

// Good - Multiple providers
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => CounterCubit()),
    BlocProvider(create: (context) => ThemeCubit()),
  ],
  child: MyApp(),
)

// Good - Lazy loading with dependencies
BlocProvider(
  create: (context) => CounterBloc(
    repository: context.read<CounterRepository>(),
  ),
  child: CounterView(),
)
```

### 4. **Accessing BLoC/Cubit**

✅ **DO**: Use context.read() for triggering actions
```dart
// Good - Read for one-time access (events/methods)
ElevatedButton(
  onPressed: () => context.read<CounterCubit>().increment(),
  child: Text('Increment'),
)
```

✅ **DO**: Use context.watch() or BlocBuilder for listening
```dart
// Good - Watch for reactive updates
@override
Widget build(BuildContext context) {
  final count = context.watch<CounterCubit>().state;
  return Text('$count');
}

// Or use BlocBuilder (preferred)
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)
```

### 5. **Side Effects**

✅ **DO**: Use BlocListener for side effects
```dart
// Good - Listener for side effects (navigation, snackbars)
BlocListener<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  },
  child: CounterView(),
)

// Or use BlocConsumer for both listening and building
BlocConsumer<CounterCubit, CounterState>(
  listener: (context, state) {
    // Side effects
    if (state.value == 10) {
      Navigator.pushNamed(context, '/success');
    }
  },
  builder: (context, state) {
    // UI
    return Text('${state.value}');
  },
)
```

### 6. **Selective Rebuilds**

✅ **DO**: Use buildWhen to optimize rebuilds
```dart
// Good - Only rebuild when value changes
BlocBuilder<CounterCubit, CounterState>(
  buildWhen: (previous, current) => previous.value != current.value,
  builder: (context, state) => Text('${state.value}'),
)

// Good - Only listen when error changes
BlocListener<CounterCubit, CounterState>(
  listenWhen: (previous, current) => previous.error != current.error,
  listener: (context, state) {
    if (state.error != null) {
      // Show error
    }
  },
  child: CounterView(),
)
```

### 7. **Testing BLoC/Cubit**

✅ **DO**: Use blocTest for easy testing
```dart
// Good - Test Cubit with blocTest
blocTest<CounterCubit, int>(
  'emits [1] when increment is called',
  build: () => CounterCubit(),
  act: (cubit) => cubit.increment(),
  expect: () => [1],
);

// Test BLoC with events
blocTest<CounterBloc, int>(
  'emits [1] when IncrementCounter is added',
  build: () => CounterBloc(),
  act: (bloc) => bloc.add(IncrementCounter()),
  expect: () => [1],
);
```

### 8. **Hydrated BLoC (Persistence)**

✅ **DO**: Use HydratedBloc for automatic persistence
```dart
// Good - Automatic state persistence
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
  
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}

// Initialize in main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(MyApp());
}
```

---

## 📁 Code Organization

### 1. **Folder Structure by Feature**

✅ **DO**: Group by feature
```
lib/
  features/
    counter/
      data/
      domain/
      presentation/
    notes/
      data/
      domain/
      presentation/
```

❌ **DON'T**: Group by type
```
lib/
  controllers/
    counter_controller.dart
    notes_controller.dart
  views/
    counter_view.dart
    notes_view.dart
```

### 2. **File Naming**

✅ **DO**: Use snake_case for files
```
counter_controller.dart
notes_view.dart
add_note_use_case.dart
```

❌ **DON'T**: Use other naming conventions
```
CounterController.dart  // Wrong
counter-controller.dart // Wrong
counterController.dart  // Wrong
```

### 3. **Class Naming**

✅ **DO**: Use PascalCase for classes
```dart
class CounterController extends GetxController {}
class NoteRepository {}
class AddNoteUseCase {}
```

### 4. **Constants and Configuration**

✅ **DO**: Centralize constants
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Counter Notes App';
  static const int maxNoteLength = 500;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Colors.blue;
  static const Color counterPrimary = Colors.blue;
  static const Color notesPrimary = Colors.green;
}
```

---

## 🧪 Testing Best Practices

### 1. **Unit Tests**

✅ **DO**: Test business logic
```dart
// test/controllers/counter_controller_test.dart
void main() {
  test('Counter increments correctly', () {
    final controller = CounterController();
    
    controller.increment();
    
    expect(controller.counter, 1);
  });

  test('Counter decrements correctly', () {
    final controller = CounterController();
    controller.increment();
    
    controller.decrement();
    
    expect(controller.counter, 0);
  });
}
```

### 2. **Widget Tests**

✅ **DO**: Test UI behavior
```dart
void main() {
  testWidgets('Counter increments on button tap', (tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
```

### 3. **Mock Dependencies**

✅ **DO**: Use mocks for external dependencies
```dart
class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  test('Use case calls repository', () {
    final mockRepo = MockCounterRepository();
    when(mockRepo.getCounter()).thenReturn(0);
    
    final useCase = IncrementCounterUseCase(mockRepo);
    useCase.execute();
    
    verify(mockRepo.saveCounter(1));
  });
}
```

---

## ⚡ Performance Optimization

### 1. **Build Method Optimization**

✅ **DO**: Keep build methods pure
```dart
// Good - Pure, no side effects
@override
Widget build(BuildContext context) {
  return Text('${controller.counter}');
}
```

❌ **DON'T**: Perform computations in build
```dart
// Bad - Computation on every build
@override
Widget build(BuildContext context) {
  final result = expensiveCalculation(); // Don't do this!
  return Text('$result');
}
```

### 2. **Lazy Loading**

✅ **DO**: Load data only when needed
```dart
class NotesController extends GetxController {
  final notes = <Note>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes(); // Load on initialization
  }

  Future<void> loadNotes() async {
    notes.value = await repository.findAll();
  }
}
```

### 3. **List Performance**

✅ **DO**: Use ListView.builder for long lists
```dart
// Good - Builds items on demand
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) => NoteCard(notes[index]),
)
```

❌ **DON'T**: Build all items at once
```dart
// Bad - Builds all items immediately
ListView(
  children: notes.map((note) => NoteCard(note)).toList(),
)
```

---

## 🔒 Security Best Practices

### 1. **Sensitive Data**

✅ **DO**: Never commit sensitive data
```dart
// Good - Use environment variables
final apiKey = dotenv.env['API_KEY'];
```

❌ **DON'T**: Hardcode secrets
```dart
// Bad - Exposed in source code
const apiKey = 'sk-1234567890abcdef';
```

### 2. **Input Validation**

✅ **DO**: Validate all user input
```dart
class NoteContent {
  final String value;

  NoteContent(String input) : value = _validate(input);

  static String _validate(String input) {
    if (input.isEmpty) throw ArgumentError('Cannot be empty');
    if (input.length > 500) throw ArgumentError('Too long');
    return input.trim();
  }
}
```

### 3. **Storage Security**

✅ **DO**: Use secure storage for sensitive data
```dart
// For sensitive data, use flutter_secure_storage
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'token', value: token);
```

---

## 📚 Additional Resources

- **Flutter Official Docs**: https://flutter.dev/docs
- **BLoC Library**: https://bloclibrary.dev
- **flutter_bloc Package**: https://pub.dev/packages/flutter_bloc
- **hydrated_bloc Package**: https://pub.dev/packages/hydrated_bloc
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **DDD Book**: Domain-Driven Design by Eric Evans
- **Flutter Best Practices**: https://dart.dev/guides/language/effective-dart

---

**Remember**: These are guidelines, not strict rules. Adapt them to your project's needs while maintaining code quality and maintainability.

**Happy Coding! 🚀**
