import '../../domain/counter/counter.dart';

class CounterDto {
  final int value;

  const CounterDto({required this.value});

  factory CounterDto.fromDomain(Counter counter) {
    return CounterDto(value: counter.value);
  }

  Counter toDomain() {
    return Counter(value);
  }

  factory CounterDto.fromJson(Map<String, dynamic> json) {
    return CounterDto(value: json['value'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}
