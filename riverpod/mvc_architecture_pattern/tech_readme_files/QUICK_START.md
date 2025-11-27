# MVC with Riverpod - Quick Start Guide

## 🎯 What is MVC?

Model-View-Controller (MVC) separates the application into three main components:
*   **Model**: Data.
*   **View**: User Interface.
*   **Controller**: Logic and State.

## 🚀 Quick Run

```bash
cd riverpod/mvc_architecture_pattern
flutter pub get
flutter run
```

## 🏗️ Code Examples

### Model
```dart
class CounterModel {
  final int value;
  const CounterModel({this.value = 0});
}
```

### Controller
```dart
final counterControllerProvider = StateNotifierProvider<CounterController, CounterModel>((ref) {
  return CounterController();
});

class CounterController extends StateNotifier<CounterModel> {
  CounterController() : super(const CounterModel());
  void increment() => state = CounterModel(value: state.value + 1);
}
```

### View
```dart
class CounterView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterControllerProvider);
    return Scaffold(
      body: Center(child: Text('${counter.value}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterControllerProvider.notifier).increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## ✅ When to use?

Use MVC when you want a simple separation of logic and UI without the complexity of Clean Architecture or DDD. It's great for small to medium-sized apps.
