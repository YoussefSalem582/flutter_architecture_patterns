import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';

/// Counter View - Presentation layer
/// Displays counter UI and handles user interactions
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter - Clean Architecture'),
        centerTitle: true,
      ),
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
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Counter Icon
                    const Icon(
                      Icons.calculate,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Counter Value',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Counter Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepPurple, width: 2),
                      ),
                      child: Text(
                        '${state.counter.value}',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrement Button
                        _ActionButton(
                          icon: Icons.remove,
                          label: 'Decrement',
                          color: Colors.red,
                          onPressed: () =>
                              context.read<CounterCubit>().decrement(),
                        ),
                        const SizedBox(width: 16),

                        // Reset Button
                        _ActionButton(
                          icon: Icons.refresh,
                          label: 'Reset',
                          color: Colors.orange,
                          onPressed: () => context.read<CounterCubit>().reset(),
                        ),
                        const SizedBox(width: 16),

                        // Increment Button
                        _ActionButton(
                          icon: Icons.add,
                          label: 'Increment',
                          color: Colors.green,
                          onPressed: () =>
                              context.read<CounterCubit>().increment(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Info Card
                    Card(
                      color: Colors.deepPurple.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Clean Architecture with BLoC',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Domain → Data → Presentation layers',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
