# Domain-Driven Design with BLoC - Architecture Guide

## Overview

This project demonstrates **Domain-Driven Design (DDD)** combined with **Clean Architecture** and **BLoC** state management in Flutter. It focuses on complex domain modeling and business logic.

## What Makes This DDD (Not Just Clean Architecture)?

| Aspect | Clean Architecture | DDD + Clean Architecture |
|--------|-------------------|--------------------------|
| Focus | Layer separation | Domain modeling |
| Entities | Simple data classes | Rich domain models with behavior |
| Value Objects | Rare | Common, immutable |
| Aggregates | Not emphasized | Core concept |
| Business Rules | In use cases | In entities AND aggregates |
| Language | Technical | Ubiquitous (domain-driven) |
| Complexity | Good for all apps | Best for complex domains |

## Architecture Layers

```
┌──────────────────────────────────────────────────────────┐
│                  Presentation Layer                       │
│                  (BLoC/Cubit + Views)                    │
│  - Application Services (coordinates domain)             │
│  - UI State Management                                   │
└────────────────────┬─────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────┐
│               Domain Layer (Core)                        │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Entities (with identity & behavior)                │ │
│  │ - Note, NoteCollection, User                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Value Objects (immutable, no identity)             │ │
│  │ - NoteContent, Email, DateRange                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Aggregates (cluster with root)                     │ │
│  │ - NotesCollection (root), Note (child)             │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Domain Services (stateless operations)             │ │
│  │ - NoteStatistics, NoteValidator                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Repository Interfaces                              │ │
│  │ - NotesRepository, UserRepository                  │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Use Cases / Application Services                   │ │
│  │ - CreateNote, ArchiveNote, GetNotes                │ │
│  └────────────────────────────────────────────────────┘ │
└────────────────────┬─────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────┐
│                  Data Layer                              │
│  - Repository Implementations                            │
│  - Data Sources (Local/Remote)                           │
│  - Data Models (with JSON)                               │
└──────────────────────────────────────────────────────────┘
```

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── usecases/
│       └── usecase.dart
│
└── features/
    └── notes/                          # Bounded Context
        │
        ├── domain/                     # Domain Layer
        │   ├── entities/
        │   │   ├── note.dart                # Entity with ID & behavior
        │   │   └── notes_collection.dart    # Aggregate Root
        │   │
        │   ├── value_objects/
        │   │   ├── note_content.dart        # Value Object
        │   │   ├── note_id.dart
        │   │   └── timestamp.dart
        │   │
        │   ├── services/
        │   │   ├── note_statistics.dart     # Domain Service
        │   │   └── note_validator.dart
        │   │
        │   ├── repositories/
        │   │   └── notes_repository.dart    # Interface
        │   │
        │   ├── events/
        │   │   ├── note_created.dart        # Domain Event
        │   │   └── note_archived.dart
        │   │
        │   ├── factories/
        │   │   └── note_factory.dart        # Factory
        │   │
        │   └── usecases/
        │       ├── create_note.dart
        │       ├── archive_note.dart
        │       ├── get_notes.dart
        │       └── get_notes_statistics.dart
        │
        ├── data/                       # Data Layer
        │   ├── models/
        │   │   ├── note_model.dart
        │   │   └── notes_collection_model.dart
        │   ├── datasources/
        │   │   ├── notes_local_datasource.dart
        │   │   └── notes_remote_datasource.dart
        │   └── repositories/
        │       └── notes_repository_impl.dart
        │
        └── presentation/               # Presentation Layer
            ├── cubit/
            │   ├── notes_cubit.dart
            │   └── notes_state.dart
            ├── pages/
            │   └── notes_page.dart
            └── widgets/
                ├── notes_list.dart
                ├── note_item.dart
                └── add_note_field.dart
```

## Key DDD Patterns

### 1. Entity (with Identity)

```dart
import 'package:equatable/equatable.dart';
import '../value_objects/note_content.dart';

class Note extends Equatable {
  final String id;  // ← Identity
  final NoteContent content;
  final DateTime createdAt;
  final bool isArchived;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isArchived,
  });

  // Domain behavior
  Note archive() {
    if (isArchived) {
      throw StateError('Note is already archived');
    }
    
    return Note(
      id: id,  // Same identity
      content: content,
      createdAt: createdAt,
      isArchived: true,
    );
  }

  Note updateContent(NoteContent newContent) {
    return Note(
      id: id,
      content: newContent,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }

  // Equality by ID only
  @override
  List<Object?> get props => [id];
}
```

### 2. Value Object (No Identity)

```dart
class NoteContent extends Equatable {
  final String value;

  const NoteContent._(this.value);

  // Smart constructor with validation
  factory NoteContent.create(String input) {
    // Business rules enforced here
    if (input.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (input.length > 1000) {
      throw ArgumentError('Note content exceeds maximum length');
    }
    return NoteContent._(input.trim());
  }

  int get wordCount => value.split(' ').length;
  bool get isEmpty => value.isEmpty;

  @override
  List<Object?> get props => [value];
}
```

### 3. Aggregate Root

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
    
    if (_containsId(note.id)) {
      throw ArgumentError('Note with ID ${note.id} already exists');
    }
    
    return NotesCollection(
      notes: [..._notes, note],
      maxNotes: maxNotes,
    );
  }

  NotesCollection removeNote(String id) {
    final note = findById(id);
    if (note == null) {
      throw ArgumentError('Note with ID $id not found');
    }
    
    return NotesCollection(
      notes: _notes.where((n) => n.id != id).toList(),
      maxNotes: maxNotes,
    );
  }

  NotesCollection archiveNote(String id) {
    final noteIndex = _notes.indexWhere((n) => n.id == id);
    if (noteIndex == -1) {
      throw ArgumentError('Note with ID $id not found');
    }
    
    final updatedNotes = List<Note>.from(_notes);
    updatedNotes[noteIndex] = _notes[noteIndex].archive();
    
    return NotesCollection(notes: updatedNotes, maxNotes: maxNotes);
  }

  Note? findById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  bool _containsId(String id) => _notes.any((note) => note.id == id);

  // Getters
  int get count => _notes.length;
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get activeNotes => _notes.where((n) => !n.isArchived).toList();
  List<Note> get archivedNotes => _notes.where((n) => n.isArchived).toList();
  bool get isFull => _notes.length >= maxNotes;

  @override
  List<Object?> get props => [_notes, maxNotes];
}
```

### 4. Domain Service

```dart
class NoteStatistics {
  int countWords(Note note) {
    return note.content.wordCount;
  }

  double calculateReadingTime(Note note) {
    final words = countWords(note);
    return words / 200.0; // 200 words per minute
  }

  List<Note> sortByWordCount(List<Note> notes) {
    return notes..sort((a, b) => 
      countWords(a).compareTo(countWords(b))
    );
  }

  int getTotalWords(NotesCollection collection) {
    return collection.notes.fold(0, (sum, note) => 
      sum + countWords(note)
    );
  }
}
```

### 5. Factory

```dart
class NoteFactory {
  Note createNote({required String content}) {
    return Note(
      id: _generateId(),
      content: NoteContent.create(content),
      createdAt: DateTime.now(),
      isArchived: false,
    );
  }

  Note createArchivedNote({required String content}) {
    return Note(
      id: _generateId(),
      content: NoteContent.create(content),
      createdAt: DateTime.now(),
      isArchived: true,
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
```

### 6. Repository (Collection-like Interface)

```dart
// Domain Layer Interface
abstract class NotesRepository {
  Future<Either<Failure, NotesCollection>> getCollection();
  Future<Either<Failure, Unit>> saveCollection(NotesCollection collection);
  Future<Either<Failure, Note>> findNoteById(String id);
  Future<Either<Failure, List<Note>>> findNotesByCreatedDate(DateTime date);
}

// Data Layer Implementation
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, NotesCollection>> getCollection() async {
    try {
      final models = await localDataSource.getNotes();
      final notes = models.map((m) => m.toEntity()).toList();
      return Right(NotesCollection(notes: notes));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCollection(NotesCollection collection) async {
    try {
      final models = collection.notes
          .map((note) => NoteModel.fromEntity(note))
          .toList();
      await localDataSource.saveNotes(models);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

### 7. Use Case with Domain Logic

```dart
class CreateNote implements UseCase<NotesCollection, CreateNoteParams> {
  final NotesRepository repository;
  final NoteFactory noteFactory;
  final NoteValidator validator;

  CreateNote({
    required this.repository,
    required this.noteFactory,
    required this.validator,
  });

  @override
  Future<Either<Failure, NotesCollection>> call(CreateNoteParams params) async {
    // Validate input (domain service)
    final validationResult = validator.validate(params.content);
    if (validationResult.isFailure) {
      return Left(ValidationFailure(validationResult.error));
    }

    // Get current collection
    final collectionResult = await repository.getCollection();
    
    return collectionResult.fold(
      (failure) => Left(failure),
      (collection) async {
        try {
          // Create note (factory)
          final note = noteFactory.createNote(content: params.content);
          
          // Add to aggregate (business rules enforced)
          final updatedCollection = collection.addNote(note);
          
          // Save (repository)
          final saveResult = await repository.saveCollection(updatedCollection);
          
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updatedCollection),
          );
        } catch (e) {
          return Left(DomainFailure(e.toString()));
        }
      },
    );
  }
}

class CreateNoteParams {
  final String content;
  
  CreateNoteParams({required this.content});
}
```

### 8. BLoC/Cubit (Application Service)

```dart
class NotesCubit extends Cubit<NotesState> {
  final CreateNote createNote;
  final ArchiveNote archiveNote;
  final GetNotes getNotes;
  final GetNotesStatistics getStatistics;

  NotesCubit({
    required this.createNote,
    required this.archiveNote,
    required this.getNotes,
    required this.getStatistics,
  }) : super(NotesInitial());

  Future<void> loadNotes() async {
    emit(NotesLoading());
    
    final result = await getNotes(NoParams());
    
    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (collection) => emit(NotesLoaded(collection)),
    );
  }

  Future<void> addNote(String content) async {
    final result = await createNote(CreateNoteParams(content: content));
    
    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (collection) => emit(NotesLoaded(collection)),
    );
  }

  Future<void> archiveNoteById(String id) async {
    final result = await archiveNote(ArchiveNoteParams(noteId: id));
    
    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (collection) => emit(NotesLoaded(collection)),
    );
  }
}
```

## Complete Data Flow

```
1. USER ACTION
   └─ Tap "Add Note" button

2. VIEW
   └─ context.read<NotesCubit>().addNote(content)

3. CUBIT (Application Service)
   └─ await createNote(CreateNoteParams(content: content))

4. USE CASE
   ├─ Validate with NoteValidator (Domain Service)
   ├─ Create Note with NoteFactory (Factory)
   ├─ Get NotesCollection from repository
   ├─ collection.addNote(note) (Aggregate enforces rules)
   └─ repository.saveCollection(updatedCollection)

5. REPOSITORY
   ├─ Convert aggregate to models
   ├─ Call data source
   ├─ Handle exceptions → Failures
   └─ Return Either<Failure, Unit>

6. DATA SOURCE
   ├─ Serialize models to JSON
   ├─ Save to storage
   └─ Throw CacheException on error

7. RETURN PATH
   └─ Use Case → Cubit: Either<Failure, NotesCollection>

8. CUBIT
   └─ emit(NotesLoaded(updatedCollection))

9. VIEW
   └─ BlocBuilder rebuilds with new collection
```

## Benefits of DDD

1. ✅ **Rich Domain Model** - Entities have behavior, not just data
2. ✅ **Business Rules Enforced** - In aggregates and value objects
3. ✅ **Ubiquitous Language** - Same terms in code and business
4. ✅ **Bounded Contexts** - Clear feature boundaries
5. ✅ **Testable Domain Logic** - Pure Dart, no dependencies
6. ✅ **Maintainable** - Complex business logic organized
7. ✅ **Scalable** - Add features without breaking existing code

## When to Use DDD

### ✅ Use DDD When:
- Complex business rules
- Large team project
- Long-term project (years)
- Domain experts involved
- Business logic is core value

### ❌ Don't Use DDD When:
- Simple CRUD app
- Small project
- Prototype/MVP
- No complex business logic
- Learning Flutter basics

## Key Differences from Clean Architecture

```dart
// Clean Architecture Entity (Simple)
class Note extends Equatable {
  final String id;
  final String content;
  
  const Note({required this.id, required this.content});
  
  @override
  List<Object?> get props => [id, content];
}

// DDD Entity (Rich)
class Note extends Equatable {
  final String id;
  final NoteContent content;  // Value Object
  final DateTime createdAt;
  final bool isArchived;
  
  const Note({...});
  
  // Domain behavior
  Note archive() { ... }
  Note updateContent(NoteContent newContent) { ... }
  bool isOlderThan(Duration duration) { ... }
  
  @override
  List<Object?> get props => [id];  // Only ID
}
```

---

**DDD + Clean Architecture + BLoC = Ultimate enterprise Flutter architecture! 🚀**

See also:
- `DDD_CONCEPTS.md` - Detailed DDD concepts explanation
- `QUICK_START.md` - Quick start guide
- `PROJECT_SUMMARY.md` - Complete project overview
