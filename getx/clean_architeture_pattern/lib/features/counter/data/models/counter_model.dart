import '../../domain/entities/counter.dart';

/// Counter Model - Data layer
/// Extends Counter entity with JSON serialization
class CounterModel extends Counter {
  const CounterModel({required super.value});

  /// Create from JSON
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  /// Create from entity
  factory CounterModel.fromEntity(Counter counter) {
    return CounterModel(value: counter.value);
  }

  /// Convert to entity
  Counter toEntity() {
    return Counter(value: value);
  }
}
