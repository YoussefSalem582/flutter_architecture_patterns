/// Counter Model
/// Represents the data structure for the counter feature
class CounterModel {
  final int value;

  CounterModel({required this.value});

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
  String toString() => 'CounterModel(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CounterModel && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
