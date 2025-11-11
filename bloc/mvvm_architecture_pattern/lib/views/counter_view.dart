import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/counter_viewmodel.dart';
import '../models/counter_model.dart';

/// Counter View
/// Displays the counter and buttons to increment, decrement, and reset
/// Uses BlocBuilder widget to reactively update UI when ViewModel state changes
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterViewModel(),
      child: Builder(
        builder: (context) {
          final viewModel = context.read<CounterViewModel>();

          return Scaffold(
            appBar: AppBar(title: const Text('Counter'), centerTitle: true),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Counter Icon
                    const Icon(Icons.calculate, size: 80, color: Colors.blue),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Counter Value',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Counter Display - Observes counterValue changes
                    BlocConsumer<CounterViewModel, CounterModel>(
                      listener: (context, state) {
                        // Show snackbar on counter change
                        String message;
                        if (state.value == 0) {
                          message = 'Counter has been reset to 0';
                        } else {
                          message = 'Counter updated to ${state.value}';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      builder: (context, state) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Text(
                            '${state.value}',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                        );
                      },
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
                          onPressed: viewModel.decrement,
                        ),
                        const SizedBox(width: 16),

                        // Reset Button
                        _ActionButton(
                          icon: Icons.refresh,
                          label: 'Reset',
                          color: Colors.orange,
                          onPressed: viewModel.reset,
                        ),
                        const SizedBox(width: 16),

                        // Increment Button
                        _ActionButton(
                          icon: Icons.add,
                          label: 'Increment',
                          color: Colors.green,
                          onPressed: viewModel.increment,
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Info Card
                    Card(
                      color: Colors.blue.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(
                              'This counter uses BLoC/Cubit state management',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The UI automatically updates when the ViewModel emits new state',
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
            ),
          );
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
