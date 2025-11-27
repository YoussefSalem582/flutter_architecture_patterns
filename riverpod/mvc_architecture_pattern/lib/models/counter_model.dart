import 'package:equatable/equatable.dart';

/// Model class for Counter
/// Holds the counter value data
class CounterModel extends Equatable {
  final int value;

  const CounterModel({this.value = 0});

  /// Increment the counter value
  CounterModel increment() {
    return CounterModel(value: value + 1);
  }

  /// Decrement the counter value
  CounterModel decrement() {
    return CounterModel(value: value - 1);
  }

  /// Reset the counter to zero
  CounterModel reset() {
    return const CounterModel(value: 0);
  }

  /// Create a copy with new value
  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }

  @override
  List<Object?> get props => [value];
}
