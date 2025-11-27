# Counter Notes App - Clean Architecture with Riverpod

A Flutter application demonstrating the **Clean Architecture** pattern using **Riverpod** for state management.

##  Architecture: Clean Architecture

The project is divided into three main layers:

### 1. Domain Layer (lib/features/*/domain/)
- **Entities**: Pure Dart objects representing the core business data.
- **Repositories**: Abstract classes defining the contract for data operations.
- **Use Cases**: Classes encapsulating specific business rules (e.g., GetCounter, AddNote).

### 2. Data Layer (lib/features/*/data/)
- **Models**: DTOs (Data Transfer Objects) that extend Entities and handle JSON serialization.
- **Data Sources**: Classes responsible for fetching data from external sources (e.g., SharedPreferences).
- **Repositories**: Implementations of the domain repositories.

### 3. Presentation Layer (lib/features/*/presentation/)
- **Providers**: State management using Riverpod (StateNotifier, Provider).
- **Pages**: UI screens.
- **Widgets**: Reusable UI components.

##  Project Structure

` 
lib/
 core/                          # Core functionality (Error handling, UseCase interface)
 features/                      # Feature-based organization
    counter/
       data/                  # Data layer
¦       domain/                # Domain layer
       presentation/          # Presentation layer
    notes/
        data/
        domain/
        presentation/
 main.dart                      # App entry point and Dependency Injection
` 

##  Dependencies

`yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2
  equatable: ^2.0.5
  dartz: ^0.10.1
` 

##  Getting Started

1. **Install dependencies**:
   `ash
   flutter pub get
   ` 

2. **Run the app**:
   `ash
   flutter pub run
   ` 

##  License

This project is created for educational purposes to demonstrate Clean Architecture with Riverpod in Flutter.
