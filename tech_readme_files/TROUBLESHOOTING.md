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
- [GetX Specific Issues](#getx-specific-issues)

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

### Issue: "GetX Instance not found"

**Error:**
```
[Get] Instance "CounterController" is not found.
You need to call "Get.put(CounterController())" or "Get.lazyPut(()=>CounterController())"
```

**Solution:**

**Option 1: Use Bindings (Recommended)**
```dart
// Create binding
class CounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounterController>(() => CounterController());
  }
}

// Add to route
GetPage(
  name: '/counter',
  page: () => CounterView(),
  binding: CounterBinding(), // Add this
)
```

**Option 2: Manual initialization**
```dart
// In main.dart or before navigation
Get.put(CounterController());

// Or lazy initialization
Get.lazyPut(() => CounterController());
```

**Option 3: Use Get.find with fallback**
```dart
// In widget
final controller = Get.find<CounterController>(
  // Create if not found
  orElse: () => CounterController(),
);
```

---

### Issue: State not updating

**Error:**
UI doesn't reflect state changes

**Solution:**

**For Reactive State (Obx/GetX):**
```dart
// ✅ Correct - Use .obs
class MyController extends GetxController {
  final count = 0.obs; // Observable
  
  void increment() {
    count.value++; // Update .value
  }
}

// In widget - Use Obx
Obx(() => Text('${controller.count.value}'))
```

**For Simple State (GetBuilder):**
```dart
// ✅ Correct - Call update()
class MyController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update(); // Must call update()
  }
}

// In widget - Use GetBuilder
GetBuilder<MyController>(
  builder: (controller) => Text('${controller.count}'),
)
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

### Issue: Controller disposed too early

**Error:**
```
This widget has been unmounted, so the State no longer has a context
```

**Solution:**

```dart
// ✅ Use autoRemove: false for persistent controllers
Get.put(MyController(), permanent: true);

// Or in binding
Get.lazyPut(() => MyController(), fenix: true);
```

---

### Issue: Memory leaks

**Problem:** Controllers not being disposed

**Solution:**

```dart
class MyController extends GetxController {
  late StreamSubscription _subscription;
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _subscription = stream.listen((_) {});
    _timer = Timer.periodic(Duration(seconds: 1), (_) {});
  }

  @override
  void onClose() {
    // ✅ Always clean up resources
    _subscription.cancel();
    _timer.cancel();
    super.onClose();
  }
}
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
class AController extends GetxController {
  final b = Get.find<BController>();
}

class BController extends GetxController {
  final a = Get.find<AController>();
}

// ✅ Good - Break the cycle
class AController extends GetxController {
  late BController b;
  
  @override
  void onReady() {
    super.onReady();
    b = Get.find<BController>();
  }
}

class BController extends GetxController {
  // No reference to A
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
// ✅ Define routes in GetMaterialApp
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(name: '/', page: () => HomeView()),
    GetPage(name: '/counter', page: () => CounterView()),
    GetPage(name: '/notes', page: () => NotesView()),
  ],
)

// Navigate using defined routes
Get.toNamed('/counter');
```

---

### Issue: Back button not working

**Solution:**

```dart
// ✅ Use Get.back() instead of Navigator.pop()
ElevatedButton(
  onPressed: () => Get.back(),
  child: Text('Back'),
)

// Or use WillPopScope for custom behavior
WillPopScope(
  onWillPop: () async {
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
// ✅ Send arguments
Get.toNamed('/details', arguments: {'id': 123, 'name': 'Test'});

// Receive arguments
class DetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final id = args['id'];
    final name = args['name'];
    return Scaffold(/* Use id and name */);
  }
}

// Or use parameters
Get.toNamed('/details?id=123&name=Test');

// Receive parameters
final id = Get.parameters['id'];
final name = Get.parameters['name'];
```

---

## 💾 Storage Issues

### Issue: GetStorage not initialized

**Error:**
```
GetStorage has not been initialized
```

**Solution:**

```dart
// ✅ Initialize before runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Must await
  runApp(MyApp());
}
```

---

### Issue: Data not persisting

**Problem:** Data lost after app restart

**Solution:**

```dart
// ✅ Use GetStorage correctly
class MyController extends GetxController {
  final _storage = GetStorage();

  void saveData(String key, dynamic value) {
    _storage.write(key, value); // Saves to disk
  }

  dynamic loadData(String key) {
    return _storage.read(key); // Reads from disk
  }

  @override
  void onInit() {
    super.onInit();
    // Load data on init
    final saved = _storage.read('myData');
    if (saved != null) {
      // Use saved data
    }
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
// ✅ Use try-catch when reading
T? readSafe<T>(String key) {
  try {
    return _storage.read<T>(key);
  } catch (e) {
    print('Storage read error: $e');
    _storage.remove(key); // Remove corrupted data
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
GetMaterialApp(
  getPages: [
    GetPage(
      name: '/counter',
      page: () => CounterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CounterController()); // Lazy
      }),
    ),
  ],
)

// Avoid putting too much in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Only essential init
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
// ✅ Dispose controllers properly
@override
void onClose() {
  // Clear large lists
  myLargeList.clear();
  
  // Cancel subscriptions
  subscription.cancel();
  
  // Clear cached data
  cache.clear();
  
  super.onClose();
}

// ✅ Use Get.delete to remove controllers
Get.delete<MyController>();

// ✅ Avoid keeping large objects in memory
// Load data on demand instead of keeping everything
```

---

## 🔍 GetX Specific Issues

### Issue: Workers not triggering

**Problem:** ever(), once(), debounce() not working

**Solution:**

```dart
class MyController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // ✅ Setup workers in onInit
    ever(count, (value) {
      print('Count changed to $value');
    });

    debounce(count, (value) {
      print('Debounced: $value');
    }, time: Duration(seconds: 1));
  }
}
```

---

### Issue: GetBuilder not updating

**Problem:** UI not rebuilding

**Solution:**

```dart
// ✅ Call update() after state change
class MyController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update(); // Must call this
  }

  void decrement() {
    count--;
    update(); // And this
  }
}

// ✅ Or update specific IDs
void increment() {
  count++;
  update(['counter']); // Update only this ID
}

// In widget
GetBuilder<MyController>(
  id: 'counter',
  builder: (controller) => Text('${controller.count}'),
)
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
