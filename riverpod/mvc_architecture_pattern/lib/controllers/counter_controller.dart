import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/counter_model.dart';

/// Controller for Counter functionality
/// Manages counter state and business logic using StateNotifier
class CounterController extends StateNotifier<CounterModel> {
  CounterController() : super(const CounterModel()) {
    _loadState();
  }

  /// Load state from SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('counter_value') ?? 0;
    state = CounterModel(value: value);
  }

  /// Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_value', state.value);
  }

  /// Increment the counter
  void increment() {
    state = state.increment();
    _saveState();
  }

  /// Decrement the counter
  void decrement() {
    state = state.decrement();
    _saveState();
  }

  /// Reset the counter to zero
  void reset() {
    state = state.reset();
    _saveState();
  }
}

/// Provider for CounterController
final counterProvider = StateNotifierProvider<CounterController, CounterModel>((
  ref,
) {
  return CounterController();
});
