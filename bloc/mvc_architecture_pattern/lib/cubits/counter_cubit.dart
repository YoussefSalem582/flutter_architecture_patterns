import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/counter_model.dart';

/// Cubit for Counter functionality
/// Manages counter state and business logic using Cubit
/// Uses HydratedCubit for automatic state persistence across app restarts
class CounterCubit extends HydratedCubit<CounterModel> {
  CounterCubit() : super(const CounterModel());

  /// Increment the counter
  void increment() {
    emit(state.increment());
  }

  /// Decrement the counter
  void decrement() {
    emit(state.decrement());
  }

  /// Reset the counter to zero
  void reset() {
    emit(state.reset());
  }

  @override
  CounterModel? fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  @override
  Map<String, dynamic>? toJson(CounterModel state) {
    return {'value': state.value};
  }
}
