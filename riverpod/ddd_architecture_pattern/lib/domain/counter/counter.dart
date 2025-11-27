import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final int value;

  const Counter(this.value);

  factory Counter.initial() => const Counter(0);

  Counter increment() => Counter(value + 1);
  Counter decrement() => Counter(value - 1);

  @override
  List<Object?> get props => [value];
}
