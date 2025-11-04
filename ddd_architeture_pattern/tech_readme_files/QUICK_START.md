# Quick Start Guide - Counter Notes App (DDD)

## 🚀 Get Started in 5 Minutes

This guide will help you quickly set up and explore the DDD Counter Notes App.

---

## 📋 Prerequisites

- **Flutter SDK**: Version 3.9.2 or higher
- **Dart SDK**: Version 3.9.2 or higher
- **VS Code** or **Android Studio** (recommended)
- **Chrome** browser (for web testing)

### Check Your Installation

```powershell
flutter --version
dart --version
```

---

## 🛠️ Installation

### Step 1: Navigate to Project

```powershell
cd d:\projects\flutter_projects\flutter_architecture_patterns\ddd_architeture_pattern
```

### Step 2: Get Dependencies

```powershell
flutter pub get
```

Expected output:
```
Running "flutter pub get" in ddd_architeture_pattern...
Resolving dependencies...
Got dependencies!
```

### Step 3: Verify Installation

```powershell
flutter doctor
```

Ensure:
- ✅ Flutter SDK installed
- ✅ Chrome browser detected (for web)
- ✅ Android/iOS setup (optional)

---

## ▶️ Running the App

### Option 1: Run on Chrome (Fastest)

```powershell
flutter run -d chrome
```

### Option 2: Run on Android Emulator

```powershell
# Start emulator first
flutter emulators --launch <emulator_id>

# Then run app
flutter run
```

### Option 3: Run on Physical Device

```powershell
# Connect device via USB
# Enable USB debugging on Android

# Check device connected
flutter devices

# Run app
flutter run
```

### Expected Launch Output

```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...     ✓
Debug service listening on ws://127.0.0.1:xxxxx/xxxxx=/ws

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
q Quit (terminate the application).

The Flutter DevTools debugger and profiler on Chrome is available at: http://...
```

---

## 🧭 App Navigation

### Home Screen
1. App launches to **Home View**
2. Displays DDD architecture overview
3. Shows two features:
   - **Counter**: Increment/Decrement counter
   - **Notes**: Create and manage notes

### Counter Feature
1. Click **"Go to Counter"** button
2. See current counter value (starts at 0)
3. Three buttons:
   - **+ (Increment)**: Increase counter
   - **- (Decrement)**: Decrease counter (stops at 0)
   - **Reset**: Reset to 0

### Notes Feature
1. Click **"Go to Notes"** button
2. See list of all notes
3. Click **+ FAB** (Floating Action Button)
4. Enter note content (max 500 chars)
5. Click **"Add"**
6. Note appears with timestamp
7. Click **trash icon** to delete individual note
8. Click **"Delete All"** to clear all notes

---

## 🧪 Testing Features

### Test 1: Counter Cannot Go Below Zero (Business Rule)
1. Go to Counter screen
2. Click **-** (decrement) button
3. **Expected**: Counter stays at 0
4. **DDD Concept**: Business rule enforced in `CounterValue` value object

### Test 2: Note Content Validation (Business Rule)
1. Go to Notes screen
2. Click **+** FAB
3. Leave content empty
4. Try to click **"Add"**
5. **Expected**: Validation error
6. **DDD Concept**: Validation in `NoteContent` value object

### Test 3: Data Persistence
1. Add some notes and increment counter
2. Close browser tab
3. Reopen app
4. **Expected**: Counter value and notes persist
5. **DDD Concept**: Infrastructure layer handles persistence

### Test 4: Timestamp Formatting (Domain Logic)
1. Add a new note
2. Observe timestamp: "Just now"
3. Wait 2 minutes
4. Refresh list
5. **Expected**: Timestamp updates to "2 minutes ago"
6. **DDD Concept**: Domain logic in `NoteTimestamp` value object

---

## 🔍 Exploring the Code

### Start with Domain Layer (Pure Business Logic)

#### 1. Counter Value Object
**File**: `lib/domain/counter/value_objects/counter_value.dart`

```dart
// Business rule: Counter cannot be negative
factory CounterValue(int value) {
  if (value < 0) {
    throw ArgumentError('Counter value cannot be negative');
  }
  return CounterValue._(value);
}

// Business rule: Decrement stops at zero
CounterValue decrement() {
  if (number == 0) {
    return this;  // ← Business rule!
  }
  return CounterValue._(number - 1);
}
```

**Try**: Comment out the `if (number == 0) return this;` line and see what happens!

#### 2. Counter Entity
**File**: `lib/domain/counter/entities/counter_entity.dart`

```dart
// Entity with identity and business methods
class CounterEntity extends Equatable {
  final String id;              // Identity
  final CounterValue value;     // State

  CounterEntity increment() {   // Business method
    return CounterEntity(
      id: id,
      value: value.increment(),
    );
  }
}
```

#### 3. Note Content Validation
**File**: `lib/domain/notes/value_objects/note_content.dart`

```dart
factory NoteContent(String content) {
  // Business rule: Cannot be empty
  if (content.isEmpty) {
    throw ArgumentError('Note content cannot be empty');
  }
  
  // Business rule: Max 500 characters
  if (content.length > 500) {
    throw ArgumentError('Note content cannot exceed 500 characters');
  }
  
  return NoteContent._(content.trim());
}
```

**Try**: Change max length to 100 and see validation in action!

### Trace Data Flow

#### Increment Counter Flow

1. **UI** (`lib/presentation/counter/views/counter_view.dart`):
   ```dart
   FloatingActionButton(
     onPressed: controller.increment,  // ← Start here
   )
   ```

2. **Controller** (`lib/presentation/counter/controllers/counter_controller.dart`):
   ```dart
   Future<void> increment() async {
     final result = await incrementCounterUseCase.execute();  // ← Calls use case
     // Handle result...
   }
   ```

3. **Use Case** (`lib/application/counter/usecases/increment_counter_usecase.dart`):
   ```dart
   Future<Either<Failure, CounterEntity>> execute() async {
     final current = await repository.getCounter();
     return current.fold(
       (failure) => Left(failure),
       (counter) async {
         final updated = counter.increment();  // ← Domain logic!
         await repository.saveCounter(updated);
         return Right(updated);
       },
     );
   }
   ```

4. **Entity** (`lib/domain/counter/entities/counter_entity.dart`):
   ```dart
   CounterEntity increment() {
     return CounterEntity(
       id: id,
       value: value.increment(),  // ← Business rule in value object
     );
   }
   ```

5. **Repository** (`lib/infrastructure/counter/repositories/counter_repository_impl.dart`):
   ```dart
   Future<Either<Failure, Unit>> saveCounter(CounterEntity counter) async {
     final dto = CounterDto.fromEntity(counter);  // ← Convert to DTO
     await dataSource.saveCounter(dto);
     return const Right(unit);
   }
   ```

---

## 📚 Learning Path

### Beginner (Day 1-2)
1. ✅ Run the app and test both features
2. ✅ Read `README.md` - overview of DDD
3. ✅ Explore `domain/` folder - entities and value objects
4. ✅ Trace one complete data flow (increment counter)

### Intermediate (Day 3-5)
1. ✅ Read `DDD_CONCEPTS.md` - deep dive into patterns
2. ✅ Study `application/` layer - use cases
3. ✅ Study `infrastructure/` layer - DTOs and persistence
4. ✅ Modify a business rule (e.g., max counter value)
5. ✅ Add a new use case (e.g., UpdateNote)

### Advanced (Day 6-7)
1. ✅ Read `ARCHITECTURE.md` - complete architecture diagrams
2. ✅ Implement a new feature (e.g., Categories)
3. ✅ Write unit tests for domain layer
4. ✅ Swap GetStorage with another persistence layer
5. ✅ Add API integration for notes

---

## 🎯 Key Files to Study

### Must Read (In Order)

1. **main.dart** - Entry point
2. **domain/core/failures.dart** - Error types
3. **domain/counter/value_objects/counter_value.dart** - Business rules
4. **domain/counter/entities/counter_entity.dart** - Entity with behavior
5. **application/counter/usecases/increment_counter_usecase.dart** - Use case pattern
6. **infrastructure/counter/repositories/counter_repository_impl.dart** - Repository implementation
7. **presentation/counter/controllers/counter_controller.dart** - State management
8. **presentation/counter/bindings/counter_binding.dart** - Dependency injection

### Architecture Flow

```
main.dart
   └─> AppPages (routing)
       └─> CounterBinding (DI setup)
           └─> CounterController (state)
               └─> UseCases (orchestration)
                   └─> Repository Interface (domain)
                       └─> Repository Impl (infrastructure)
                           └─> DataSource (GetStorage)
```

---

## 🛠️ Common Commands

### Development

```powershell
# Hot reload (in running app terminal)
r

# Hot restart (in running app terminal)
R

# Stop app (in running app terminal)
q

# Run with device selection
flutter run -d <device_id>

# List available devices
flutter devices

# Check for errors
flutter analyze

# Format code
flutter format lib/
```

### Building

```powershell
# Build APK (Android)
flutter build apk

# Build app bundle (Android)
flutter build appbundle

# Build for web
flutter build web

# Build for Windows
flutter build windows
```

### Cleaning

```powershell
# Clean build files
flutter clean

# Get dependencies again
flutter pub get
```

---

## 🐛 Troubleshooting

### Issue: App Won't Launch

**Solution**:
```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

### Issue: Dependencies Not Found

**Solution**:
```powershell
# Check pubspec.yaml
flutter pub get
flutter pub upgrade
```

### Issue: Chrome Not Detected

**Solution**:
```powershell
# Check Flutter web support
flutter config --enable-web
flutter devices
```

### Issue: GetStorage Error

**Solution**:
```powershell
# Clear app data
# In browser: F12 → Application → Storage → Clear site data
# Then restart app
```

---

## 📖 Documentation Files

| File | Purpose | Lines |
|------|---------|-------|
| `README.md` | Complete DDD guide | 900+ |
| `DDD_CONCEPTS.md` | Deep dive into DDD patterns | 650+ |
| `ARCHITECTURE.md` | Architecture diagrams & flows | 800+ |
| `PROJECT_SUMMARY.md` | Implementation summary | 600+ |
| `QUICK_START.md` | This file | 400+ |

**Total**: ~3,400 lines of documentation!

---

## 🎓 Concepts Demonstrated

| Concept | File Location | Description |
|---------|--------------|-------------|
| **Entity** | `domain/counter/entities/counter_entity.dart` | Object with identity |
| **Value Object** | `domain/counter/value_objects/counter_value.dart` | Validation rules |
| **Aggregate** | `domain/notes/entities/note_entity.dart` | Cluster of objects |
| **Repository** | `domain/counter/repositories/counter_repository.dart` | Interface |
| **Use Case** | `application/counter/usecases/increment_counter_usecase.dart` | Workflow |
| **DTO** | `infrastructure/counter/dtos/counter_dto.dart` | Data transfer |
| **Controller** | `presentation/counter/controllers/counter_controller.dart` | State |
| **Binding** | `presentation/counter/bindings/counter_binding.dart` | DI |

---

## 🎯 Learning Challenges

### Challenge 1: Add Max Counter Value
**Task**: Counter should not exceed 100  
**File**: `lib/domain/counter/value_objects/counter_value.dart`  
**Hint**: Add validation in `increment()` method

### Challenge 2: Add Note Priority
**Task**: Add priority field (Low, Medium, High) to notes  
**Steps**:
1. Create `NotePriority` value object
2. Add to `NoteEntity`
3. Update DTO, repository, use cases
4. Update UI to show priority

### Challenge 3: Add Search Feature
**Task**: Search notes by content  
**Steps**:
1. Create `SearchNotesUseCase`
2. Add search method to repository
3. Update controller with search state
4. Add search TextField to UI

### Challenge 4: Swap Persistence
**Task**: Replace GetStorage with SharedPreferences  
**File**: `lib/infrastructure/counter/datasources/counter_local_datasource.dart`  
**Hint**: Only change infrastructure layer!

---

## 🚀 Next Steps

1. ✅ **Run the app** and test all features
2. ✅ **Read README.md** for overview
3. ✅ **Trace data flow** for increment counter
4. ✅ **Modify a business rule** (e.g., max counter value)
5. ✅ **Add a new feature** (e.g., note categories)
6. ✅ **Write tests** for domain layer
7. ✅ **Study ARCHITECTURE.md** for complete diagrams

---

## 💡 Tips

1. **Start with Domain**: Always explore domain layer first
2. **Trace Data Flows**: Follow complete request/response cycles
3. **Read Documentation**: 3,400+ lines of comprehensive guides
4. **Modify Code**: Change business rules and see effects
5. **Ask Questions**: Use documentation as reference

---

## 📞 Help

### Documentation
- `README.md` - Complete overview
- `DDD_CONCEPTS.md` - Pattern deep dive
- `ARCHITECTURE.md` - Diagrams and flows
- `PROJECT_SUMMARY.md` - Implementation details

### Key Concepts
- **Pure Domain**: No Flutter dependencies
- **Value Objects**: Validation and rules
- **Use Cases**: Workflow orchestration
- **Either Pattern**: Type-safe errors
- **Immutability**: No mutations

---

## 🎉 You're Ready!

You now have:
- ✅ Complete DDD architecture
- ✅ Working Counter & Notes features
- ✅ 40+ well-structured files
- ✅ 3,400+ lines of documentation
- ✅ Production-ready patterns

**Start exploring and happy learning! 🚀**

---

**Pro Tip**: Open VS Code, use Ctrl+P to quickly navigate files, and Ctrl+Shift+F to search across the codebase!
