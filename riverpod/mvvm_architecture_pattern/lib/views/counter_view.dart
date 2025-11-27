import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/counter_viewmodel.dart';

class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterViewModelProvider);

    // Listen for side effects if needed, though in MVVM UI logic often stays in View
    // or ViewModel exposes a stream of events.
    // Here we just react to state changes.

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(counterViewModelProvider.notifier).reset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Counter reset')));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Count:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '${counterState.value}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () {
              ref.read(counterViewModelProvider.notifier).increment();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () {
              ref.read(counterViewModelProvider.notifier).decrement();
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
