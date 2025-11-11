import 'package:equatable/equatable.dart';

/// Counter Entity - Domain layer
/// Pure business object without any framework dependencies
class Counter extends Equatable {
  final int value;

  const Counter({required this.value});

  /// Create a copy with modified value
  Counter copyWith({int? value}) {
    return Counter(value: value ?? this.value);
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'Counter(value: $value)';
}
