# Counter Notes App - Domain-Driven Design (DDD)

A comprehensive Flutter application demonstrating **Domain-Driven Design (DDD)** principles with **GetX** state management.

## 📋 Table of Contents
- [Overview](#overview)
- [DDD Architecture](#ddd-architecture)
- [Project Structure](#project-structure)
- [Key Concepts](#key-concepts)
- [Features](#features)
- [Getting Started](#getting-started)
- [Learning Resources](#learning-resources)

## 🎯 Overview

This project showcases Domain-Driven Design implementation in Flutter, featuring:

- **Pure Domain Logic**: Business rules independent of frameworks
- **Value Objects**: Encapsulated validation and business rules
- **Entities**: Objects with identity and lifecycle
- **Repositories**: Abstract data access patterns
- **Use Cases**: Application services orchestrating domain logic
- **Dependency Inversion**: All layers depend on domain abstractions

### Why DDD?

**Domain-Driven Design** helps build complex applications by:
- Placing business logic at the center (domain layer)
- Creating a ubiquitous language between developers and domain experts
- Separating domain complexity from technical complexity
- Making the codebase more maintainable and testable

## 🏗️ DDD Architecture

### Layer Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│            (Controllers, Views, Bindings)                    │
│                         ↓ calls                              │
├─────────────────────────────────────────────────────────────┤
│                   APPLICATION LAYER                          │
│           (Use Cases - Business Workflows)                   │
│                    ↓ orchestrates                            │
├─────────────────────────────────────────────────────────────┤
│                     DOMAIN LAYER                             │
│  (Entities, Value Objects, Repository Interfaces)           │
│            ← Pure Business Logic (No Dependencies)           │
│                    ↑ implements                              │
├─────────────────────────────────────────────────────────────┤
│                 INFRASTRUCTURE LAYER                         │
│      (Repository Implementations, Data Sources, DTOs)        │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Flow

**Key Principle**: All dependencies point INWARD to the domain layer

- ✅ **Presentation** → Application → Domain
- ✅ **Infrastructure** → Domain (implements interfaces)
- ✅ **Application** → Domain (orchestrates entities)
- ❌ **Domain** → Nothing (pure business logic)

## 📁 Project Structure

```
lib/
├── domain/                           # DOMAIN LAYER (Pure Business Logic)
│   ├── core/
│   │   └── failures.dart            # Domain-level error types
│   ├── counter/
│   │   ├── entities/
│   │   │   └── counter_entity.dart  # Counter aggregate root
│   │   ├── value_objects/
│   │   │   └── counter_value.dart   # Value object with validation
│   │   └── repositories/
│   │       └── counter_repository.dart  # Repository interface
│   └── notes/
│       ├── entities/
│       │   └── note_entity.dart     # Note aggregate root
│       ├── value_objects/
│       │   ├── note_id.dart         # Identity value object
│       │   ├── note_content.dart    # Content with validation
│       │   └── note_timestamp.dart  # Timestamp value object
│       └── repositories/
│           └── notes_repository.dart    # Repository interface
│
├── application/                      # APPLICATION LAYER (Use Cases)
│   ├── counter/
│   │   └── usecases/
│   │       ├── get_counter_usecase.dart
│   │       ├── increment_counter_usecase.dart
│   │       ├── decrement_counter_usecase.dart
│   │       └── reset_counter_usecase.dart
│   └── notes/
│       └── usecases/
│           ├── get_all_notes_usecase.dart
│           ├── add_note_usecase.dart
│           ├── delete_note_usecase.dart
│           └── delete_all_notes_usecase.dart
│
├── infrastructure/                   # INFRASTRUCTURE LAYER (Implementation)
│   ├── counter/
│   │   ├── datasources/
│   │   │   └── counter_local_datasource.dart
│   │   ├── dtos/
│   │   │   └── counter_dto.dart     # Data transfer object
│   │   └── repositories/
│   │       └── counter_repository_impl.dart
│   └── notes/
│       ├── datasources/
│       │   └── notes_local_datasource.dart
│       ├── dtos/
│       │   └── note_dto.dart
│       └── repositories/
│           └── notes_repository_impl.dart
│
└── presentation/                     # PRESENTATION LAYER (UI)
    ├── counter/
    │   ├── bindings/
    │   │   └── counter_binding.dart
    │   ├── controllers/
    │   │   └── counter_controller.dart
    │   └── views/
    │       └── counter_view.dart
    ├── notes/
    │   ├── bindings/
    │   │   └── notes_binding.dart
    │   ├── controllers/
    │   │   └── notes_controller.dart
    │   └── views/
    │       └── notes_view.dart
    └── core/
        ├── routes/
        │   ├── app_routes.dart
        │   └── app_pages.dart
        └── views/
            └── home_view.dart
```

## 🔑 Key Concepts

### 1. Domain Layer (Core Business Logic)

**Entities** - Objects with identity:
```dart
class CounterEntity extends Equatable {
  final String id;
  final CounterValue value;  // Value object

  // Business rules encoded in methods
  CounterEntity increment() {
    return CounterEntity(
      id: id,
      value: value.increment(),
    );
  }
}
```

**Value Objects** - Objects without identity, defined by their values:
```dart
class CounterValue extends Equatable {
  final int number;

  factory CounterValue(int value) {
    if (value < 0) {
      throw ArgumentError('Counter value cannot be negative');
    }
    return CounterValue._(value);
  }

  // Business rule: decrement with validation
  CounterValue decrement() {
    if (number == 0) return this;  // Cannot go below zero
    return CounterValue._(number - 1);
  }
}
```

**Repository Interfaces** - Contracts for data access:
```dart
abstract class CounterRepository {
  Future<Either<Failure, CounterEntity>> getCounter();
  Future<Either<Failure, Unit>> saveCounter(CounterEntity counter);
}
```

### 2. Application Layer (Use Cases)

**Use Cases** orchestrate domain logic:
```dart
class IncrementCounterUseCase {
  final CounterRepository repository;

  Future<Either<Failure, CounterEntity>> execute() async {
    // Get current state
    final currentResult = await repository.getCounter();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (counter) async {
        // Apply domain logic
        final updatedCounter = counter.increment();
        
        // Persist
        await repository.saveCounter(updatedCounter);
        return Right(updatedCounter);
      },
    );
  }
}
```

### 3. Infrastructure Layer (Implementation)

**DTOs** (Data Transfer Objects) - Handle serialization:
```dart
class CounterDto {
  final String id;
  final int value;

  // Convert from domain entity
  factory CounterDto.fromEntity(CounterEntity entity) {
    return CounterDto(
      id: entity.id,
      value: entity.value.number,
    );
  }

  // Convert to domain entity
  CounterEntity toEntity() {
    return CounterEntity(
      id: id,
      value: CounterValue(value),
    );
  }
}
```

**Repository Implementation**:
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
}
```

### 4. Presentation Layer (UI)

**Controllers** call use cases:
```dart
class CounterController extends GetxController {
  final IncrementCounterUseCase incrementCounterUseCase;

  Future<void> increment() async {
    final result = await incrementCounterUseCase.execute();
    
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (counter) => _counter.value = counter,
    );
  }
}
```

## ✨ Features

### Counter Feature
- ➕ **Increment**: Increase counter value
- ➖ **Decrement**: Decrease counter (domain rule: cannot go below 0)
- 🔄 **Reset**: Reset to zero
- 💾 **Persistence**: State saved across app restarts
- 📏 **Domain Rules**: Enforced by value objects and entities

### Notes Feature
- ✍️ **Add Notes**: Create notes with validation (max 500 chars)
- 📋 **View Notes**: Display all notes with timestamps
- 🗑️ **Delete Notes**: Remove individual or all notes
- 💾 **Persistence**: Notes saved locally with GetStorage
- ⏰ **Timestamps**: Relative time display (e.g., "2 minutes ago")

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.9.2
- Dart SDK >=3.9.2

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd ddd_architeture_pattern
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# On Chrome (Web)
flutter run -d chrome

# On Android
flutter run -d android

# On iOS
flutter run -d ios
```

## 🧪 Testing Philosophy

DDD makes testing natural:

**Unit Tests** (Domain Layer):
- Test entities and value objects in isolation
- No dependencies on frameworks or infrastructure
- Fast and reliable

**Use Case Tests** (Application Layer):
- Mock repository interfaces
- Test business workflows
- Verify orchestration logic

**Integration Tests** (Infrastructure Layer):
- Test repository implementations
- Verify data persistence
- Mock external dependencies

## 📦 Dependencies

### Core
- **get**: ^4.6.6 - State management, DI, routing
- **get_storage**: ^2.1.1 - Local persistence
- **dartz**: ^0.10.1 - Functional programming (Either type)
- **equatable**: ^2.0.5 - Value equality
- **uuid**: ^4.2.1 - Generate unique IDs

### Dev
- **flutter_test**: Unit and widget testing
- **flutter_lints**: ^5.0.0 - Linting rules

## 📚 Learning Resources

### DDD Books
- **"Domain-Driven Design" by Eric Evans** - The original DDD book
- **"Implementing Domain-Driven Design" by Vaughn Vernon** - Practical guide

### Articles
- [DDD Reference by Eric Evans](https://www.domainlanguage.com/ddd/reference/)
- [Martin Fowler's DDD Explanation](https://martinfowler.com/tags/domain%20driven%20design.html)

### Flutter DDD
- [Reso Coder's Flutter TDD DDD Series](https://resocoder.com/flutter-firebase-ddd-course/)

## 🎓 Key Takeaways

### What Makes This DDD?

1. **Ubiquitous Language**: Code uses domain terms (Counter, Note, Value)
2. **Bounded Contexts**: Counter and Notes are separate contexts
3. **Entities**: CounterEntity, NoteEntity have identity
4. **Value Objects**: CounterValue, NoteContent, NoteTimestamp
5. **Aggregates**: Entities with clear boundaries
6. **Repositories**: Abstract data access
7. **Domain Services**: Use cases coordinate complex operations
8. **Layered Architecture**: Clear separation of concerns

### Benefits Demonstrated

✅ **Testability**: Each layer tests independently  
✅ **Maintainability**: Changes isolated to specific layers  
✅ **Business Logic Clarity**: Domain layer is pure and readable  
✅ **Flexibility**: Easy to swap infrastructure (DB, API, etc.)  
✅ **Team Collaboration**: Clear boundaries for different developers  

## 🔍 Code Examples

### Adding a New Feature (DDD Way)

1. **Start with Domain**: Define entities and value objects
2. **Define Repository Interface**: In domain layer
3. **Create Use Cases**: Application services
4. **Implement Infrastructure**: Data sources and repositories
5. **Build UI**: Controllers and views

This order ensures business logic drives the architecture, not technical concerns.

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow DDD principles
4. Write tests for domain logic
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Built with ❤️ to demonstrate Domain-Driven Design in Flutter

---

## 🔍 Quick Command Reference

```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

---

**Happy Learning! 🚀**

*Remember: DDD is about keeping business logic pure, independent, and at the center of your application.*

