import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/counter_model.dart';
import '../providers/app_providers.dart';

class CounterViewModel extends StateNotifier<CounterModel> {
  final SharedPreferences _prefs;

  CounterViewModel(this._prefs) : super(const CounterModel()) {
    _loadCounter();
  }

  void _loadCounter() {
    final savedValue = _prefs.getInt('counter_value') ?? 0;
    state = CounterModel(value: savedValue);
  }

  Future<void> increment() async {
    final newValue = state.value + 1;
    state = state.copyWith(value: newValue);
    await _prefs.setInt('counter_value', newValue);
  }

  Future<void> decrement() async {
    final newValue = state.value - 1;
    state = state.copyWith(value: newValue);
    await _prefs.setInt('counter_value', newValue);
  }

  Future<void> reset() async {
    state = const CounterModel(value: 0);
    await _prefs.setInt('counter_value', 0);
  }
}

final counterViewModelProvider =
    StateNotifierProvider<CounterViewModel, CounterModel>((ref) {
      return CounterViewModel(ref.watch(sharedPreferencesProvider));
    });
