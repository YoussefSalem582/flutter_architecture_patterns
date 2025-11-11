# Counter Notes App - Clean Architecture Pattern

A comprehensive Flutter application demonstrating **Clean Architecture** principles with **GetX** state management and **GetStorage** for local persistence.

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Key Concepts](#key-concepts)
- [Dependencies](#dependencies)
- [Testing](#testing)
- [Contributing](#contributing)

## 🎯 Overview

This project showcases a robust implementation of Clean Architecture in Flutter, featuring:
- **Counter Feature**: Increment, decrement, and reset counter with persistent storage
- **Notes Feature**: Add, view, and delete notes with local persistence
- **Clean Architecture**: Strict separation of concerns across three layers
- **Dependency Inversion**: Domain layer defines contracts, outer layers depend on abstractions
- **GetX State Management**: Reactive state with minimal boilerplate
- **GetStorage**: Fast, lightweight local storage solution
- **Functional Programming**: Either pattern for error handling using Dartz

## 🏗️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Views, Controllers, Bindings - depends on DOMAIN only)    │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│     (Entities, Use Cases, Repository Interfaces)             │
│              (No dependencies - Pure Dart)                   │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│   (Models, Repositories, Data Sources - depends on DOMAIN)  │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Rule
**Dependencies point inward**: Presentation → Domain ← Data

- **Presentation Layer** imports only from Domain
- **Data Layer** imports only from Domain
- **Domain Layer** has NO external dependencies (pure business logic)

### Layer Responsibilities

#### 1. Domain Layer (Business Logic)
- **Entities**: Core business objects (immutable, use Equatable)
- **Use Cases**: Single-responsibility business operations
- **Repository Interfaces**: Contracts for data access (abstract classes)

#### 2. Data Layer (Data Management)
- **Models**: Data transfer objects extending entities with JSON serialization
- **Repositories**: Concrete implementations of domain repository interfaces
- **Data Sources**: External data providers (local storage, APIs)

#### 3. Presentation Layer (UI)
- **Views**: Flutter widgets for UI presentation
- **Controllers**: GetX controllers managing reactive state
- **Bindings**: Dependency injection setup for each feature

## ✨ Features

### Counter Feature
- ➕ Increment counter
- ➖ Decrement counter
- 🔄 Reset counter to zero
- 💾 Automatic persistence across app restarts
- 🎨 Material Design 3 UI

### Notes Feature
- ✍️ Add new notes with content
- 📋 View all saved notes
- 🗑️ Delete individual notes
- 🧹 Clear all notes at once
- 💾 Persistent storage with GetStorage
- ⏰ Timestamp for each note

## 📁 Project Structure

```
lib/
├── core/                           # Shared infrastructure
│   ├── constants/
│   │   └── storage_keys.dart       # Storage key constants
│   ├── error/
│   │   └── failures.dart           # Error handling abstractions
│   ├── presentation/
│   │   └── views/
│   │       └── home_view.dart      # Home landing page
│   ├── routes/
│   │   ├── app_pages.dart          # GetX route configuration
│   │   └── app_routes.dart         # Route name constants
│   ├── theme/
│   │   └── app_theme.dart          # Light/Dark theme definitions
│   ├── usecases/
│   │   └── usecase.dart            # Base use case interface
│   └── utils/
│       └── logger.dart             # Logging utility
│
├── features/                       # Feature modules
│   ├── counter/                    # Counter feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── counter_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── counter_model.dart
│   │   │   └── repositories/
│   │   │       └── counter_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── counter.dart
│   │   │   ├── repositories/
│   │   │   │   └── counter_repository.dart
│   │   │   └── usecases/
│   │   │       ├── decrement_counter.dart
│   │   │       ├── get_counter.dart
│   │   │       ├── increment_counter.dart
│   │   │       └── reset_counter.dart
│   │   └── presentation/
│   │       ├── bindings/
│   │       │   └── counter_binding.dart
│   │       ├── controllers/
│   │       │   └── counter_controller.dart
│   │       └── views/
│   │           └── counter_view.dart
│   │
│   └── notes/                      # Notes feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── notes_local_datasource.dart
│       │   ├── models/
│       │   │   └── note_model.dart
│       │   └── repositories/
│       │       └── notes_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── note.dart
│       │   ├── repositories/
│       │   │   └── notes_repository.dart
│       │   └── usecases/
│       │       ├── add_note.dart
│       │       ├── delete_all_notes.dart
│       │       ├── delete_note.dart
│       │       └── get_all_notes.dart
│       └── presentation/
│           ├── bindings/
│           │   └── notes_binding.dart
│           ├── controllers/
│           │   └── notes_controller.dart
│           └── views/
│               └── notes_view.dart
│
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: `>=3.9.2 <4.0.0`
- Dart SDK: `>=3.9.2 <4.0.0`

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd clean_architeture_pattern
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

## 🔑 Key Concepts

### 1. Clean Architecture Benefits
- ✅ **Testability**: Each layer can be tested independently
- ✅ **Maintainability**: Changes in one layer don't affect others
- ✅ **Scalability**: Easy to add new features following the pattern
- ✅ **Flexibility**: Swap implementations without changing business logic
- ✅ **Separation of Concerns**: Each layer has a single responsibility

### 2. GetX State Management
```dart
// Reactive state with .obs
final counter = 0.obs;

// Reactive UI with Obx
Obx(() => Text('${controller.counter.value}'))
```

### 3. Use Case Pattern
Each business operation is a separate class:
```dart
class IncrementCounter extends UseCase<Counter, NoParams> {
  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    // Business logic here
  }
}
```

### 4. Repository Pattern
Domain defines the contract, Data implements it:
```dart
// Domain layer (interface)
abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();
  Future<Either<Failure, Counter>> saveCounter(Counter counter);
}

// Data layer (implementation)
class CounterRepositoryImpl implements CounterRepository {
  // Concrete implementation using data source
}
```

### 5. Error Handling with Either
Using Dartz for functional error handling:
```dart
Either<Failure, Counter> result = await getCounterUseCase(NoParams());
result.fold(
  (failure) => handleError(failure),  // Left: Error
  (counter) => handleSuccess(counter), // Right: Success
);
```

## 📦 Dependencies

### Core Dependencies
- **get**: ^4.6.6 - State management, DI, and routing
- **get_storage**: ^2.1.1 - Fast local storage
- **dartz**: ^0.10.1 - Functional programming (Either type)
- **equatable**: ^2.0.5 - Value equality for entities

### Dev Dependencies
- **flutter_test**: SDK version - Unit and widget testing
- **flutter_lints**: ^5.0.0 - Linting rules

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Test Coverage
```bash
flutter test --coverage
```

### Test Structure
```
test/
├── features/
│   ├── counter/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── notes/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── core/
```

## 🎨 Code Style

### Naming Conventions
- **Files**: snake_case (e.g., `counter_controller.dart`)
- **Classes**: PascalCase (e.g., `CounterController`)
- **Variables**: camelCase (e.g., `counterValue`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `COUNTER_KEY`)

### Architecture Guidelines
1. **Domain Layer**: No Flutter/package dependencies (pure Dart)
2. **Use Cases**: Single responsibility, one action per class
3. **Entities**: Immutable, use Equatable for value comparison
4. **Controllers**: Business logic only, no UI code
5. **Views**: Stateless widgets, reactive with Obx()

## 📚 Learn More

### Clean Architecture Resources
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

### GetX Resources
- [GetX Documentation](https://pub.dev/packages/get)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)

### GetStorage Resources
- [GetStorage Documentation](https://pub.dev/packages/get_storage)

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Built with ❤️ using Flutter and Clean Architecture principles

---

## 🔍 Quick Command Reference

```bash
# Install dependencies
flutter pub get

# Run app (Chrome)
flutter run -d chrome

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated

# Analyze code
flutter analyze

# Format code
dart format .

# Build APK (Android)
flutter build apk

# Build Web
flutter build web
```

---

**Happy Coding! 🚀**

