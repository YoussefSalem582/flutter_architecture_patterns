import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';

/// Counter View - Presentation layer
/// Displays counter UI and handles user interactions
class CounterView extends GetView<CounterController> {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter - Clean Architecture'),
        centerTitle: true,
      ),
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

              // Counter Display with Loading
              Obx(() {
                if (controller.isLoading) {
                  return const CircularProgressIndicator();
                }
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
                    '${controller.counterValue}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 48),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement
                  _ActionButton(
                    icon: Icons.remove,
                    label: 'Decrement',
                    color: Colors.red,
                    onPressed: controller.decrement,
                  ),
                  const SizedBox(width: 16),

                  // Reset
                  _ActionButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    color: Colors.orange,
                    onPressed: controller.reset,
                  ),
                  const SizedBox(width: 16),

                  // Increment
                  _ActionButton(
                    icon: Icons.add,
                    label: 'Increment',
                    color: Colors.green,
                    onPressed: controller.increment,
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
                        'Clean Architecture Pattern',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data → Domain → Presentation',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
