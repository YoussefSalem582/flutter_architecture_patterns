# 🎯 Best Practices Guide for Flutter Architecture Patterns

This guide covers best practices for working with different architecture patterns in Flutter, based on the implementations in this repository.

## 📋 Table of Contents
- [General Flutter Best Practices](#general-flutter-best-practices)
- [MVC Best Practices](#mvc-best-practices)
- [MVVM Best Practices](#mvvm-best-practices)
- [Clean Architecture Best Practices](#clean-architecture-best-practices)
- [DDD Best Practices](#ddd-best-practices)
- [State Management with GetX](#state-management-with-getx)
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
    Get.snackbar('Success', 'Note saved');
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to save note: $e',
      backgroundColor: Colors.red,
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
  get: ^4.7.2  # Specify versions
  get_storage: ^2.1.1
```

❌ **DON'T**: Use outdated or unspecified versions
```yaml
# Bad
dependencies:
  get: any  # Don't use 'any'
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

// Controller - Business logic
class CounterController extends GetxController {
  final CounterModel _model = CounterModel();
  
  int get counter => _model.value;
  
  void increment() {
    _model.value++;
    update();
  }
}

// View - UI only
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CounterController>(
      builder: (controller) => Text('${controller.counter}'),
    );
  }
}
```

### 2. **Controller Lifecycle**

✅ **DO**: Clean up resources in onClose
```dart
class CounterController extends GetxController {
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => update());
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
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
// Good - ViewModel handles presentation logic
class CounterViewModel extends GetxController {
  final _counter = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  int get counter => _counter.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<void> increment() async {
    _isLoading.value = true;
    try {
      _counter.value++;
      await _saveToStorage();
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _saveToStorage() async {
    await GetStorage().write('counter', _counter.value);
  }
}
```

### 2. **Observable State**

✅ **DO**: Use observables for reactive state
```dart
// Good - Reactive state management
class NotesViewModel extends GetxController {
  final notes = <Note>[].obs;
  final isLoading = false.obs;

  // Computed properties
  int get notesCount => notes.length;
  bool get hasNotes => notes.isNotEmpty;
}
```

❌ **DON'T**: Mix observable and non-observable state
```dart
// Bad - Inconsistent state management
class NotesViewModel extends GetxController {
  final notes = <Note>[].obs; // Observable
  bool isLoading = false; // Not observable - won't trigger UI updates
}
```

### 3. **View-ViewModel Binding**

✅ **DO**: Use proper bindings
```dart
// Good - Dependency injection with bindings
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounterViewModel>(() => CounterViewModel());
  }
}

// Route setup
GetPage(
  name: '/counter',
  page: () => CounterView(),
  binding: CounterBinding(),
)
```

### 4. **Two-Way Data Binding**

✅ **DO**: Use Obx for automatic updates
```dart
// Good - Automatic UI updates
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<CounterViewModel>(
      builder: (viewModel) => Text('${viewModel.counter}'),
    );
  }
}
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
  int getCounter();
  void saveCounter(int value);
}

// Data Layer - Implements domain interface
class CounterRepositoryImpl implements CounterRepository {
  final GetStorage _storage = GetStorage();

  @override
  int getCounter() => _storage.read('counter') ?? 0;

  @override
  void saveCounter(int value) => _storage.write('counter', value);
}

// Presentation Layer - Uses domain interface
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  int execute() {
    final current = repository.getCounter();
    final incremented = current + 1;
    repository.saveCounter(incremented);
    return incremented;
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
  final GetStorage storage; // Domain shouldn't know about GetStorage!
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

## 🎮 State Management with GetX

### 1. **Reactive State**

✅ **DO**: Use `.obs` for reactive state
```dart
class MyController extends GetxController {
  final count = 0.obs; // Reactive
  
  void increment() => count.value++;
}

// In widget
Obx(() => Text('${controller.count}'))
```

### 2. **Simple State**

✅ **DO**: Use `update()` for simple state
```dart
class MyController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update(); // Manually trigger update
  }
}

// In widget
GetBuilder<MyController>(
  builder: (controller) => Text('${controller.count}'),
)
```

### 3. **Dependency Injection**

✅ **DO**: Use proper DI patterns
```dart
// Good - Lazy initialization
Get.lazyPut(() => MyController());

// Good - Always create new instance
Get.put(MyController(), tag: 'unique');

// Good - Singleton
Get.putAsync(() async => await MyService.create());
```

### 4. **Navigation**

✅ **DO**: Use named routes
```dart
// Good - Named routes
Get.toNamed('/counter');
Get.toNamed('/notes', arguments: note);

// Good - Typed routes
Get.to(() => CounterView());
```

### 5. **Snackbars and Dialogs**

✅ **DO**: Use GetX helpers
```dart
// Good - Simple and clean
Get.snackbar('Success', 'Operation completed');

Get.dialog(AlertDialog(
  title: Text('Confirm'),
  content: Text('Are you sure?'),
));

Get.bottomSheet(Container(/* ... */));
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
- **GetX Documentation**: https://pub.dev/packages/get
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **DDD Book**: Domain-Driven Design by Eric Evans
- **Flutter Best Practices**: https://dart.dev/guides/language/effective-dart

---

**Remember**: These are guidelines, not strict rules. Adapt them to your project's needs while maintaining code quality and maintainability.

**Happy Coding! 🚀**
