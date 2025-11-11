# Domain-Driven Design - Deep Dive

## Table of Contents
1. [What is DDD?](#what-is-ddd)
2. [Core Building Blocks](#core-building-blocks)
3. [Strategic Design](#strategic-design)
4. [Tactical Design](#tactical-design)
5. [DDD vs Other Architectures](#ddd-vs-other-architectures)
6. [Implementation Patterns](#implementation-patterns)
7. [Best Practices](#best-practices)

---

## What is DDD?

**Domain-Driven Design** is an approach to software development that:
- Places the **business domain** at the center of the software
- Creates a **ubiquitous language** shared by developers and domain experts
- Models complex business logic through **domain models**
- Separates technical concerns from business logic

### Why Use DDD?

✅ **Complex Business Logic**: When your app has rich business rules  
✅ **Long-term Projects**: Maintainability over years  
✅ **Team Collaboration**: Clear communication between technical and non-technical stakeholders  
✅ **Evolving Requirements**: Easy to adapt to changing business needs  

### When NOT to Use DDD?

❌ **Simple CRUD Apps**: Overhead not justified  
❌ **Short-lived Prototypes**: Too much upfront design  
❌ **Data-centric Applications**: When business logic is minimal  

---

## Core Building Blocks

### 1. Entities

**Definition**: Objects with **identity** and **lifecycle**

**Characteristics**:
- Have unique identifier
- Can change over time
- Identity remains constant
- Tracked throughout their lifecycle

**Example from our app**:
```dart
class CounterEntity extends Equatable {
  final String id;           // Identity
  final CounterValue value;  // State

  const CounterEntity({
    required this.id,
    required this.value,
  });

  // Business rule encoded in entity
  CounterEntity increment() {
    return CounterEntity(
      id: id,  // Identity preserved
      value: value.increment(),
    );
  }

  @override
  List<Object?> get props => [id, value];  // Identity matters!
}
```

**Key Points**:
- Equality based on ID, not content
- Encapsulate business rules as methods
- Immutable (return new instances)

### 2. Value Objects

**Definition**: Objects without **identity**, defined entirely by their **values**

**Characteristics**:
- No unique identifier
- Immutable
- Compared by value, not reference
- Encapsulate validation rules
- Can be replaced, not modified

**Example from our app**:
```dart
class CounterValue extends Equatable {
  final int number;

  const CounterValue._(this.number);

  factory CounterValue(int value) {
    // Validation rule
    if (value < 0) {
      throw ArgumentError('Counter value cannot be negative');
    }
    return CounterValue._(value);
  }

  // Business rule
  CounterValue increment() {
    return CounterValue._(number + 1);
  }

  // Business rule with validation
  CounterValue decrement() {
    if (number == 0) {
      return this;  // Cannot go below zero
    }
    return CounterValue._(number - 1);
  }

  @override
  List<Object?> get props => [number];  // Value equality
}
```

**Why Value Objects?**
- Centralize validation logic
- Make domain rules explicit
- Prevent primitive obsession
- Improve code readability

**Value Objects in Notes Feature**:
```dart
// Identity value object
class NoteId extends Equatable {
  final String value;
  const NoteId(this.value);
  
  @override
  List<Object?> get props => [value];
}

// Content with validation
class NoteContent extends Equatable {
  final String text;

  factory NoteContent(String content) {
    if (content.isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (content.length > 500) {
      throw ArgumentError('Note content cannot exceed 500 characters');
    }
    return NoteContent._(content.trim());
  }
  
  const NoteContent._(this.text);
  
  @override
  List<Object?> get props => [text];
}

// Timestamp with formatting
class NoteTimestamp extends Equatable {
  final DateTime dateTime;

  const NoteTimestamp._(this.dateTime);

  factory NoteTimestamp.now() {
    return NoteTimestamp._(DateTime.now());
  }

  // Domain-specific formatting
  String get formatted {
    return '${dateTime.year}-${_pad(dateTime.month)}-${_pad(dateTime.day)} '
        '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}';
  }

  String get relative {
    // Business logic for relative time
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    // ... more rules
  }
}
```

### 3. Aggregates

**Definition**: Cluster of entities and value objects treated as a **single unit**

**Characteristics**:
- Has one **aggregate root** (entry point)
- Enforces consistency boundaries
- External objects only reference the root
- Changes happen through the root

**In Our App**:
- `CounterEntity` is an aggregate root (simple aggregate)
- `NoteEntity` is an aggregate root (contains value objects)

**Example**:
```dart
class NoteEntity extends Equatable {
  final NoteId id;              // Identity
  final NoteContent content;    // Value object
  final NoteTimestamp createdAt; // Value object

  const NoteEntity({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  // Business rule: update content
  NoteEntity updateContent(String newContent) {
    return NoteEntity(
      id: id,
      content: NoteContent(newContent),  // Validation happens here
      createdAt: createdAt,  // Preserve timestamp
    );
  }

  // Business rule: check validity
  bool get isValid => content.isValid;

  @override
  List<Object?> get props => [id, content, createdAt];
}
```

### 4. Repositories

**Definition**: Abstractions for **accessing aggregates**

**Characteristics**:
- Defined in domain layer (interface)
- Implemented in infrastructure layer
- Work with aggregate roots
- Hide persistence details

**Domain Layer (Interface)**:
```dart
abstract class CounterRepository {
  Future<Either<Failure, CounterEntity>> getCounter();
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter);
  Future<bool> exists();
}
```

**Infrastructure Layer (Implementation)**:
```dart
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource dataSource;

  @override
  Future<Either<Failure, CounterEntity>> getCounter() async {
    try {
      final dto = await dataSource.getCounter();
      return Right(dto.toEntity());  // DTO → Entity
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter) async {
    try {
      final dto = CounterDto.fromEntity(counter);  // Entity → DTO
      await dataSource.saveCounter(dto);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}
```

### 5. Domain Services

**Definition**: Operations that **don't naturally belong** to an entity or value object

**When to Use**:
- Operation involves multiple aggregates
- Logic doesn't fit in one entity
- Stateless operations

**In Our App**: Use cases act as application services (similar to domain services)

**Example**:
```dart
class IncrementCounterUseCase {
  final CounterRepository repository;

  IncrementCounterUseCase(this.repository);

  Future<Either<Failure, CounterEntity>> execute() async {
    // Coordinate between repository and entity
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (counter) async {
        // Domain logic
        final updatedCounter = counter.increment();
        
        // Persistence
        final saveResult = await repository.saveCounter(updatedCounter);
        
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right(updatedCounter),
        );
      },
    );
  }
}
```

### 6. Factories

**Definition**: Objects responsible for **creating complex aggregates**

**Example**:
```dart
class NoteEntity {
  // Factory method
  factory NoteEntity.create({
    required String id,
    required String content,
  }) {
    return NoteEntity(
      id: NoteId(id),
      content: NoteContent(content),
      createdAt: NoteTimestamp.now(),
    );
  }
}

// Usage
final note = NoteEntity.create(
  id: uuid.v4(),
  content: 'My note',
);
```

---

## Strategic Design

### Bounded Contexts

**Definition**: Explicit boundaries within which a **domain model** is defined

**In Our App**:
- **Counter Context**: Counter domain with its entities and rules
- **Notes Context**: Notes domain with its entities and rules

**Folder Structure Reflects Bounded Contexts**:
```
lib/
  domain/
    counter/   ← Counter bounded context
    notes/     ← Notes bounded context
  application/
    counter/   ← Counter application services
    notes/     ← Notes application services
```

### Ubiquitous Language

**Definition**: **Shared vocabulary** between developers and domain experts

**Examples from Our App**:
- "Counter" (not "integer storage")
- "Increment/Decrement" (not "add/subtract")
- "Note" (not "text entry")
- "Content" (not "string data")
- "Timestamp" (not "DateTime")

**Code Should Read Like Business Rules**:
```dart
// Good - uses ubiquitous language
final updatedCounter = counter.increment();
final note = NoteEntity.create(id: id, content: content);

// Bad - technical jargon
final updatedNumber = number + 1;
final textEntry = TextEntry(data: data);
```

---

## Tactical Design

### Domain Layer

**Rules**:
- ✅ Pure Dart (no Flutter dependencies)
- ✅ No external package dependencies (except utilities like Equatable, Dartz)
- ✅ Contains business logic only
- ✅ Defines interfaces for repositories

**Structure**:
```
domain/
  core/
    failures.dart          ← Domain error types
  counter/
    entities/
    value_objects/
    repositories/          ← Interfaces only
  notes/
    entities/
    value_objects/
    repositories/          ← Interfaces only
```

### Application Layer

**Purpose**: Orchestrate domain logic for **specific use cases**

**Characteristics**:
- Coordinate between repositories and entities
- Handle application workflows
- Return Either<Failure, Success>

**Structure**:
```
application/
  counter/
    usecases/
      get_counter_usecase.dart
      increment_counter_usecase.dart
  notes/
    usecases/
      add_note_usecase.dart
      get_all_notes_usecase.dart
```

### Infrastructure Layer

**Purpose**: Implement **technical concerns** (persistence, external services)

**Components**:
- **Data Sources**: Low-level persistence (GetStorage, API calls)
- **DTOs**: Data Transfer Objects for serialization
- **Repository Implementations**: Implement domain interfaces

**Structure**:
```
infrastructure/
  counter/
    datasources/           ← GetStorage operations
    dtos/                  ← JSON serialization
    repositories/          ← Implement domain interfaces
  notes/
    datasources/
    dtos/
    repositories/
```

**DTO Pattern**:
```dart
class CounterDto {
  final String id;
  final int value;

  // From domain entity
  factory CounterDto.fromEntity(CounterEntity entity) {
    return CounterDto(
      id: entity.id,
      value: entity.value.number,  // Extract from value object
    );
  }

  // To domain entity
  CounterEntity toEntity() {
    return CounterEntity(
      id: id,
      value: CounterValue(value),  // Reconstruct value object
    );
  }

  // JSON serialization
  factory CounterDto.fromJson(Map<String, dynamic> json) {
    return CounterDto(
      id: json['id'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }
}
```

### Presentation Layer

**Purpose**: UI and user interaction

**Components**:
- **Controllers**: Call use cases, manage UI state (GetX)
- **Views**: Display domain concepts
- **Bindings**: Dependency injection

**Structure**:
```
presentation/
  counter/
    bindings/
    controllers/
    views/
  notes/
    bindings/
    controllers/
    views/
  core/
    routes/
    views/
```

---

## DDD vs Other Architectures

### DDD vs Clean Architecture

**Similarities**:
- Layer separation
- Dependency inversion
- Domain at the center

**Differences**:
| DDD | Clean Architecture |
|-----|-------------------|
| Focus on **business domain** | Focus on **use cases** |
| **Entities** have behavior | Entities are data structures |
| **Value objects** central | Value objects optional |
| **Bounded contexts** | Feature modules |
| **Ubiquitous language** | Technical separation |

### DDD vs MVC

| DDD | MVC |
|-----|-----|
| **Domain-centric** | **UI-centric** |
| Rich domain models | Anemic models |
| Business logic in domain | Business logic in controllers |
| Value objects | Primitives |
| Repository interfaces | Direct data access |

### DDD vs MVVM

| DDD | MVVM |
|-----|------|
| **Domain layer** separate | Business logic in ViewModels |
| **Use cases** coordinate | ViewModels coordinate |
| Entities with behavior | Models as data |
| Repository abstractions | Services or repositories |

---

## Implementation Patterns

### Error Handling with Either

**DDD uses functional approach**:
```dart
// Use case returns Either<Failure, Success>
Future<Either<Failure, CounterEntity>> execute() async {
  final result = await repository.getCounter();
  
  return result.fold(
    (failure) => Left(failure),  // Error path
    (counter) => Right(counter.increment()),  // Success path
  );
}

// Controller handles both cases
final result = await useCase.execute();
result.fold(
  (failure) => showError(failure.message),
  (counter) => updateUI(counter),
);
```

### Validation in Value Objects

**Centralize validation**:
```dart
class NoteContent extends Equatable {
  final String text;

  factory NoteContent(String content) {
    // All validation in one place
    if (content.isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (content.length > 500) {
      throw ArgumentError('Note content cannot exceed 500 characters');
    }
    return NoteContent._(content.trim());
  }

  const NoteContent._(this.text);

  // Validation predicates
  bool get isEmpty => text.isEmpty;
  bool get isValid => text.isNotEmpty && text.length <= 500;
  int get length => text.length;
}
```

### Repository Pattern

**Domain defines WHAT, Infrastructure defines HOW**:
```dart
// Domain: Interface (what)
abstract class NotesRepository {
  Future<Either<Failure, List<NoteEntity>>> getAllNotes();
  Future<Either<Failure, Unit>> addNote(NoteEntity note);
}

// Infrastructure: Implementation (how)
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource dataSource;  // Could be API, DB, etc.

  @override
  Future<Either<Failure, List<NoteEntity>>> getAllNotes() async {
    final dtos = await dataSource.getAllNotes();
    final entities = dtos.map((dto) => dto.toEntity()).toList();
    return Right(entities);
  }
}
```

---

## Best Practices

### 1. Keep Domain Pure

✅ **Do**:
- Use only Dart core libraries
- Encode business rules in entities
- Use value objects for validation
- Define repository interfaces

❌ **Don't**:
- Import Flutter packages in domain
- Use infrastructure types (JSON, Database objects)
- Mix UI concerns with business logic

### 2. Use Meaningful Names

**Ubiquitous Language**:
```dart
// Good
class NoteEntity {
  NoteEntity updateContent(String newContent) { ... }
}

// Bad
class Note {
  Note changeText(String text) { ... }
}
```

### 3. Small Value Objects

Create value objects even for "simple" types:
```dart
// Instead of String
class NoteId extends Equatable {
  final String value;
  const NoteId(this.value);
}

// Instead of DateTime
class NoteTimestamp extends Equatable {
  final DateTime dateTime;
  
  String get formatted { ... }
  String get relative { ... }
}
```

### 4. Immutability

**All domain objects immutable**:
```dart
class CounterEntity {
  final String id;
  final CounterValue value;

  // Return NEW instance, don't modify
  CounterEntity increment() {
    return CounterEntity(
      id: id,
      value: value.increment(),
    );
  }
}
```

### 5. Business Rules in Domain

❌ **Bad** - Logic in controller:
```dart
class CounterController {
  void increment() {
    if (counter.value < 0) {  // Business rule in UI!
      counter.value = 0;
    }
    counter.value++;
  }
}
```

✅ **Good** - Logic in value object:
```dart
class CounterValue {
  CounterValue decrement() {
    if (number == 0) {  // Business rule in domain!
      return this;
    }
    return CounterValue._(number - 1);
  }
}
```

### 6. Repository Per Aggregate

Each aggregate root has its own repository:
```dart
// Counter aggregate → Counter repository
abstract class CounterRepository {
  Future<Either<Failure, CounterEntity>> getCounter();
}

// Note aggregate → Notes repository
abstract class NotesRepository {
  Future<Either<Failure, List<NoteEntity>>> getAllNotes();
}
```

### 7. Use Cases for Orchestration

Don't put orchestration logic in controllers:
```dart
// ✅ Good - Use case orchestrates
class IncrementCounterUseCase {
  Future<Either<Failure, CounterEntity>> execute() async {
    final current = await repository.getCounter();
    return current.fold(
      (failure) => Left(failure),
      (counter) async {
        final updated = counter.increment();
        await repository.saveCounter(updated);
        return Right(updated);
      },
    );
  }
}

// Controller just calls use case
class CounterController {
  Future<void> increment() async {
    final result = await incrementCounterUseCase.execute();
    result.fold(
      (failure) => showError(failure),
      (counter) => _counter.value = counter,
    );
  }
}
```

---

## Summary

### DDD Key Principles

1. **Domain First**: Business logic is central
2. **Ubiquitous Language**: Code speaks business
3. **Bounded Contexts**: Clear module boundaries
4. **Rich Domain Models**: Entities with behavior
5. **Value Objects**: Validation and rules
6. **Dependency Inversion**: All point to domain
7. **Layered Architecture**: Separation of concerns

### When to Use DDD

✅ Complex business rules  
✅ Long-term maintainability  
✅ Evolving requirements  
✅ Team collaboration  

### DDD Benefits in This App

- **Counter**: Value object enforces "cannot go below zero"
- **Notes**: Content validation, timestamp formatting
- **Testability**: Each layer tests independently
- **Flexibility**: Easy to swap GetStorage for Firebase
- **Clarity**: Code reads like business requirements

---

**Remember**: DDD is about **understanding the business domain** and **expressing it in code**. The technical patterns serve this goal.
