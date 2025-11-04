import '../../../domain/counter/entities/counter_entity.dart';
import '../../../domain/counter/value_objects/counter_value.dart';

/// Counter DTO - Infrastructure Layer
///
/// In DDD, DTOs (Data Transfer Objects):
/// - Handle serialization/deserialization
/// - Live in infrastructure layer
/// - Convert between domain entities and persistence format
/// - Keep domain layer free of framework concerns
class CounterDto {
  final String id;
  final int value;

  const CounterDto({required this.id, required this.value});

  /// Convert from domain entity to DTO
  factory CounterDto.fromEntity(CounterEntity entity) {
    return CounterDto(id: entity.id, value: entity.value.number);
  }

  /// Convert from DTO to domain entity
  CounterEntity toEntity() {
    return CounterEntity(id: id, value: CounterValue(value));
  }

  /// Convert from JSON
  factory CounterDto.fromJson(Map<String, dynamic> json) {
    return CounterDto(id: json['id'] as String, value: json['value'] as int);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value};
  }
}
