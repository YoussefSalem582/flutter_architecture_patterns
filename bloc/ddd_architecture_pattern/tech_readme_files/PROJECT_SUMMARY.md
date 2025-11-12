# DDD Architecture - Project Summary

## 📋 Overview

This Counter & Notes application demonstrates **Domain-Driven Design (DDD)** with **Clean Architecture** and **BLoC** state management in Flutter. It showcases advanced DDD patterns for complex business domains.

## 🎯 What Makes This DDD?

Unlike simple Clean Architecture, this project includes:

✅ **Rich Domain Models** - Entities with behavior, not just data  
✅ **Value Objects** - Immutable, validated objects (NoteContent, Email)  
✅ **Aggregates** - Business rule enforcement (NotesCollection)  
✅ **Domain Services** - Stateless operations (NoteStatistics)  
✅ **Factories** - Complex creation logic (NoteFactory)  
✅ **Domain Events** - Important occurrences (NoteCreated, NoteArchived)  
✅ **Specifications** - Reusable business rules  
✅ **Ubiquitous Language** - Same terms in code and business  

## 📁 Complete Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart      # get_it DI setup
│   ├── error/
│   │   ├── exceptions.dart               # Data layer exceptions
│   │   └── failures.dart                 # Domain layer failures
│   ├── usecases/
│   │   └── usecase.dart                  # Base use case
│   └── domain/
│       ├── value_objects/
│       │   ├── email.dart                # Shared value object
│       │   └── unique_id.dart
│       └── specifications/
│           └── specification.dart        # Base specification
│
└── features/
    ├── counter/                          # Simple Bounded Context
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── counter.dart          # Value Object (simple)
    │   │   ├── repositories/
    │   │   │   └── counter_repository.dart
    │   │   └── usecases/
    │   │       ├── get_counter.dart
    │   │       ├── increment_counter.dart
    │   │       ├── decrement_counter.dart
    │   │       └── reset_counter.dart
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── counter_model.dart
    │   │   ├── datasources/
    │   │   │   └── counter_local_datasource.dart
    │   │   └── repositories/
    │   │       └── counter_repository_impl.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── counter_cubit.dart
    │       │   └── counter_state.dart
    │       └── pages/
    │           └── counter_page.dart
    │
    └── notes/                            # Complex Bounded Context (Full DDD)
        ├── domain/                       # Domain Layer (Pure Dart)
        │   │
        │   ├── entities/                 # Entities (with ID)
        │   │   ├── note.dart
        │   │   │   • String id (identity)
        │   │   │   • NoteContent content (value object)
        │   │   │   • DateTime createdAt
        │   │   │   • bool isArchived
        │   │   │   • archive() method
        │   │   │   • updateContent() method
        │   │   │   • Equality by ID only
        │   │   │
        │   │   └── notes_collection.dart # Aggregate Root
        │   │       • List<Note> _notes
        │   │       • int maxNotes
        │   │       • addNote() - enforces max rule
        │   │       • removeNote() - validates exists
        │   │       • archiveNote() - updates entity
        │   │       • findById() - retrieves note
        │   │       • Business rules enforced
        │   │
        │   ├── value_objects/            # Value Objects (no ID)
        │   │   ├── note_content.dart
        │   │   │   • String value
        │   │   │   • Smart constructor with validation
        │   │   │   • wordCount getter
        │   │   │   • Immutable
        │   │   │   • Equality by value
        │   │   │
        │   │   ├── note_id.dart
        │   │   └── timestamp.dart
        │   │
        │   ├── services/                 # Domain Services
        │   │   ├── note_statistics.dart
        │   │   │   • countWords(Note)
        │   │   │   • calculateReadingTime(Note)
        │   │   │   • sortByWordCount(List<Note>)
        │   │   │   • Stateless operations
        │   │   │
        │   │   ├── note_validator.dart
        │   │   │   • validate(String content)
        │   │   │   • ValidationResult
        │   │   │
        │   │   └── note_search_service.dart
        │   │       • searchByKeyword(List<Note>, String)
        │   │       • filterByDate(List<Note>, DateTime)
        │   │
        │   ├── repositories/             # Repository Interfaces
        │   │   └── notes_repository.dart
        │   │       • getCollection()
        │   │       • saveCollection()
        │   │       • findNoteById()
        │   │       • Works with aggregates
        │   │
        │   ├── factories/                # Factories
        │   │   └── note_factory.dart
        │   │       • createNote()
        │   │       • createArchivedNote()
        │   │       • _generateId()
        │   │       • Encapsulates creation
        │   │
        │   ├── events/                   # Domain Events
        │   │   ├── domain_event.dart     # Base event
        │   │   ├── note_created.dart
        │   │   ├── note_archived.dart
        │   │   └── note_deleted.dart
        │   │
        │   ├── specifications/           # Specifications
        │   │   ├── is_active_note_spec.dart
        │   │   ├── created_after_spec.dart
        │   │   └── contains_keyword_spec.dart
        │   │
        │   └── usecases/                 # Use Cases
        │       ├── create_note.dart
        │       │   • Uses NoteFactory
        │       │   • Uses NoteValidator
        │       │   • Enforces aggregate rules
        │       │
        │       ├── archive_note.dart
        │       │   • Publishes NoteArchived event
        │       │   • Updates aggregate
        │       │
        │       ├── get_notes.dart
        │       │   • Returns NotesCollection
        │       │
        │       ├── get_notes_statistics.dart
        │       │   • Uses NoteStatistics service
        │       │
        │       ├── search_notes.dart
        │       │   • Uses NoteSearchService
        │       │   • Uses Specifications
        │       │
        │       └── delete_note.dart
        │           • Publishes NoteDeleted event
        │
        ├── data/                         # Data Layer
        │   ├── models/
        │   │   ├── note_model.dart
        │   │   │   • Extends Note entity
        │   │   │   • toJson() / fromJson()
        │   │   │   • toEntity() / fromEntity()
        │   │   │
        │   │   └── notes_collection_model.dart
        │   │       • Extends NotesCollection
        │   │       • Serialization for aggregate
        │   │
        │   ├── datasources/
        │   │   ├── notes_local_datasource.dart
        │   │   │   • HydratedStorage / SharedPreferences
        │   │   │   • getNotes()
        │   │   │   • saveNotes()
        │   │   │   • Throws exceptions
        │   │   │
        │   │   └── notes_remote_datasource.dart (optional)
        │   │       • API calls
        │   │       • HTTP client
        │   │
        │   └── repositories/
        │       └── notes_repository_impl.dart
        │           • Implements domain interface
        │           • Converts models ↔ entities
        │           • Exception → Failure handling
        │           • Works with aggregates
        │
        └── presentation/                 # Presentation Layer
            ├── cubit/
            │   ├── notes_cubit.dart
            │   │   • Coordinates use cases
            │   │   • Manages UI state
            │   │   • No business logic
            │   │
            │   └── notes_state.dart
            │       • NotesInitial
            │       • NotesLoading
            │       • NotesLoaded(NotesCollection)
            │       • NotesError(message)
            │
            ├── pages/
            │   ├── notes_page.dart
            │   │   • BlocBuilder<NotesCubit, NotesState>
            │   │   • Displays notes collection
            │   │
            │   └── note_details_page.dart
            │       • Shows single note
            │       • Archive/edit actions
            │
            └── widgets/
                ├── notes_list.dart
                │   • ListView of notes
                ├── note_item.dart
                │   • Single note card
                ├── add_note_field.dart
                │   • Input field
                └── notes_statistics_widget.dart
                    • Shows stats from domain service
```

## 🔄 Complete Data Flow (DDD Style)

### Example: Creating a Note

```
┌─────────────────────────────────────────────────────────┐
│ 1. USER INPUT                                           │
│    User types "Buy groceries" and taps Add             │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 2. VIEW (notes_page.dart)                               │
│    context.read<NotesCubit>().addNote("Buy groceries")  │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 3. CUBIT (notes_cubit.dart) - Application Service       │
│    final params = CreateNoteParams(content: input);     │
│    final result = await createNote(params);             │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 4. USE CASE (create_note.dart)                          │
│    ├─ Validate with NoteValidator (Domain Service)      │
│    │  └─ validator.validate("Buy groceries")            │
│    │                                                     │
│    ├─ Get current collection from repository            │
│    │  └─ final collection = await repo.getCollection()  │
│    │                                                     │
│    ├─ Create Note with NoteFactory (Factory)            │
│    │  └─ final note = factory.createNote(               │
│    │       content: "Buy groceries"                     │
│    │     )                                              │
│    │     ├─ Generates unique ID                         │
│    │     ├─ Creates NoteContent value object            │
│    │     │  └─ NoteContent.create() validates input     │
│    │     └─ Sets createdAt timestamp                    │
│    │                                                     │
│    ├─ Add to Aggregate (NotesCollection)                │
│    │  └─ final updated = collection.addNote(note)       │
│    │     ├─ Checks if max notes exceeded                │
│    │     ├─ Checks if ID already exists                 │
│    │     └─ Returns new collection or throws error      │
│    │                                                     │
│    ├─ Publish Domain Event (optional)                   │
│    │  └─ eventBus.publish(NoteCreated(noteId: note.id)) │
│    │                                                     │
│    └─ Save via Repository                               │
│       └─ await repo.saveCollection(updatedCollection)   │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 5. REPOSITORY (notes_repository_impl.dart)              │
│    ├─ Convert NotesCollection → NotesCollectionModel    │
│    │  └─ Each Note → NoteModel with toJson()            │
│    │                                                     │
│    ├─ Call Data Source                                  │
│    │  └─ await dataSource.saveNotes(models)             │
│    │                                                     │
│    └─ Error Handling                                    │
│       ├─ CacheException → CacheFailure                  │
│       └─ Return Either<Failure, Unit>                   │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 6. DATA SOURCE (notes_local_datasource.dart)            │
│    ├─ Serialize models to JSON                          │
│    │  └─ notes.map((note) => note.toJson()).toList()    │
│    │                                                     │
│    ├─ Save to storage                                   │
│    │  └─ await storage.write('notes', jsonData)         │
│    │                                                     │
│    └─ Throw CacheException on error                     │
└────────────┬────────────────────────────────────────────┘
             │
             ▼ (Return path)
┌─────────────────────────────────────────────────────────┐
│ 7. BACK TO USE CASE                                     │
│    Returns Either<Failure, NotesCollection>             │
│    ├─ Success: Right(updatedCollection)                 │
│    └─ Failure: Left(CacheFailure(...))                  │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 8. CUBIT PROCESSES RESULT                               │
│    result.fold(                                         │
│      (failure) => emit(NotesError(failure.message)),    │
│      (collection) => emit(NotesLoaded(collection))      │
│    )                                                    │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│ 9. VIEW UPDATES (BlocBuilder)                           │
│    ├─ Detects NotesLoaded state                         │
│    ├─ Rebuilds with new NotesCollection                 │
│    └─ User sees "Buy groceries" in list                 │
└─────────────────────────────────────────────────────────┘
```

## 🎯 DDD Patterns in Action

### 1. Value Object with Validation

```dart
// ❌ Without DDD - Validation scattered
class NotesCubit {
  void addNote(String content) {
    if (content.isEmpty) { ... }  // Validation in cubit
    if (content.length > 1000) { ... }
  }
}

// ✅ With DDD - Validation in domain
class NoteContent extends Equatable {
  final String value;
  
  factory NoteContent.create(String input) {
    if (input.trim().isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }
    if (input.length > 1000) {
      throw ArgumentError('Content exceeds 1000 characters');
    }
    return NoteContent._(input.trim());
  }
  
  // Business logic methods
  int get wordCount => value.split(' ').length;
  bool get isEmpty => value.isEmpty;
}
```

### 2. Aggregate Enforcing Business Rules

```dart
class NotesCollection extends Equatable {
  final List<Note> _notes;
  final int maxNotes;

  // Business rule: Cannot exceed max notes
  NotesCollection addNote(Note note) {
    if (_notes.length >= maxNotes) {
      throw StateError('Cannot exceed $maxNotes notes');
    }
    if (_containsId(note.id)) {
      throw ArgumentError('Note already exists');
    }
    return NotesCollection(notes: [..._notes, note], maxNotes: maxNotes);
  }

  // Business rule: Cannot remove non-existent note
  NotesCollection removeNote(String id) {
    if (!_containsId(id)) {
      throw ArgumentError('Note not found');
    }
    return NotesCollection(
      notes: _notes.where((n) => n.id != id).toList(),
      maxNotes: maxNotes,
    );
  }
}
```

### 3. Domain Service for Complex Calculations

```dart
class NoteStatistics {
  int getTotalWords(NotesCollection collection) {
    return collection.notes.fold(0, (sum, note) => 
      sum + note.content.wordCount
    );
  }

  double getAverageReadingTime(NotesCollection collection) {
    if (collection.count == 0) return 0.0;
    final totalWords = getTotalWords(collection);
    return (totalWords / 200.0) / collection.count;
  }

  Note getLongestNote(NotesCollection collection) {
    return collection.notes.reduce((a, b) =>
      a.content.wordCount > b.content.wordCount ? a : b
    );
  }
}
```

### 4. Factory for Complex Creation

```dart
class NoteFactory {
  final IdGenerator idGenerator;
  final TimeProvider timeProvider;

  NoteFactory({
    required this.idGenerator,
    required this.timeProvider,
  });

  Note createNote({required String content}) {
    return Note(
      id: idGenerator.generateId(),
      content: NoteContent.create(content),
      createdAt: timeProvider.now(),
      isArchived: false,
    );
  }

  Note createFromTemplate(NoteTemplate template) {
    return Note(
      id: idGenerator.generateId(),
      content: NoteContent.create(template.defaultContent),
      createdAt: timeProvider.now(),
      isArchived: false,
    );
  }
}
```

### 5. Specification for Reusable Business Rules

```dart
abstract class Specification<T> {
  bool isSatisfiedBy(T candidate);
  
  Specification<T> and(Specification<T> other) =>
      AndSpecification(this, other);
}

class IsActiveNoteSpec extends Specification<Note> {
  @override
  bool isSatisfiedBy(Note note) => !note.isArchived;
}

class CreatedAfterSpec extends Specification<Note> {
  final DateTime date;
  CreatedAfterSpec(this.date);
  
  @override
  bool isSatisfiedBy(Note note) => note.createdAt.isAfter(date);
}

// Usage in Use Case
class SearchNotes implements UseCase<List<Note>, SearchParams> {
  @override
  Future<Either<Failure, List<Note>>> call(SearchParams params) async {
    final collection = await repository.getCollection();
    
    final activeSpec = IsActiveNoteSpec();
    final recentSpec = CreatedAfterSpec(params.afterDate);
    final combined = activeSpec.and(recentSpec);
    
    final filtered = collection.notes
        .where(combined.isSatisfiedBy)
        .toList();
    
    return Right(filtered);
  }
}
```

## 📚 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Value equality
  dartz: ^0.10.1                # Either, Option
  get_it: ^7.6.0                # Dependency injection
  shared_preferences: ^2.2.2    # Local storage

dev_dependencies:
  bloc_test: ^9.1.5             # BLoC testing
  mocktail: ^1.0.0              # Mocking
```

## ✅ Benefits

1. **Business Logic Encapsulated** - In entities, aggregates, value objects
2. **Validated at Creation** - Value objects validate in constructor
3. **Impossible States Prevented** - Aggregates enforce invariants
4. **Rich Domain Model** - Entities have behavior, not just data
5. **Testable** - Domain layer is pure Dart
6. **Maintainable** - Complex logic organized in domain
7. **Scalable** - Add features without breaking existing code
8. **Ubiquitous Language** - Same terms in code and business discussions

## 🎓 Learning Outcomes

After studying this project, you'll understand:

1. ✅ Difference between Entity and Value Object
2. ✅ How to design Aggregates with business rules
3. ✅ When to use Domain Services vs Entity methods
4. ✅ Factory pattern for complex object creation
5. ✅ Specification pattern for reusable business rules
6. ✅ How to combine DDD with Clean Architecture
7. ✅ How to use BLoC as Application Service
8. ✅ Testing strategies for DDD

## 🚀 Commands

```bash
# Run app
flutter run -d chrome

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

**This project showcases enterprise-grade DDD with Clean Architecture and BLoC in Flutter! 🚀**

Perfect for:
- Learning Domain-Driven Design
- Complex business applications
- Enterprise Flutter projects
- Architectural best practices
- Advanced Flutter patterns
- Team training
