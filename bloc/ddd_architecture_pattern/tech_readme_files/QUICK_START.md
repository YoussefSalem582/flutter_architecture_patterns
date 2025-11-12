# DDD Architecture - Quick Start Guide

## 🎯 What is DDD?

**Domain-Driven Design (DDD)** is a software approach that focuses on modeling complex business domains. It goes beyond Clean Architecture by emphasizing **rich domain models** with business logic embedded in entities and aggregates.

## 📦 Quick Setup

```bash
cd ddd_architecture_pattern
flutter pub get
flutter run -d chrome
```

## 🏗️ DDD vs Clean Architecture

| Feature | Clean Architecture | DDD + Clean Architecture |
|---------|-------------------|--------------------------|
| **Entities** | Simple data classes | Rich models with behavior |
| **Business Logic** | In use cases | In entities + aggregates + use cases |
| **Value Objects** | Rare | Everywhere (Email, Money, NoteContent) |
| **Aggregates** | Not used | Core concept (enforce rules) |
| **Focus** | Layer separation | Domain modeling |
| **Best For** | All apps | Complex business logic |

## 📁 Project Structure

```
lib/
└── features/
    └── notes/                          # Bounded Context
        ├── domain/                     # Core business logic
        │   ├── entities/
        │   │   ├── note.dart                # Entity (has ID)
        │   │   └── notes_collection.dart    # Aggregate Root
        │   ├── value_objects/
        │   │   └── note_content.dart        # Value Object (no ID)
        │   ├── services/
        │   │   └── note_statistics.dart     # Domain Service
        │   ├── repositories/
        │   │   └── notes_repository.dart    # Interface
        │   ├── factories/
        │   │   └── note_factory.dart        # Factory pattern
        │   └── usecases/
        │       └── create_note.dart
        ├── data/
        │   └── repositories/
        │       └── notes_repository_impl.dart
        └── presentation/
            └── cubit/
                └── notes_cubit.dart
```

## 🎓 Core DDD Concepts

### 1. Entity (Has Identity)

```dart
class Note extends Equatable {
  final String id;  // ← Unique identity
  final NoteContent content;
  final bool isArchived;

  const Note({
    required this.id,
    required this.content,
    required this.isArchived,
  });

  // Domain behavior
  Note archive() {
    if (isArchived) throw StateError('Already archived');
    return Note(id: id, content: content, isArchived: true);
  }

  @override
  List<Object?> get props => [id];  // Equality by ID only
}
```

**Why**: Notes with same ID are the same, even if content differs.

### 2. Value Object (No Identity)

```dart
class NoteContent extends Equatable {
  final String value;

  const NoteContent._(this.value);

  // Smart constructor with validation
  factory NoteContent.create(String input) {
    if (input.trim().isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }
    if (input.length > 1000) {
      throw ArgumentError('Content too long');
    }
    return NoteContent._(input.trim());
  }

  @override
  List<Object?> get props => [value];  // Equality by value
}
```

**Why**: Two NoteContent with "Hello" are identical and interchangeable.

### 3. Aggregate Root (Enforces Rules)

```dart
class NotesCollection extends Equatable {
  final List<Note> _notes;
  final int maxNotes;

  const NotesCollection({
    required List<Note> notes,
    this.maxNotes = 100,
  }) : _notes = notes;

  // Business rule enforcement
  NotesCollection addNote(Note note) {
    if (_notes.length >= maxNotes) {
      throw StateError('Cannot exceed $maxNotes notes');
    }
    return NotesCollection(notes: [..._notes, note], maxNotes: maxNotes);
  }

  @override
  List<Object?> get props => [_notes, maxNotes];
}
```

**Why**: All note operations go through aggregate root, ensuring business rules.

### 4. Domain Service (Stateless Operations)

```dart
class NoteStatistics {
  int countWords(Note note) {
    return note.content.value.split(' ').length;
  }

  double calculateReadingTime(Note note) {
    return countWords(note) / 200.0; // 200 words/min
  }
}
```

**Why**: Logic that doesn't belong to a specific entity.

### 5. Factory (Complex Creation)

```dart
class NoteFactory {
  Note createNote({required String content}) {
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: NoteContent.create(content),
      isArchived: false,
    );
  }
}
```

**Why**: Encapsulates creation logic and validation.

### 6. Repository (Collection-like Interface)

```dart
// Domain Interface
abstract class NotesRepository {
  Future<Either<Failure, NotesCollection>> getCollection();
  Future<Either<Failure, Unit>> saveCollection(NotesCollection collection);
}

// Data Implementation
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource dataSource;
  
  @override
  Future<Either<Failure, NotesCollection>> getCollection() async {
    // Implementation with error handling
  }
}
```

**Why**: Abstracts persistence, works with aggregates.

## 🔄 Data Flow Example

### Creating a Note

```
1. USER INPUT
   └─ User types "Buy milk" and taps Add

2. VIEW
   └─ context.read<NotesCubit>().addNote("Buy milk")

3. CUBIT (Application Service)
   └─ await createNote(CreateNoteParams(content: "Buy milk"))

4. USE CASE
   ├─ Validate with NoteValidator (Domain Service)
   ├─ Create with NoteFactory (Factory)
   │  └─ Creates Note with NoteContent value object
   ├─ Get NotesCollection from repository
   ├─ collection.addNote(note) ← Aggregate enforces max notes rule
   └─ repository.saveCollection(updatedCollection)

5. AGGREGATE ROOT
   ├─ Checks if max notes exceeded
   ├─ Checks if note ID already exists
   └─ Returns new collection or throws error

6. REPOSITORY
   ├─ Converts aggregate → models
   ├─ Saves to data source
   └─ Returns Either<Failure, Unit>

7. CUBIT
   └─ emit(NotesLoaded(updatedCollection))

8. VIEW
   └─ BlocBuilder rebuilds with new notes
```

## 📊 Key Patterns

### Entity vs Value Object

```dart
// ✅ Entity - Has unique ID
class User {
  final String id;       // ID defines identity
  final String name;
  // Same ID = same user, even if name changes
}

// ✅ Value Object - No ID
class Email {
  final String value;
  // Two emails with "test@test.com" are identical
}
```

### Simple vs Rich Entity

```dart
// Clean Architecture (Simple)
class Note {
  final String id;
  final String content;  // Just a string
}

// DDD (Rich)
class Note {
  final String id;
  final NoteContent content;  // Value Object with validation
  final DateTime createdAt;
  final bool isArchived;
  
  // Domain behavior
  Note archive() { ... }
  bool isOlderThan(Duration duration) { ... }
}
```

### Use Case with Domain Logic

```dart
class CreateNote implements UseCase<NotesCollection, CreateNoteParams> {
  final NotesRepository repository;
  final NoteFactory noteFactory;        // ← DDD Factory
  final NoteValidator validator;        // ← DDD Domain Service
  
  @override
  Future<Either<Failure, NotesCollection>> call(CreateNoteParams params) async {
    // Validate (Domain Service)
    final validationResult = validator.validate(params.content);
    
    // Get collection
    final collection = await repository.getCollection();
    
    // Create note (Factory)
    final note = noteFactory.createNote(content: params.content);
    
    // Add to aggregate (Business rules enforced)
    final updated = collection.addNote(note);
    
    // Save
    return repository.saveCollection(updated);
  }
}
```

## 🧪 Testing DDD

### Test Value Objects

```dart
test('NoteContent validates empty input', () {
  expect(
    () => NoteContent.create(''),
    throwsA(isA<ArgumentError>()),
  );
});

test('NoteContent trims whitespace', () {
  final content = NoteContent.create('  Hello  ');
  expect(content.value, 'Hello');
});
```

### Test Entities

```dart
test('Note can be archived', () {
  final note = Note(
    id: '1',
    content: NoteContent.create('Test'),
    isArchived: false,
  );
  
  final archived = note.archive();
  
  expect(archived.isArchived, true);
  expect(archived.id, note.id);  // Same identity
});
```

### Test Aggregates

```dart
test('NotesCollection enforces max notes rule', () {
  final collection = NotesCollection(
    notes: List.generate(100, (i) => createNote(id: '$i')),
    maxNotes: 100,
  );
  
  expect(
    () => collection.addNote(createNote(id: '101')),
    throwsA(isA<StateError>()),
  );
});
```

### Test Domain Services

```dart
test('NoteStatistics counts words correctly', () {
  final note = Note(
    id: '1',
    content: NoteContent.create('Hello world test'),
    isArchived: false,
  );
  
  final stats = NoteStatistics();
  expect(stats.countWords(note), 3);
});
```

## 📚 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3      # State management
  equatable: ^2.0.5         # Value equality
  dartz: ^0.10.1            # Functional programming
  get_it: ^7.6.0            # Dependency injection
  shared_preferences: ^2.2.2

dev_dependencies:
  bloc_test: ^9.1.5
  mocktail: ^1.0.0
```

## ✅ Benefits of DDD

1. **Rich Domain Model** - Business logic in entities, not scattered
2. **Validated at Creation** - Value objects validate in constructor
3. **Business Rules Enforced** - Aggregates prevent invalid states
4. **Testable** - Domain logic is pure Dart
5. **Maintainable** - Clear structure for complex logic
6. **Ubiquitous Language** - Same terms everywhere

## ⚠️ When to Use DDD

### ✅ Use DDD When:
- Complex business rules
- Large enterprise app
- Multiple teams
- Long-term project
- Domain experts available
- Business logic is core value

### ❌ Avoid DDD When:
- Simple CRUD app
- Prototype/MVP
- Small team
- Learning Flutter
- No complex domain logic
- Time-constrained project

## 🎯 Quick Reference

### DDD Building Blocks

| Pattern | Has ID? | Mutable? | Example |
|---------|---------|----------|---------|
| Entity | ✅ Yes | Attributes can change | Note, User, Order |
| Value Object | ❌ No | ❌ Immutable | Email, Money, NoteContent |
| Aggregate | ✅ Yes | Via methods only | NotesCollection, ShoppingCart |
| Domain Service | N/A | Stateless | NoteStatistics, PaymentProcessor |
| Factory | N/A | Creates objects | NoteFactory, UserFactory |
| Repository | N/A | Persistence abstraction | NotesRepository |

### Common Mistakes

```dart
// ❌ Wrong - Business logic in cubit
class NotesCubit extends Cubit<NotesState> {
  void addNote(String content) {
    if (content.isEmpty) return;  // ← Should be in domain
    if (content.length > 1000) return;  // ← Should be in domain
  }
}

// ✅ Correct - Business logic in domain
class NoteContent {
  factory NoteContent.create(String input) {
    if (input.isEmpty) throw ArgumentError();
    if (input.length > 1000) throw ArgumentError();
    return NoteContent._(input);
  }
}
```

---

**DDD + Clean Architecture + BLoC = Production-ready enterprise Flutter apps! 🚀**

## 📖 Further Reading

- **`DDD_CONCEPTS.md`** - Deep dive into DDD concepts
- **`ARCHITECTURE.md`** - Detailed architecture guide
- **`PROJECT_SUMMARY.md`** - Complete project overview
- **Book**: "Domain-Driven Design" by Eric Evans
- **Book**: "Implementing Domain-Driven Design" by Vaughn Vernon
