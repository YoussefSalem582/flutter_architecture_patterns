import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/counter_model.dart';

/// Counter ViewModel (Cubit)
/// Contains reactive data and business logic for the counter feature
/// Uses Cubit to enable reactive UI updates via BlocBuilder
class CounterViewModel extends Cubit<CounterModel> {
  CounterViewModel() : super(const CounterModel(value: 0));

  /// Getter to access just the counter value
  int get counterValue => state.value;

  /// Increment the counter by 1
  void increment() {
    emit(state.copyWith(value: counterValue + 1));
  }

  /// Decrement the counter by 1
  void decrement() {
    emit(state.copyWith(value: counterValue - 1));
  }

  /// Reset the counter to 0
  void reset() {
    emit(const CounterModel(value: 0));
  }

  @override
  void onChange(Change<CounterModel> change) {
    super.onChange(change);
    print(
      'CounterViewModel changed: ${change.currentState.value} -> ${change.nextState.value}',
    );
  }

  @override
  Future<void> close() {
    print('CounterViewModel disposed');
    return super.close();
  }
}
