# Domain-Driven Design (DDD) with Riverpod - Quick Start Guide

## 🎯 What is DDD?

Domain-Driven Design is an approach to software development that centers the development on programming a domain model that has a rich understanding of the processes and rules of a domain.

## 📦 Project Structure

```
lib/
├── application/       # State Management (Notifiers)
├── domain/            # Business Logic (Entities, Interfaces)
├── infrastructure/    # Data Access (Repositories, DTOs)
└── presentation/      # UI (Widgets, Pages)
```

## 🚀 Quick Run

```bash
# Navigate to project
cd riverpod/ddd_architecture_pattern

# Get dependencies
flutter pub get

# Generate code (Crucial for Freezed/JsonSerializable)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

## 🏗️ Layer Breakdown

### 1. Domain (Pure Business)
*   **Entities**: `Counter`, `Note`.
*   **Interfaces**: `ICounterRepository`.
*   **Failures**: `Failure`.

### 2. Infrastructure (Implementation)
*   **DTOs**: `CounterDto` (converts Domain <-> JSON).
*   **Repositories**: `CounterRepository` (implements `ICounterRepository`).

### 3. Application (Orchestration)
*   **Notifiers**: `CounterNotifier` (manages state using Domain objects).

### 4. Presentation (UI)
*   **Pages**: `CounterPage`.
*   **Providers**: Defined in `presentation/core/providers.dart`.

## 🔧 Code Generation

This project uses `freezed` and `json_serializable`. You must run the build runner whenever you change a file with `@freezed` or `@JsonSerializable`.

```bash
# One-time build
dart run build_runner build

# Watch mode (auto-rebuild on save)
dart run build_runner watch
```

## 📊 Data Flow Example

1.  **UI** calls `ref.read(counterNotifierProvider.notifier).increment()`.
2.  **Notifier** calls `counter.increment()` (Domain Logic).
3.  **Notifier** calls `repository.saveCounter(newCounter)`.
4.  **Repository** converts `Counter` -> `CounterDto` -> JSON.
5.  **Repository** saves to SharedPreferences.
6.  **Notifier** updates state with result.
7.  **UI** rebuilds.

## ✅ Benefits

*   **Rich Domain**: Logic is encapsulated in domain objects, not scattered.
*   **Decoupling**: Domain doesn't know about Flutter or Database.
*   **Type Safety**: Strong typing with Freezed and Dartz.
*   **Scalability**: Ready for complex business rules.

---

**DDD ensures your app's core logic remains clean and focused on the business problem!**
