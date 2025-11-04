import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/counter_controller.dart';

/// Counter View - Presentation Layer
///
/// In DDD:
/// - Views are part of presentation layer
/// - They observe controller state (reactive)
/// - They trigger use cases via controller methods
/// - They display domain concepts in UI terms
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Counter Value:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16),

              // Display counter value (from domain entity)
              Text(
                '${controller.counterValue}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),

              const SizedBox(height: 48),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement
                  ElevatedButton.icon(
                    onPressed: controller.canDecrement
                        ? controller.decrement
                        : null,
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrement'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Increment
                  ElevatedButton.icon(
                    onPressed: controller.increment,
                    icon: const Icon(Icons.add),
                    label: const Text('Increment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Reset button
              OutlinedButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Zero'),
              ),

              const SizedBox(height: 32),

              // Domain rule indicator
              if (!controller.canDecrement)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Domain rule: Counter cannot go below zero',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
