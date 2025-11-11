import 'package:equatable/equatable.dart';

/// Counter Model
/// Represents the data structure for the counter feature
class CounterModel extends Equatable {
  final int value;

  const CounterModel({required this.value});

  /// Creates a copy of the CounterModel with updated values
  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  /// Creates a CounterModel from a JSON map
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'CounterModel(value: $value)';
}
