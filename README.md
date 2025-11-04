# Flutter Architecture Patterns

A comprehensive collection of Flutter projects demonstrating **four different architecture patterns** for building scalable and maintainable applications. All patterns implement **identical features and UI** for easy comparison.

## 📚 Architecture Patterns

### 1. MVC (Model-View-Controller)
📁 `mvc_architeture_pattern/`

**Pattern Overview:**
- **Model**: Data and business logic
- **View**: UI components
- **Controller**: Mediates between Model and View

**Best For:** Small to medium apps, rapid prototyping, learning Flutter basics

**Features:**
- ✅ Counter with increment/decrement/reset
- ✅ Notes with add/view/delete
- ✅ Theme toggle (dark/light)
- ✅ Home view with navigation
- ✅ Persistent storage (in-memory)

**Complexity:** ⭐ Simple | **Files:** ~10 | **Lines:** ~800

---

### 2. MVVM (Model-View-ViewModel)
📁 `mvvm_architeture_pattern/`

**Pattern Overview:**
- **Model**: Data entities
- **View**: UI components
- **ViewModel**: Presentation logic with observables

**Best For:** Medium to large apps, complex UI state, reactive programming

**Features:**
- ✅ Counter with increment/decrement/reset
- ✅ Notes with add/view/delete
- ✅ Theme toggle (dark/light)
- ✅ Home view with navigation
- ✅ Persistent storage with GetStorage

**Complexity:** ⭐⭐ Moderate | **Files:** ~15 | **Lines:** ~1,000

---

### 3. Clean Architecture
📁 `clean_architeture_pattern/`

**Pattern Overview:**
- **Data Layer**: Repositories, data sources, models
- **Domain Layer**: Use cases, entities, repository interfaces
- **Presentation Layer**: Controllers, views, bindings

**Best For:** Large scalable apps, multiple teams, high testability requirements

**Features:**
- ✅ Counter with increment/decrement/reset
- ✅ Notes with add/view/delete
- ✅ Theme toggle (dark/light)
- ✅ Home view with navigation
- ✅ Persistent storage with GetStorage
- ✅ Framework-independent domain layer

**Complexity:** ⭐⭐⭐ Complex | **Files:** ~25 | **Lines:** ~1,500

---

### 4. DDD (Domain-Driven Design)
📁 `ddd_architeture_pattern/`

**Pattern Overview:**
- **Domain Layer**: Entities, value objects, repository interfaces (pure Dart)
- **Application Layer**: Use cases orchestrating domain logic
- **Infrastructure Layer**: DTOs, data sources, repository implementations
- **Presentation Layer**: Controllers, views, bindings

**Best For:** Enterprise applications, complex business logic, evolving requirements

**Features:**
- ✅ Counter with increment/decrement/reset
- ✅ Notes with add/view/delete
- ✅ Theme toggle (dark/light)
- ✅ Home view with navigation
- ✅ Persistent storage with GetStorage
- ✅ Pure domain layer (zero Flutter dependencies)
- ✅ Value objects with validation
- ✅ Rich domain models with behavior

**Complexity:** ⭐⭐⭐⭐ Most Complex | **Files:** ~40 | **Lines:** ~2,500

---

## 🎯 Why This Repository?

### ✨ Standardized Features
All four patterns implement **identical features** with **consistent UI/UX**:
- Same Counter and Notes functionality
- Identical home view design
- Consistent theme toggle
- Uniform styling and layouts

This allows you to:
- 🔍 **Compare** architectures side-by-side
- 📚 **Learn** pattern differences without UI distractions
- 🎯 **Choose** the right pattern for your project
- 💡 **Understand** trade-offs clearly

### � Comprehensive Documentation
- **STANDARDIZATION_SUMMARY.md** - Complete standardization details
- **COMPARISON_GUIDE.md** - In-depth pattern comparison
- Each project has detailed README and code comments

### ✅ Production Ready
- Clean, maintainable code
- Best practices implementation
- Zero compilation errors
- GetX state management
- Proper error handling

---

## 🚀 Getting Started

### Requirements
- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- VS Code or Android Studio (recommended)

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YoussefSalem582/flutter_architecture_patterns.git
   cd flutter_architecture_patterns
   ```

2. **Choose a pattern and navigate to it:**
   ```bash
   # For MVC
   cd mvc_architeture_pattern
   
   # For MVVM
   cd mvvm_architeture_pattern
   
   # For Clean Architecture
   cd clean_architeture_pattern
   
   # For DDD
   cd ddd_architeture_pattern
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   
   # Or run on specific device
   flutter run -d chrome
   flutter run -d windows
   ```

---

## 📖 Learning Path

### Recommended Order (Beginner → Advanced):

#### Week 1: **MVC Pattern** ⭐
- Understand basic separation of concerns
- Learn Model-View-Controller fundamentals
- Build simple apps quickly
- **Start Here** if new to Flutter architecture

#### Week 2-3: **MVVM Pattern** ⭐⭐
- Learn reactive programming with GetX
- Understand ViewModel pattern
- Master observable state management
- **Choose This** for UI-heavy apps

#### Week 4-6: **Clean Architecture** ⭐⭐⭐
- Understand layered architecture
- Learn use case pattern
- Master dependency inversion
- **Choose This** for large-scale apps

#### Week 7-12: **DDD Pattern** ⭐⭐⭐⭐
- Master tactical DDD patterns
- Understand value objects and entities
- Learn bounded contexts
- **Choose This** for enterprise apps

---

## 📊 Quick Comparison

| Feature | MVC | MVVM | Clean | DDD |
|---------|-----|------|-------|-----|
| **Layers** | 3 | 3 | 3 | 4 |
| **Complexity** | Simple | Moderate | Complex | Most Complex |
| **Learning Curve** | Easy | Moderate | Hard | Very Hard |
| **Files** | ~10 | ~15 | ~25 | ~40 |
| **Best For** | Small apps | Medium apps | Large apps | Enterprise |
| **Testability** | Moderate | Good | Excellent | Best |

See **COMPARISON_GUIDE.md** for detailed comparison.

---

## 🎨 Features Implemented

### All Patterns Include:

#### 🏠 Home View
- Landing page with navigation
- Architecture information card
- Feature cards for Counter and Notes
- Theme toggle button

#### 🔢 Counter Feature
- Increment counter (+1)
- Decrement counter (-1)
- Reset counter (to 0)
- Persistent storage
- Reactive UI updates

#### 📝 Notes Feature
- Add new notes
- View all notes
- Delete individual notes
- Delete all notes
- Timestamps on each note
- Empty state handling
- Persistent storage

#### 🎨 Theme Support
- Light theme (default)
- Dark theme
- System theme (MVVM, Clean, DDD)
- Theme toggle button in app bar

---

## 🏗️ Project Structure

### MVC Structure
```
mvc_architeture_pattern/
├── lib/
│   ├── models/          # Data models
│   ├── views/           # UI screens
│   ├── controllers/     # Business logic
│   └── main.dart
```

### MVVM Structure
```
mvvm_architeture_pattern/
├── lib/
│   ├── models/          # Data entities
│   ├── views/           # UI screens
│   ├── viewmodels/      # Presentation logic
│   ├── bindings/        # Dependency injection
│   ├── routes/          # Navigation
│   └── main.dart
```

### Clean Architecture Structure
```
clean_architeture_pattern/
├── lib/
│   ├── core/            # Shared resources
│   ├── features/
│   │   ├── counter/
│   │   │   ├── data/           # Data layer
│   │   │   ├── domain/         # Domain layer
│   │   │   └── presentation/   # Presentation layer
│   │   └── notes/
│   └── main.dart
```

### DDD Structure
```
ddd_architeture_pattern/
├── lib/
│   ├── domain/          # Pure business logic
│   ├── application/     # Use cases
│   ├── infrastructure/  # Implementation
│   ├── presentation/    # UI layer
│   └── main.dart
```

---

## 📚 Documentation

### Essential Reads:
1. **STANDARDIZATION_SUMMARY.md** - How patterns were standardized
2. **COMPARISON_GUIDE.md** - Detailed pattern comparison
3. Each pattern's README - Pattern-specific details

### Pattern-Specific Docs:
- **DDD**: `DDD_CONCEPTS.md`, `ARCHITECTURE.md`, `PROJECT_SUMMARY.md`, `QUICK_START.md`
- **Clean/MVVM**: README with architecture diagrams
- **MVC**: README with pattern explanation

---

## 🎯 When to Use Each Pattern

### Use MVC When:
- ✅ Building small apps (< 5 screens)
- ✅ Rapid prototyping
- ✅ Learning Flutter
- ✅ Personal projects

### Use MVVM When:
- ✅ Medium-sized apps (5-15 screens)
- ✅ Complex UI state
- ✅ Reactive programming preferred
- ✅ Two-way data binding needed

### Use Clean Architecture When:
- ✅ Large apps (15+ screens)
- ✅ Multiple developers
- ✅ High testability required
- ✅ Long-term maintenance

### Use DDD When:
- ✅ Enterprise applications
- ✅ Complex business logic
- ✅ Multiple bounded contexts
- ✅ Domain experts involved
- ✅ Evolving requirements

---

## 🧪 Testing

All patterns are designed to be testable:

- **MVC**: Controller testing
- **MVVM**: ViewModel testing
- **Clean**: Layer-by-layer testing
- **DDD**: Pure domain testing + all layers

Run tests:
```bash
flutter test
```

---

## 🛠️ Technology Stack

### All Patterns Use:
- **Flutter**: 3.9.2+
- **Dart**: 3.9.2+
- **GetX**: 4.7.2 (State management, routing, DI)

### Clean & DDD Also Use:
- **GetStorage**: 2.1.1 (Local persistence)
- **Dartz**: 0.10.1 (Functional programming)
- **Equatable**: 2.0.7 (Value equality)
- **UUID**: 4.5.2 (Unique identifiers - DDD only)

---

## ⭐ Show Your Support

If this repository helped you learn Flutter architecture patterns, please give it a ⭐ star!

## 📄 License

This project is for educational purposes. Feel free to use it for learning and reference.

---

**Happy Learning! 🚀 Master Flutter Architecture Patterns!**
