# 🔧 Troubleshooting Guide

Common issues and solutions for Flutter Architecture Patterns projects.

## 📋 Table of Contents
- [Installation Issues](#installation-issues)
- [Build Errors](#build-errors)
- [Runtime Errors](#runtime-errors)
- [Platform-Specific Issues](#platform-specific-issues)
- [State Management Issues](#state-management-issues)
- [Navigation Issues](#navigation-issues)
- [Storage Issues](#storage-issues)
- [Performance Issues](#performance-issues)
- [BLoC Specific Issues](#bloc-specific-issues)

---

## 🔨 Installation Issues

### Issue: Flutter command not found

**Error:**
```
'flutter' is not recognized as an internal or external command
```

**Solution:**

**Windows:**
```powershell
# Add Flutter to PATH
$env:Path += ";C:\src\flutter\bin"

# Make it permanent
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path,
    [EnvironmentVariableTarget]::User
)

# Verify
flutter --version
```

**macOS/Linux:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"

# Reload shell
source ~/.bashrc

# Verify
flutter --version
```

---

### Issue: Pub get failed - Network error

**Error:**
```
Failed to retrieve package dependencies from pub.dev
```

**Solution:**

```bash
# Clear Flutter cache
flutter pub cache clean

# Clear pub cache
rm -rf ~/.pub-cache

# Try again
flutter pub get

# If behind proxy
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
flutter pub get
```

---

### Issue: Flutter doctor shows errors

**Error:**
```
[!] Android toolchain - develop for Android devices
    ✗ Android SDK not found
```

**Solution:**

```bash
# Run doctor with detailed info
flutter doctor -v

# For Android toolchain issues:
# 1. Install Android Studio
# 2. Open SDK Manager and install Android SDK
# 3. Accept licenses
flutter doctor --android-licenses

# For iOS (macOS only):
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

---

## 🏗️ Build Errors

### Issue: Gradle build failed (Android)

**Error:**
```
FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:checkDebugAarMetadata'.
```

**Solution:**

```bash
# Clean project
flutter clean

# Delete gradle cache
rm -rf ~/.gradle/caches

# Invalidate caches (if using Android Studio)
# File → Invalidate Caches / Restart

# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 7.5

# Try build again
cd ..
flutter pub get
flutter build apk
```

---

### Issue: CocoaPods error (iOS/macOS)

**Error:**
```
Error running pod install
```

**Solution:**

```bash
# Navigate to iOS/macOS directory
cd ios  # or cd macos

# Remove old pods
rm -rf Pods
rm Podfile.lock

# Update CocoaPods
sudo gem install cocoapods

# Repo update
pod repo update

# Install pods
pod install --repo-update

# Back to project root
cd ..

# Try build again
flutter build ios
```

---

### Issue: Windows build failed

**Error:**
```
CMake Error: Could not find CMAKE_MODULE_PATH
```

**Solution:**

```powershell
# Install Visual Studio with C++ tools
# Download from: https://visualstudio.microsoft.com/downloads/

# Ensure Windows SDK is installed

# Clean and rebuild
flutter clean
flutter pub get
flutter build windows
```

---

### Issue: Web build failed

**Error:**
```
Target web_entrypoint failed
```

**Solution:**

```bash
# Enable web support
flutter config --enable-web

# Clean
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web

# Or run in debug mode
flutter run -d chrome
```

---

## 🐛 Runtime Errors

### Issue: "BLoC/Cubit not found in context"

**Error:**
```
BlocProvider.of() called with a context that does not contain a CounterCubit
```

**Solution:**

**Option 1: Add BlocProvider above the widget**
```dart
// Wrap your widget tree with BlocProvider
BlocProvider(
  create: (context) => CounterCubit(),
  child: CounterView(),
)
```

**Option 2: Use MultiBlocProvider for multiple BLoCs**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => CounterCubit()),
    BlocProvider(create: (context) => ThemeCubit()),
  ],
  child: MyApp(),
)
```

**Option 3: Access from parent provider**
```dart
// If provider is higher up in tree
final cubit = context.read<CounterCubit>();
```

---

### Issue: State not updating

**Error:**
UI doesn't reflect state changes

**Solution:**

**For BLoC/Cubit:**
```dart
// ✅ Correct - Emit new state
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() {
    emit(state + 1); // Emit new state
  }
}

// In widget - Use BlocBuilder
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)
```

**For State Classes:**
```dart
// ✅ Correct - Create new instance with copyWith
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState.initial());
  
  void increment() {
    emit(state.copyWith(value: state.value + 1)); // New instance
  }
}

// In widget
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.value}'),
)
```

❌ **DON'T**: Mutate state directly
```dart
// Bad - Don't mutate state
void increment() {
  state.value++; // This won't trigger rebuild!
}
```

---

### Issue: "A RenderFlex overflowed"

**Error:**
```
A RenderFlex overflowed by 123 pixels on the bottom.
```

**Solution:**

```dart
// ✅ Wrap in SingleChildScrollView
Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [
        // Your widgets
      ],
    ),
  ),
)

// Or use ListView instead of Column
Scaffold(
  body: ListView(
    children: [
      // Your widgets
    ],
  ),
)
```

---

### Issue: Null check operator used on null value

**Error:**
```
Null check operator used on a null value
```

**Solution:**

```dart
// ❌ Bad
String name = getName()!; // Dangerous
print(name.length);

// ✅ Good - Null check
String? name = getName();
if (name != null) {
  print(name.length);
}

// ✅ Good - Null-aware operator
String? name = getName();
print(name?.length ?? 0);

// ✅ Good - Default value
String name = getName() ?? 'Default';
print(name.length);
```

---

## 💻 Platform-Specific Issues

### Windows Issues

**Issue: Antivirus blocking Flutter**

**Solution:**
```powershell
# Add Flutter to Windows Defender exclusions
# 1. Open Windows Security
# 2. Virus & threat protection → Manage settings
# 3. Exclusions → Add or remove exclusions
# 4. Add folder: C:\src\flutter
```

**Issue: PowerShell execution policy**

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for current session
Set-ExecutionPolicy Bypass -Scope Process
```

---

### macOS Issues

**Issue: Gatekeeper blocking Flutter**

**Solution:**
```bash
# Allow Flutter
xattr -d com.apple.quarantine /path/to/flutter/bin/flutter

# Allow all in Flutter directory
sudo xattr -r -d com.apple.quarantine /path/to/flutter
```

**Issue: Xcode license not accepted**

**Solution:**
```bash
sudo xcodebuild -license accept
```

---

### Linux Issues

**Issue: Missing dependencies**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa

# Fedora
sudo dnf install curl git unzip xz zip

# Arch
sudo pacman -S curl git unzip xz zip
```

---

## 🎮 State Management Issues

### Issue: BLoC/Cubit disposed too early

**Error:**
```
Bad state: Cannot emit new states after calling close
```

**Solution:**

```dart
// ✅ Don't close bloc manually if using BlocProvider
// BlocProvider automatically disposes the bloc

// ✅ Keep bloc alive across routes
BlocProvider.value(
  value: existingCubit, // Reuse existing instance
  child: NextScreen(),
)

// ✅ For persistent blocs across app
// Create at app level
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => ThemeCubit()), // Lives for entire app
  ],
  child: MaterialApp(),
)
```

---

### Issue: Memory leaks

**Problem:** BLoC/Cubit not being disposed

**Solution:**

```dart
class MyCubit extends Cubit<MyState> {
  late StreamSubscription _subscription;
  late Timer _timer;

  MyCubit() : super(MyInitial()) {
    _subscription = stream.listen((_) {});
    _timer = Timer.periodic(Duration(seconds: 1), (_) {});
  }

  @override
  Future<void> close() {
    // ✅ Always clean up resources
    _subscription.cancel();
    _timer.cancel();
    return super.close();
  }
}

// BlocProvider automatically calls close() when widget is disposed
```

---

### Issue: Circular dependency

**Error:**
```
Circular dependency detected
```

**Solution:**

```dart
// ❌ Bad - Circular dependency
class ACubit extends Cubit<AState> {
  final BCubit b; // Needs B
  ACubit(this.b) : super(AInitial());
}

class BCubit extends Cubit<BState> {
  final ACubit a; // Needs A - CIRCULAR!
  BCubit(this.a) : super(BInitial());
}

// ✅ Good - Break the cycle with repositories/use cases
class ACubit extends Cubit<AState> {
  final MyRepository repository; // Use shared repository
  ACubit(this.repository) : super(AInitial());
}

class BCubit extends Cubit<BState> {
  final MyRepository repository; // Same repository
  BCubit(this.repository) : super(BInitial());
}
```

---

## 🧭 Navigation Issues

### Issue: "Route not found"

**Error:**
```
No route defined for /counter
```

**Solution:**

```dart
// ✅ Define routes in MaterialApp
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomeView(),
    '/counter': (context) => BlocProvider(
      create: (context) => CounterCubit(),
      child: CounterView(),
    ),
    '/notes': (context) => BlocProvider(
      create: (context) => NotesCubit(),
      child: NotesView(),
    ),
  },
)

// Navigate using defined routes
Navigator.pushNamed(context, '/counter');
```

---

### Issue: Back button not working

**Solution:**

```dart
// ✅ Use Navigator.pop()
ElevatedButton(
  onPressed: () => Navigator.pop(context),
  child: Text('Back'),
)

// Or use WillPopScope for custom behavior
WillPopScope(
  onWillPop() async {
    // Custom back button logic
    return true; // Allow pop
  },
  child: Scaffold(/* ... */),
)
```

---

### Issue: Arguments not received

**Problem:** Passing data between screens

**Solution:**

```dart
// ✅ Send arguments via Navigator
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'id': 123, 'name': 'Test'},
);

// Receive arguments in destination widget
class DetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final id = args['id'];
    final name = args['name'];
    return Scaffold(/* Use id and name */);
  }
}

// Or pass via constructor with named routes
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/details':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => DetailsView(
          id: args['id'],
          name: args['name'],
        ),
      );
    default:
      return MaterialPageRoute(builder: (_) => HomeView());
  }
}
```

---

## 💾 Storage Issues

### Issue: Hydrated BLoC not initialized

**Error:**
```
HydratedBloc.storage has not been initialized
```

**Solution:**

```dart
// ✅ Initialize before runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  runApp(MyApp());
}
```

---

### Issue: Data not persisting

**Problem:** Data lost after app restart

**Solution:**

```dart
// ✅ Use HydratedCubit for automatic persistence
class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}

// Or use SharedPreferences manually
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('counter') ?? 0;
    emit(saved);
  }

  void increment() async {
    emit(state + 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', state);
  }
}
```

---

### Issue: Storage corrupted

**Error:**
```
FormatException: Invalid JSON
```

**Solution:**

```bash
# Clear app data
flutter clean

# On Android device
adb shell pm clear com.example.your_app

# On iOS simulator
# Device → Erase All Content and Settings

# Reinstall app
flutter run
```

**Prevent corruption:**
```dart
// ✅ Use try-catch when reading from storage
T? readSafe<T>(SharedPreferences prefs, String key) {
  try {
    return prefs.get(key) as T?;
  } catch (e) {
    print('Storage read error: $e');
    prefs.remove(key); // Remove corrupted data
    return null;
  }
}
```

---

## ⚡ Performance Issues

### Issue: Slow app startup

**Problem:** App takes long to start

**Solution:**

```dart
// ✅ Use lazy initialization
MaterialApp(
  home: BlocProvider(
    create: (context) => HomeCubit(), // Created only when needed
    child: HomeView(),
  ),
)

// Avoid putting too much in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only essential initialization
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  runApp(MyApp()); // Don't do heavy work here
}
```

---

### Issue: UI freezing/janky

**Problem:** App feels sluggish

**Solution:**

```dart
// ✅ Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ Use const constructors
const SizedBox(height: 16)
const Padding(padding: EdgeInsets.all(24))

// ✅ Avoid expensive operations in build
class MyWidget extends StatelessWidget {
  final String data;
  
  // ✅ Compute outside build
  late final processed = _process(data);
  
  String _process(String input) {
    // Expensive operation done once
    return input.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Text(processed); // Use pre-computed value
  }
}

// ✅ Use isolates for heavy computation
Future<String> heavyWork(String data) async {
  return await compute(_processData, data);
}

String _processData(String data) {
  // Heavy CPU work
  return data;
}
```

---

### Issue: High memory usage

**Problem:** App consuming too much memory

**Solution:**

```dart
// ✅ Dispose cubits properly
@override
Future<void> close() {
  // Clear large lists
  myLargeList.clear();
  
  // Cancel subscriptions
  subscription.cancel();
  
  // Clear cached data
  cache.clear();
  
  return super.close();
}

// BlocProvider automatically disposes cubits
// No need to manually dispose if using BlocProvider

// ✅ Avoid keeping large objects in memory
// Load data on demand instead of keeping everything
```

---

## 🔍 BLoC Specific Issues

### Issue: Listeners not triggering

**Problem:** BlocListener not responding to state changes

**Solution:**

```dart
class MyCubit extends Cubit<MyState> {
  MyCubit() : super(MyInitial());

  void doSomething() {
    // ✅ Must emit a NEW state instance
    emit(MySuccess()); // This triggers listeners
  }
}

// Use listenWhen to control when listener is called
BlocListener<MyCubit, MyState>(
  listenWhen: (previous, current) {
    // Only listen when state actually changes
    return previous != current;
  },
  listener: (context, state) {
    if (state is MySuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success!')),
      );
    }
  },
  child: MyWidget(),
)
```

---

### Issue: BlocBuilder not updating

**Problem:** UI not rebuilding

**Solution:**

```dart
// ✅ Ensure Equatable is implemented correctly
class CounterState extends Equatable {
  final int value;

  const CounterState(this.value);

  @override
  List<Object> get props => [value]; // Include all properties
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));

  void increment() {
    // ✅ Emit new state instance
    emit(CounterState(state.value + 1));
  }
}

// Use buildWhen to optimize rebuilds
BlocBuilder<CounterCubit, CounterState>(
  buildWhen: (previous, current) {
    // Only rebuild when value actually changes
    return previous.value != current.value;
  },
  builder: (context, state) => Text('${state.value}'),
)
```

---

### Issue: StreamSubscription errors

**Problem:** Stream already listened to

**Solution:**

```dart
// ✅ Use broadcast streams
class MyBloc extends Bloc<MyEvent, MyState> {
  late final Stream<int> dataStream;

  MyBloc() : super(MyInitial()) {
    // Create broadcast stream
    dataStream = Stream.periodic(
      Duration(seconds: 1),
      (count) => count,
    ).asBroadcastStream(); // Make it broadcast

    on<LoadData>(_onLoadData);
  }

  Future<void> _onLoadData(
    LoadData event,
    Emitter<MyState> emit,
  ) async {
    await emit.forEach(
      dataStream,
      onData: (data) => MyLoaded(data),
    );
  }
}
```

---

### Issue: Concurrent modification error

**Problem:** Modifying state while emitting

**Solution:**

```dart
// ❌ Bad - Modifying list directly
class NotesCubit extends Cubit<List<Note>> {
  NotesCubit() : super([]);

  void addNote(Note note) {
    state.add(note); // DON'T mutate state!
    emit(state); // This won't work correctly
  }
}

// ✅ Good - Create new list
class NotesCubit extends Cubit<List<Note>> {
  NotesCubit() : super([]);

  void addNote(Note note) {
    // Create new list with added note
    emit(List.from(state)..add(note));
  }
}

// ✅ Better - Use copyWith pattern with state class
class NotesState extends Equatable {
  final List<Note> notes;

  const NotesState({required this.notes});

  NotesState copyWith({List<Note>? notes}) {
    return NotesState(notes: notes ?? this.notes);
  }

  @override
  List<Object> get props => [notes];
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesState(notes: []));

  void addNote(Note note) {
    final updatedNotes = List<Note>.from(state.notes)..add(note);
    emit(state.copyWith(notes: updatedNotes));
  }
}
```

---

## 📞 Getting Help

### Still Having Issues?

1. **Check the error message** carefully - it usually tells you what's wrong
2. **Search GitHub Issues** - someone likely had the same problem
3. **Check Flutter/GetX documentation**
4. **Ask on Stack Overflow** with the `flutter` and `getx` tags
5. **Open an issue** on this repository with:
   - Flutter/Dart version (`flutter --version`)
   - Platform (Windows/macOS/Linux/Android/iOS/Web)
   - Complete error message
   - Steps to reproduce
   - Code sample (if possible)

### Useful Commands

```bash
# Get version info
flutter --version
flutter doctor -v

# Clear everything and start fresh
flutter clean
flutter pub get

# Check for issues
flutter analyze

# Run with verbose logging
flutter run -v

# View logs (Android)
adb logcat

# View logs (iOS)
# Xcode → Window → Devices and Simulators → View Device Logs
```

### Contact

- 📧 Email: youssef.salem.hassan582@gmail.com
- 🐙 GitHub: [@YoussefSalem582](https://github.com/YoussefSalem582)
- 💬 Issues: [GitHub Issues](https://github.com/YoussefSalem582/flutter_architecture_patterns/issues)

---

**Don't give up! Every error is a learning opportunity. 🚀**
