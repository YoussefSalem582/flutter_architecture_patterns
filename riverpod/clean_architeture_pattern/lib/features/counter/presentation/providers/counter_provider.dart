import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/counter_local_data_source.dart';
import '../../data/repositories/counter_repository_impl.dart';
import '../../domain/entities/counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/save_counter.dart';

// Dependency Injection via Providers

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Will be overridden in main.dart
});

final counterLocalDataSourceProvider = Provider<CounterLocalDataSource>((ref) {
  return CounterLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final counterRepositoryProvider = Provider<CounterRepositoryImpl>((ref) {
  return CounterRepositoryImpl(
    localDataSource: ref.watch(counterLocalDataSourceProvider),
  );
});

final getCounterUseCaseProvider = Provider<GetCounter>((ref) {
  return GetCounter(ref.watch(counterRepositoryProvider));
});

final saveCounterUseCaseProvider = Provider<SaveCounter>((ref) {
  return SaveCounter(ref.watch(counterRepositoryProvider));
});

// StateNotifier

class CounterNotifier extends StateNotifier<Counter> {
  final GetCounter getCounter;
  final SaveCounter saveCounter;

  CounterNotifier({required this.getCounter, required this.saveCounter})
    : super(const Counter(value: 0)) {
    loadCounter();
  }

  Future<void> loadCounter() async {
    final result = await getCounter(NoParams());
    result.fold(
      (failure) => null, // Handle error state if needed
      (counter) => state = counter,
    );
  }

  Future<void> increment() async {
    final newCounter = Counter(value: state.value + 1);
    state = newCounter;
    await saveCounter(SaveCounterParams(newCounter));
  }

  Future<void> decrement() async {
    final newCounter = Counter(value: state.value - 1);
    state = newCounter;
    await saveCounter(SaveCounterParams(newCounter));
  }

  Future<void> reset() async {
    const newCounter = Counter(value: 0);
    state = newCounter;
    await saveCounter(SaveCounterParams(newCounter));
  }
}

final counterNotifierProvider = StateNotifierProvider<CounterNotifier, Counter>(
  (ref) {
    return CounterNotifier(
      getCounter: ref.watch(getCounterUseCaseProvider),
      saveCounter: ref.watch(saveCounterUseCaseProvider),
    );
  },
);
