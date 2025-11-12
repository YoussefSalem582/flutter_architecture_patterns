# Domain-Driven Design (DDD) Concepts

## Overview

Domain-Driven Design is a software development approach focused on modeling complex business domains. This guide explains DDD concepts as implemented in our Flutter app with BLoC.

## Core DDD Concepts

### 1. Ubiquitous Language

**Definition**: A common language shared by developers and domain experts.

**In Our App**:
- Counter: "increment", "decrement", "reset"
- Notes: "create note", "archive note", "note content"
- Use the same terms in code, docs, and conversations

**Example**:
```dart
// ✅ Good - Uses domain language
class Note {
  void archive() { ... }  // Domain expert says "archive"
}

// ❌ Bad - Technical language
class Note {
  void setInactive() { ... }  // Domain expert doesn't say "inactive"
}
```

---

### 2. Bounded Contexts

**Definition**: Explicit boundaries where a domain model applies.

**In Our App**:
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Counter Context│     │  Notes Context  │     │  Theme Context  │
│                 │     │                 │     │                 │
│  - Counter      │     │  - Note         │     │  - ThemeMode    │
│  - Value        │     │  - Content      │     │  - Preference   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**File Structure**:
```
features/
├── counter/           ← Counter Bounded Context
├── notes/             ← Notes Bounded Context
└── theme/             ← Theme Bounded Context
```

---

### 3. Entities

**Definition**: Objects with unique identity that persists over time.

**Characteristics**:
- Has unique ID
- Mutable (identity stays same, attributes change)
- Tracked across operations

**Example**:
```dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;              // ← Unique identity
  final String content;
  final DateTime timestamp;
  final bool isArchived;

  const Note({
    required this.id,
    required this.content,
    required this.timestamp,
    this.isArchived = false,
  });

  // Same ID = same entity, even if content changes
  @override
  List<Object?> get props => [id];  // Only ID for equality

  // Modify entity (returns new instance for immutability)
  Note archive() {
    return Note(
      id: id,  // ← Same identity
      content: content,
      timestamp: timestamp,
      isArchived: true,
    );
  }
}
```

**Why Entity**:
- `id` identifies the note even if content changes
- Two notes with different IDs are different, even if content is same

---

### 4. Value Objects

**Definition**: Objects defined by their attributes, not identity.

**Characteristics**:
- No unique ID
- Immutable
- Equality based on attributes
- Interchangeable

**Example**:
```dart
class Counter extends Equatable {
  final int value;

  const Counter({required this.value});

  @override
  List<Object?> get props => [value];  // All attributes for equality

  Counter increment() => Counter(value: value + 1);
}
```

**Why Value Object**:
- No ID needed
- Two counters with value 5 are the same
- If value changes, it's a different counter

**More Examples**:

```dart
// Email Value Object
class Email extends Equatable {
  final String value;

  const Email(this.value);

  factory Email.create(String input) {
    if (!_isValid(input)) {
      throw ArgumentError('Invalid email');
    }
    return Email(input);
  }

  static bool _isValid(String email) {
    return email.contains('@') && email.contains('.');
  }

  @override
  List<Object?> get props => [value];
}

// DateRange Value Object
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

  @override
  List<Object?> get props => [start, end];
}
```

---

### 5. Aggregates

**Definition**: Cluster of entities and value objects treated as a single unit.

**Characteristics**:
- Has a root entity (Aggregate Root)
- Enforces business rules
- Transactional boundary

**Example**:

```dart
// Aggregate Root
class NotesCollection extends Equatable {
  final List<Note> _notes;
  final int maxNotes;

  const NotesCollection({
    required List<Note> notes,
    this.maxNotes = 100,
  }) : _notes = notes;

  // Encapsulates business rule
  NotesCollection addNote(Note note) {
    if (_notes.length >= maxNotes) {
      throw Exception('Cannot exceed $maxNotes notes');
    }
    return NotesCollection(notes: [..._notes, note], maxNotes: maxNotes);
  }

  Note getById(String id) {
    return _notes.firstWhere((note) => note.id == id);
  }

  List<Note> get activeNotes {
    return _notes.where((note) => !note.isArchived).toList();
  }

  @override
  List<Object?> get props => [_notes, maxNotes];
}
```

**Why Aggregate**:
- Ensures notes collection never exceeds limit
- All note operations go through the aggregate root
- Business rules enforced in one place

---

### 6. Domain Services

**Definition**: Operations that don't belong to entities or value objects.

**When to Use**:
- Operation involves multiple entities
- Stateless operation
- Domain logic that doesn't fit in an entity

**Example**:

```dart
// Domain Service
class NoteStatistics {
  int countWords(Note note) {
    return note.content.split(' ').length;
  }

  double calculateReadingTime(Note note) {
    final words = countWords(note);
    return words / 200.0; // Average reading speed: 200 words/min
  }

  List<Note> sortByLength(List<Note> notes) {
    return notes..sort((a, b) {
      return countWords(a).compareTo(countWords(b));
    });
  }
}

// Usage in Use Case
class GetNotesStatistics implements UseCase<NotesStats, NoParams> {
  final NotesRepository repository;
  final NoteStatistics noteStatistics; // ← Domain Service

  GetNotesStatistics(this.repository, this.noteStatistics);

  @override
  Future<Either<Failure, NotesStats>> call(NoParams params) async {
    final result = await repository.getNotes();
    
    return result.fold(
      (failure) => Left(failure),
      (notes) {
        final totalWords = notes.fold(0, (sum, note) {
          return sum + noteStatistics.countWords(note);
        });
        
        return Right(NotesStats(
          totalNotes: notes.length,
          totalWords: totalWords,
        ));
      },
    );
  }
}
```

---

### 7. Repositories (DDD Style)

**Definition**: Abstracts data access, provides collection-like interface.

**Characteristics**:
- Interface in domain layer
- Implementation in data layer
- Works with aggregates
- Hides persistence details

**Example**:

```dart
// Domain Layer
abstract class NotesRepository {
  Future<Either<Failure, NotesCollection>> getNotesCollection();
  Future<Either<Failure, Unit>> saveNotesCollection(NotesCollection collection);
  Future<Either<Failure, Note>> findById(String id);
}

// Data Layer
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, NotesCollection>> getNotesCollection() async {
    try {
      final models = await localDataSource.getNotes();
      final notes = models.map((m) => m.toEntity()).toList();
      return Right(NotesCollection(notes: notes));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

---

### 8. Domain Events

**Definition**: Something that happened in the domain that domain experts care about.

**Example**:

```dart
// Domain Event
abstract class DomainEvent {
  final DateTime occurredAt;
  
  DomainEvent() : occurredAt = DateTime.now();
}

class NoteCreated extends DomainEvent {
  final String noteId;
  final String content;
  
  NoteCreated({required this.noteId, required this.content});
}

class NoteArchived extends DomainEvent {
  final String noteId;
  
  NoteArchived({required this.noteId});
}

// Entity with Events
class Note extends Equatable {
  final String id;
  final String content;
  final bool isArchived;
  final List<DomainEvent> _domainEvents = [];

  List<DomainEvent> get domainEvents => List.unmodifiable(_domainEvents);

  Note archive() {
    final archivedNote = Note(
      id: id,
      content: content,
      isArchived: true,
    );
    
    archivedNote._domainEvents.add(NoteArchived(noteId: id));
    
    return archivedNote;
  }
}

// Use Case processes events
class ArchiveNote implements UseCase<Note, ArchiveNoteParams> {
  final NotesRepository repository;
  final EventBus eventBus;

  @override
  Future<Either<Failure, Note>> call(ArchiveNoteParams params) async {
    final result = await repository.findById(params.noteId);
    
    return result.fold(
      (failure) => Left(failure),
      (note) async {
        final archivedNote = note.archive();
        
        // Publish domain events
        for (final event in archivedNote.domainEvents) {
          eventBus.publish(event);
        }
        
        return await repository.save(archivedNote);
      },
    );
  }
}
```

---

### 9. Factories

**Definition**: Encapsulates complex object creation.

**Example**:

```dart
class NoteFactory {
  Note createNote({required String content}) {
    return Note(
      id: _generateId(),
      content: content,
      timestamp: DateTime.now(),
      isArchived: false,
    );
  }

  Note createArchivedNote({required String content}) {
    return Note(
      id: _generateId(),
      content: content,
      timestamp: DateTime.now(),
      isArchived: true,
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Usage in Use Case
class CreateNote implements UseCase<Note, CreateNoteParams> {
  final NotesRepository repository;
  final NoteFactory noteFactory;

  CreateNote(this.repository, this.noteFactory);

  @override
  Future<Either<Failure, Note>> call(CreateNoteParams params) async {
    final note = noteFactory.createNote(content: params.content);
    return await repository.save(note);
  }
}
```

---

### 10. Specifications

**Definition**: Encapsulates business rules for querying/filtering.

**Example**:

```dart
abstract class Specification<T> {
  bool isSatisfiedBy(T candidate);
  
  Specification<T> and(Specification<T> other) {
    return AndSpecification(this, other);
  }
  
  Specification<T> or(Specification<T> other) {
    return OrSpecification(this, other);
  }
}

class IsActiveNoteSpecification extends Specification<Note> {
  @override
  bool isSatisfiedBy(Note note) {
    return !note.isArchived;
  }
}

class CreatedAfterSpecification extends Specification<Note> {
  final DateTime date;
  
  CreatedAfterSpecification(this.date);
  
  @override
  bool isSatisfiedBy(Note note) {
    return note.timestamp.isAfter(date);
  }
}

// Usage
final activeSpec = IsActiveNoteSpecification();
final recentSpec = CreatedAfterSpecification(DateTime.now().subtract(Duration(days: 7)));
final activeAndRecent = activeSpec.and(recentSpec);

final filteredNotes = notes.where(activeAndRecent.isSatisfiedBy).toList();
```

---

## DDD in Flutter with BLoC

### Layer Mapping

```
┌──────────────────────────────────────┐
│   Presentation Layer (BLoC/Cubit)    │  ← Application Services
│   - Coordinates use cases            │
│   - Manages UI state                 │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│        Domain Layer (Core)           │  ← Domain Model
│   - Entities                         │
│   - Value Objects                    │
│   - Aggregates                       │
│   - Domain Services                  │
│   - Repository Interfaces            │
│   - Domain Events                    │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│          Data Layer                  │  ← Infrastructure
│   - Repository Implementations       │
│   - Data Sources                     │
│   - Models (persistence)             │
└──────────────────────────────────────┘
```

### Complete Example: Note Aggregate

```dart
// ========== Domain Layer ==========

// Value Object
class NoteContent extends Equatable {
  final String value;

  const NoteContent(this.value);

  factory NoteContent.create(String input) {
    if (input.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (input.length > 1000) {
      throw ArgumentError('Note content too long');
    }
    return NoteContent(input.trim());
  }

  @override
  List<Object?> get props => [value];
}

// Entity
class Note extends Equatable {
  final String id;
  final NoteContent content;
  final DateTime createdAt;
  final bool isArchived;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isArchived,
  });

  Note archive() {
    if (isArchived) {
      throw StateError('Note is already archived');
    }
    return Note(
      id: id,
      content: content,
      createdAt: createdAt,
      isArchived: true,
    );
  }

  @override
  List<Object?> get props => [id];
}

// Aggregate Root
class NotesCollection extends Equatable {
  final List<Note> _notes;

  const NotesCollection(this._notes);

  NotesCollection addNote(Note note) {
    if (_contains(note.id)) {
      throw ArgumentError('Note with this ID already exists');
    }
    return NotesCollection([..._notes, note]);
  }

  NotesCollection removeNote(String id) {
    return NotesCollection(
      _notes.where((note) => note.id != id).toList(),
    );
  }

  Note? findById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  bool _contains(String id) {
    return _notes.any((note) => note.id == id);
  }

  int get count => _notes.length;
  List<Note> get notes => List.unmodifiable(_notes);

  @override
  List<Object?> get props => [_notes];
}

// Repository Interface
abstract class NotesRepository {
  Future<Either<Failure, NotesCollection>> getCollection();
  Future<Either<Failure, Unit>> saveCollection(NotesCollection collection);
}

// ========== Data Layer ==========

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource dataSource;

  NotesRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, NotesCollection>> getCollection() async {
    try {
      final models = await dataSource.getNotes();
      final notes = models.map((m) => m.toEntity()).toList();
      return Right(NotesCollection(notes));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}

// ========== Presentation Layer ==========

class NotesCubit extends Cubit<NotesState> {
  final AddNote addNoteUseCase;
  final GetNotes getNotesUseCase;

  NotesCubit({
    required this.addNoteUseCase,
    required this.getNotesUseCase,
  }) : super(NotesInitial());

  Future<void> loadNotes() async {
    emit(NotesLoading());
    final result = await getNotesUseCase(NoParams());
    
    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (collection) => emit(NotesLoaded(collection)),
    );
  }

  Future<void> addNote(String content) async {
    try {
      final noteContent = NoteContent.create(content); // Domain validation
      final result = await addNoteUseCase(AddNoteParams(noteContent));
      
      result.fold(
        (failure) => emit(NotesError(failure.message)),
        (collection) => emit(NotesLoaded(collection)),
      );
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
```

---

## Summary: Entity vs Value Object

| Aspect | Entity | Value Object |
|--------|--------|--------------|
| Identity | Has unique ID | No ID |
| Equality | Based on ID | Based on attributes |
| Mutability | Can change attributes | Immutable |
| Lifecycle | Tracked over time | Replaceable |
| Example | Note, User, Order | Email, Money, DateRange, Counter |

---

## Best Practices

1. ✅ **Use Ubiquitous Language** everywhere (code, docs, conversations)
2. ✅ **Define clear Bounded Contexts** (one per feature)
3. ✅ **Make Value Objects immutable** (use const, copyWith)
4. ✅ **Identify Entities by ID** (not attributes)
5. ✅ **Protect Aggregates** (enforce business rules)
6. ✅ **Keep Domain pure** (no Flutter, no frameworks)
7. ✅ **Use Specifications** for complex queries
8. ✅ **Factories for complex creation** logic
9. ✅ **Domain Events** for important occurrences
10. ✅ **Repository pattern** for persistence abstraction

---

**DDD + Clean Architecture + BLoC = Robust, maintainable Flutter apps! 🚀**
