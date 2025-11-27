import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final int value;

  const Counter({required this.value});

  @override
  List<Object> get props => [value];
}
