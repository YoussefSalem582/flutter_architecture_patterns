import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';

/// Counter View - Presentation Layer
///
/// UI for counter feature demonstrating DDD with BLoC.
/// Shows value object validation and entity operations.
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter (DDD + BLoC)')),
      body: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          if (state is CounterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CounterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CounterCubit>().loadCounter(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CounterLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Counter Value',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${state.counter.value.number}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<CounterCubit>().increment(),
                        icon: const Icon(Icons.add),
                        label: const Text('Increment'),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.counter.value.canDecrement
                            ? () => context.read<CounterCubit>().decrement()
                            : null,
                        icon: const Icon(Icons.remove),
                        label: const Text('Decrement'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.read<CounterCubit>().reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }
}
