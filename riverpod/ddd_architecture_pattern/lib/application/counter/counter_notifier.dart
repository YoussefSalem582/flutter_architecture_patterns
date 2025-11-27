import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/counter/counter.dart';
import '../../domain/counter/i_counter_repository.dart';

class CounterNotifier extends StateNotifier<Counter> {
  final ICounterRepository _repository;

  CounterNotifier(this._repository) : super(Counter.initial()) {
    _load();
  }

  Future<void> _load() async {
    final failureOrCounter = await _repository.getCounter();
    failureOrCounter.fold(
      (failure) => null, // Could handle error state
      (counter) => state = counter,
    );
  }

  Future<void> increment() async {
    final newCounter = state.increment();
    state = newCounter;
    await _repository.saveCounter(newCounter);
  }

  Future<void> decrement() async {
    final newCounter = state.decrement();
    state = newCounter;
    await _repository.saveCounter(newCounter);
  }
}
