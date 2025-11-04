import 'package:equatable/equatable.dart';

import '../value_objects/counter_value.dart';

/// Counter Entity - Domain Model
///
/// In DDD, entities have:
/// - Identity (unique ID)
/// - Lifecycle
/// - Business rules
/// - Value objects as properties
///
/// This entity is framework-independent (pure Dart)
class CounterEntity extends Equatable {
  final String id;
  final CounterValue value;

  const CounterEntity({required this.id, required this.value});

  /// Business rule: Increment counter
  CounterEntity increment() {
    return CounterEntity(id: id, value: value.increment());
  }

  /// Business rule: Decrement counter (cannot go below zero)
  CounterEntity decrement() {
    return CounterEntity(id: id, value: value.decrement());
  }

  /// Business rule: Reset counter to zero
  CounterEntity reset() {
    return CounterEntity(id: id, value: CounterValue.zero());
  }

  /// Factory: Create new counter with default value
  factory CounterEntity.create(String id) {
    return CounterEntity(id: id, value: CounterValue.zero());
  }

  @override
  List<Object?> get props => [id, value];

  @override
  String toString() => 'CounterEntity(id: $id, value: ${value.number})';
}
