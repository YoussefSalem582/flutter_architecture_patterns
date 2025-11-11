import 'dart:convert';

import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/value_objects/counter_value.dart';

/// CounterDTO - Data Transfer Object
///
/// Handles serialization/deserialization between domain entities
/// and infrastructure (storage, APIs, etc.).
///
/// Separates domain model from persistence format.
class CounterDTO {
  final String id;
  final int value;

  CounterDTO({required this.id, required this.value});

  /// Convert from domain entity to DTO
  factory CounterDTO.fromEntity(CounterEntity entity) {
    return CounterDTO(id: entity.id, value: entity.value.number);
  }

  /// Convert from DTO to domain entity
  CounterEntity toEntity() {
    return CounterEntity(id: id, value: CounterValue(value));
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value};
  }

  /// Deserialize from JSON
  factory CounterDTO.fromJson(Map<String, dynamic> json) {
    return CounterDTO(id: json['id'] as String, value: json['value'] as int);
  }

  /// Encode to JSON string
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string
  factory CounterDTO.decode(String source) =>
      CounterDTO.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
