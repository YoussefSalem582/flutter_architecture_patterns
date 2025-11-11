import '../../domain/entities/counter.dart';

/// Counter Model - Data layer
/// Extends Counter entity and adds JSON serialization
class CounterModel extends Counter {
  const CounterModel({required super.value});

  /// Convert entity to model
  factory CounterModel.fromEntity(Counter counter) {
    return CounterModel(value: counter.value);
  }

  /// Convert to entity
  Counter toEntity() {
    return Counter(value: value);
  }

  /// Create from JSON
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  @override
  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }
}
