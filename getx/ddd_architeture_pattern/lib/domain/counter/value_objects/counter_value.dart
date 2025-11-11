import 'package:equatable/equatable.dart';

/// CounterValue - Value Object
///
/// In DDD, value objects:
/// - Have no identity (defined by their values)
/// - Are immutable
/// - Encapsulate validation and business rules
/// - Are compared by value, not identity
///
/// This value object ensures counter cannot be negative
class CounterValue extends Equatable {
  final int number;

  const CounterValue._(this.number);

  /// Factory constructor with validation
  factory CounterValue(int value) {
    if (value < 0) {
      throw ArgumentError('Counter value cannot be negative');
    }
    return CounterValue._(value);
  }

  /// Named constructor for zero
  factory CounterValue.zero() => const CounterValue._(0);

  /// Business rule: Increment
  CounterValue increment() {
    return CounterValue._(number + 1);
  }

  /// Business rule: Decrement (with validation)
  CounterValue decrement() {
    if (number == 0) {
      return this; // Cannot go below zero
    }
    return CounterValue._(number - 1);
  }

  /// Check if counter is at zero
  bool get isZero => number == 0;

  /// Check if counter can be decremented
  bool get canDecrement => number > 0;

  @override
  List<Object?> get props => [number];

  @override
  String toString() => 'CounterValue($number)';
}
