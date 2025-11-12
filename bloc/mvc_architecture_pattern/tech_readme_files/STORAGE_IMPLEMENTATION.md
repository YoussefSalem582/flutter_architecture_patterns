# 💾 HydratedBloc Storage Implementation Guide

## Overview

This guide explains how **HydratedBloc** is implemented in our MVC architecture to provide automatic state persistence that survives app restarts.

## What is HydratedBloc?

**HydratedBloc** is an extension of the standard BLoC library that automatically persists and restores bloc/cubit state. It uses local storage to save state when it changes and restores it when the app starts.

### Key Features

- ✅ **Automatic persistence**: No manual save/load calls
- ✅ **Platform-agnostic**: Works on all Flutter platforms
- ✅ **Type-safe**: Uses JSON serialization
- ✅ **Lightweight**: Minimal performance overhead
- ✅ **Simple API**: Just implement toJson/fromJson
- ✅ **Reliable**: Built on top of Hive (fast key-value storage)

## Setup Steps

### 1. Add Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  hydrated_bloc: ^9.1.2
  path_provider: ^2.1.1
  equatable: ^2.0.5
```

**Why these packages?**
- `flutter_bloc`: Core BLoC library for state management
- `hydrated_bloc`: Adds automatic persistence to BLoC
- `path_provider`: Finds storage directory path
- `equatable`: Makes state comparison easy

### 2. Initialize HydratedBloc in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // IMPORTANT: Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HydratedBloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  runApp(const MyApp());
}
```

**What happens here?**
1. `WidgetsFlutterBinding.ensureInitialized()`: Ensures Flutter is ready
2. `getApplicationDocumentsDirectory()`: Gets platform-specific storage path
3. `HydratedStorage.build()`: Creates storage instance
4. Storage is ready before app starts

### 3. Setup BlocProviders

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Counter Cubit with automatic persistence
        BlocProvider(
          create: (context) => CounterCubit(),
        ),
        
        // Notes Cubit with automatic persistence
        BlocProvider(
          create: (context) => NotesCubit(),
        ),
        
        // Theme Cubit with automatic persistence
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'MVC Pattern with BLoC',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
```

## Implementation Examples

### Example 1: Simple Cubit with Persistence (Counter)

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';

// CounterCubit extends HydratedCubit for automatic persistence
class CounterCubit extends HydratedCubit<int> {
  // Initial state: 0
  CounterCubit() : super(0);

  // Business logic methods
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);

  // PERSISTENCE: Save state to storage
  @override
  int? fromJson(Map<String, dynamic> json) {
    // Restore state from JSON
    return json['value'] as int?;
  }

  // PERSISTENCE: Load state from storage
  @override
  Map<String, dynamic>? toJson(int state) {
    // Save state to JSON
    return {'value': state};
  }
}
```

**How it works:**
1. When `emit()` is called → `toJson()` saves state automatically
2. When app starts → `fromJson()` restores last saved state
3. No manual save/load calls needed!

### Example 2: Complex State with Objects (Notes)

#### Model with JSON Support

```dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;

  const Note({
    required this.id,
    required this.content,
    required this.timestamp,
  });

  // Convert Note to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create Note from JSON Map
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [id, content, timestamp];
}
```

#### Cubit with List Persistence

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/note_model.dart';

class NotesCubit extends HydratedCubit<List<Note>> {
  // Initial state: empty list
  NotesCubit() : super([]);

  void addNote(String content) {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      timestamp: DateTime.now(),
    );
    emit([...state, note]);  // Creates new list with added note
  }

  void deleteNote(String id) {
    emit(state.where((note) => note.id != id).toList());
  }

  void clearAllNotes() {
    emit([]);
  }

  // PERSISTENCE: Convert List<Note> to JSON
  @override
  List<Note>? fromJson(Map<String, dynamic> json) {
    final notesJson = json['notes'] as List<dynamic>?;
    
    if (notesJson == null) return [];
    
    return notesJson
        .map((noteJson) => Note.fromJson(noteJson as Map<String, dynamic>))
        .toList();
  }

  // PERSISTENCE: Convert JSON to List<Note>
  @override
  Map<String, dynamic>? toJson(List<Note> state) {
    return {
      'notes': state.map((note) => note.toJson()).toList(),
    };
  }
}
```

**JSON Storage Format:**
```json
{
  "notes": [
    {
      "id": "1234567890",
      "content": "Buy groceries",
      "timestamp": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": "1234567891",
      "content": "Finish project",
      "timestamp": "2024-01-15T11:45:00.000Z"
    }
  ]
}
```

### Example 3: Enum State Persistence (Theme)

```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void setLightTheme() => emit(ThemeMode.light);
  void setDarkTheme() => emit(ThemeMode.dark);

  // PERSISTENCE: Convert ThemeMode to JSON
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final themeString = json['theme'] as String?;
    
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  // PERSISTENCE: Convert JSON to ThemeMode
  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    String themeString;
    
    switch (state) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    return {'theme': themeString};
  }
}
```

## Storage Patterns Comparison

### MVC Pattern (This Project)
```dart
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
  
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}
```

**Characteristics:**
- ✅ Direct storage in Cubit
- ✅ Simple for basic apps
- ✅ Quick to implement
- ⚠️ Couples business logic with storage

### Clean Architecture / DDD Pattern
```dart
// Repository interface
abstract class CounterRepository {
  Future<int> getCounter();
  Future<void> saveCounter(int value);
}

// HydratedBloc implementation
class CounterRepositoryImpl implements CounterRepository {
  final HydratedStorage storage;
  
  @override
  Future<int> getCounter() async {
    // Use HydratedStorage directly
    final data = await storage.read('counter');
    return data?['value'] ?? 0;
  }
  
  @override
  Future<void> saveCounter(int value) async {
    await storage.write('counter', {'value': value});
  }
}

// Cubit uses repository (no HydratedCubit)
class CounterCubit extends Cubit<int> {
  final CounterRepository repository;
  
  CounterCubit(this.repository) : super(0) {
    _loadCounter();
  }
  
  Future<void> _loadCounter() async {
    emit(await repository.getCounter());
  }
  
  void increment() async {
    final newValue = state + 1;
    emit(newValue);
    await repository.saveCounter(newValue);
  }
}
```

**Characteristics:**
- ✅ Clean separation of concerns
- ✅ Testable (mock repository)
- ✅ Swappable storage implementation
- ⚠️ More boilerplate code

## When to Use HydratedCubit vs Manual Persistence

### Use HydratedCubit When:
- ✅ Building MVC or MVVM apps
- ✅ Want automatic persistence
- ✅ State is simple and JSON-serializable
- ✅ Don't need complex storage logic
- ✅ Prototyping or small apps

### Use Repository Pattern When:
- ✅ Building Clean Architecture or DDD apps
- ✅ Need business logic separation
- ✅ Complex storage requirements
- ✅ Multiple storage backends
- ✅ Need high testability

## Advanced Patterns

### Pattern 1: Migration Strategy

```dart
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);

  @override
  int? fromJson(Map<String, dynamic> json) {
    // Version 2: New storage format
    if (json.containsKey('version') && json['version'] == 2) {
      return json['counterValue'] as int?;
    }
    
    // Version 1: Old storage format (migration)
    if (json.containsKey('value')) {
      final oldValue = json['value'] as int?;
      // Migrate to new format on next save
      return oldValue;
    }
    
    return null;
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    // Always save in latest format
    return {
      'version': 2,
      'counterValue': state,
    };
  }
}
```

### Pattern 2: Selective Persistence

```dart
class AppSettingsCubit extends HydratedCubit<AppSettings> {
  AppSettingsCubit() : super(AppSettings.defaults());

  @override
  Map<String, dynamic>? toJson(AppSettings state) {
    // Only persist certain fields
    return {
      'theme': state.theme,
      'language': state.language,
      // Don't persist temporary session data
      // 'sessionId': state.sessionId,
    };
  }

  @override
  AppSettings? fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] as String,
      language: json['language'] as String,
      sessionId: null, // Will be set elsewhere
    );
  }
}
```

### Pattern 3: Error Handling

```dart
class NotesCubit extends HydratedCubit<List<Note>> {
  NotesCubit() : super([]);

  @override
  List<Note>? fromJson(Map<String, dynamic> json) {
    try {
      final notesJson = json['notes'] as List<dynamic>?;
      if (notesJson == null) return [];
      
      return notesJson
          .map((noteJson) {
            try {
              return Note.fromJson(noteJson as Map<String, dynamic>);
            } catch (e) {
              // Skip corrupted notes
              print('Error deserializing note: $e');
              return null;
            }
          })
          .whereType<Note>() // Filter out nulls
          .toList();
    } catch (e) {
      print('Error loading notes: $e');
      return []; // Return empty list on error
    }
  }

  @override
  Map<String, dynamic>? toJson(List<Note> state) {
    try {
      return {
        'notes': state.map((note) => note.toJson()).toList(),
      };
    } catch (e) {
      print('Error saving notes: $e');
      return null; // Don't save if error
    }
  }
}
```

## Storage Location

HydratedBloc stores data in platform-specific locations:

| Platform | Default Location |
|----------|------------------|
| Android | `/data/data/<package>/app_flutter/` |
| iOS | `~/Library/Application Support/` |
| macOS | `~/Library/Containers/<app>/Data/Library/Application Support/` |
| Windows | `%APPDATA%/<app>/` |
| Linux | `~/.local/share/<app>/` |
| Web | `localStorage` |

## Testing HydratedCubit

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    
    // Setup mock storage
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
    
    HydratedBloc.storage = storage;
  });

  group('CounterCubit', () {
    test('initial state is 0', () {
      expect(CounterCubit().state, 0);
    });

    test('increment increases state', () {
      final cubit = CounterCubit();
      cubit.increment();
      expect(cubit.state, 1);
    });

    test('toJson/fromJson works correctly', () {
      final cubit = CounterCubit();
      
      // Test serialization
      expect(cubit.toJson(5), {'value': 5});
      
      // Test deserialization
      expect(cubit.fromJson({'value': 10}), 10);
    });
  });
}
```

## Best Practices

### ✅ DO:
- Keep JSON serialization simple
- Handle null cases in `fromJson`
- Use Equatable for state comparison
- Test toJson/fromJson methods
- Implement error handling
- Use meaningful storage keys
- Consider migration strategies

### ❌ DON'T:
- Store sensitive data unencrypted
- Store very large objects (use database instead)
- Make toJson/fromJson async
- Store UI state (only business state)
- Forget to initialize HydratedBloc.storage
- Skip null checks in fromJson

## Debugging Tips

### Enable HydratedBloc Logging

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable bloc logging
  Bloc.observer = SimpleBlocObserver();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  runApp(const MyApp());
}
```

### Clear Storage (For Testing)

```dart
// Clear all HydratedBloc storage
await HydratedBloc.storage.clear();

// Clear specific cubit storage
await HydratedBloc.storage.delete('CounterCubit');
```

## Performance Considerations

1. **Storage Size**: HydratedBloc uses Hive (very fast)
   - ✅ Good for: Settings, user preferences, small lists
   - ❌ Bad for: Large datasets, images, files

2. **Write Performance**: Writes are async but don't block UI
   - Each `emit()` triggers a write
   - Use throttling for frequently changing state

3. **Read Performance**: Restore is synchronous
   - Happens during Cubit initialization
   - Keep fromJson logic simple

## Summary

| Feature | HydratedCubit | Manual Storage | Repository Pattern |
|---------|---------------|----------------|-------------------|
| Automatic persistence | ✅ | ❌ | ❌ |
| Boilerplate | Low | Medium | High |
| Testability | Good | Good | Excellent |
| Separation of concerns | Medium | Medium | High |
| Flexibility | Medium | High | High |
| Best for | MVC/MVVM | Simple apps | Clean Arch/DDD |

---

**HydratedBloc makes persistence simple in MVC architecture! 🚀**

For more complex architectures (Clean/DDD), consider using the Repository pattern instead.
