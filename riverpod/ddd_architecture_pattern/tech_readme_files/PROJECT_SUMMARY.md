# Domain-Driven Design (DDD) with Riverpod - Project Summary

## 📋 Overview

This project implements **Domain-Driven Design (DDD)** principles using **Riverpod** for state management in Flutter. It emphasizes a rich domain model and strict separation of concerns.

## 🎯 Key Features

*   **Rich Domain Model**: Business logic resides in Entities and Value Objects, not in Services or UI.
*   **Strict Layering**: Domain, Infrastructure, Application, and Presentation layers.
*   **Functional Error Handling**: Using `dartz` (Either) to handle errors as values.
*   **Immutable Data**: Using `freezed` for immutable classes and unions.
*   **Dependency Injection**: Using Riverpod for clean DI.

## 📁 Project Structure

```
lib/
├── application/               # Application Services (StateNotifiers)
│   ├── counter/
│   └── notes/
│
├── domain/                    # Core Business Logic (Pure Dart)
│   ├── core/                  # Shared domain objects (Failures)
│   ├── counter/               # Counter Domain (Entities, Interfaces)
│   └── notes/                 # Notes Domain
│
├── infrastructure/            # Implementation Details
│   ├── counter/               # Counter Repositories & DTOs
│   └── notes/                 # Notes Repositories & DTOs
│
├── presentation/              # UI Layer
│   ├── core/                  # Shared UI & Providers
│   ├── counter/               # Counter Pages
│   └── notes/                 # Notes Pages
│
└── main.dart
```

## 🏗️ Architecture Layers

1.  **Domain Layer**: The "What". Defines *what* the business objects are and *what* they can do. Contains Entities, Value Objects, and Repository Interfaces.
2.  **Infrastructure Layer**: The "How". Defines *how* data is persisted and retrieved. Implements Repository Interfaces and handles serialization (DTOs).
3.  **Application Layer**: The "Orchestrator". Connects the UI to the Domain. Handles application state and user flows.
4.  **Presentation Layer**: The "View". Displays data and captures user input.

## 📦 Key Dependencies

*   `flutter_riverpod`: State management and DI.
*   `freezed_annotation`: Code generation for immutable classes.
*   `json_annotation`: JSON serialization.
*   `dartz`: Functional programming types (Either, Unit).
*   `shared_preferences`: Local storage.

## 🚀 Quick Start

1.  Run `flutter pub get`.
2.  Run `dart run build_runner build` to generate code (freezed/json_serializable).
3.  Run `flutter run`.

## 📚 Documentation

*   **`ARCHITECTURE.md`**: Detailed breakdown of the DDD layers and patterns used.
*   **`QUICK_START.md`**: Guide to running and understanding the project.

---

**This project demonstrates how to build complex, domain-centric Flutter apps using DDD and Riverpod.**
