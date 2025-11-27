# Counter Notes App - DDD with Riverpod

A Flutter application demonstrating the **Domain-Driven Design (DDD)** pattern using **Riverpod** for state management.

##  Architecture: Domain-Driven Design

The project is organized by layers and features (subdomains):

### 1. Domain Layer (lib/domain/)
- **Core**: Shared domain logic (Failures, Value Objects).
- **Features** (e.g., counter, 
otes):
  - **Entities**: Rich objects encapsulating business logic and state.
  - **Repositories**: Interfaces defining contracts for data access.

### 2. Infrastructure Layer (lib/infrastructure/)
- **DTOs**: Data Transfer Objects for external communication (JSON serialization).
- **Repositories**: Implementations of domain repositories using specific technologies (e.g., SharedPreferences).

### 3. Application Layer (lib/application/)
- **Notifiers**: Application Services that orchestrate domain logic and manage state (using StateNotifier).

### 4. Presentation Layer (lib/presentation/)
- **Providers**: Dependency Injection and State Management wiring.
- **Pages/Widgets**: UI components.

##  Project Structure

` 
lib/
 application/               # Application Services (StateNotifiers)
 domain/                    # Enterprise Business Rules
    core/                  # Shared domain kernel
    counter/               # Counter subdomain
    notes/                 # Notes subdomain
 infrastructure/            # Interface Adapters (Repositories, DTOs)
 presentation/              # UI and Frameworks
 main.dart                  # App entry point
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
  uuid: ^4.2.1
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

This project is created for educational purposes to demonstrate DDD with Riverpod in Flutter.
