# MVVM with Riverpod - Quick Start Guide

## 🎯 What is MVVM?

Model-View-ViewModel (MVVM) facilitates a separation of development of the graphical user interface from the development of the business logic or back-end logic (the data model).

## 🚀 Quick Run

```bash
cd riverpod/mvvm_architecture_pattern
flutter pub get
flutter run
```

## 🏗️ Code Examples

### ViewModel
```dart
final counterViewModelProvider = StateNotifierProvider<CounterViewModel, CounterModel>((ref) {
  // Dependency Injection via ref
  return CounterViewModel(ref.watch(sharedPreferencesProvider));
});

class CounterViewModel extends StateNotifier<CounterModel> {
  final SharedPreferences prefs;
  CounterViewModel(this.prefs) : super(const CounterModel());
  // ...
}
```

### View
```dart
class CounterView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterViewModelProvider);
    // ...
  }
}
```

## ✅ Benefits

*   **Decoupling**: View doesn't depend on Model directly.
*   **Testability**: ViewModels are easy to test.
*   **Reactive**: Fits perfectly with Flutter's reactive nature.
