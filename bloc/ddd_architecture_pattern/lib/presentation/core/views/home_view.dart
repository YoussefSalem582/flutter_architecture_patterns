import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

/// Home View - Entry Point
///
/// Landing page with navigation to features.
/// Demonstrates DDD bounded contexts (Counter, Notes).
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DDD Architecture with BLoC'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Title
            const Text(
              'Domain-Driven Design',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'with BLoC State Management',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Feature Cards
            _buildFeatureCard(
              context,
              title: 'Counter',
              description: 'Demonstrates value objects and entity lifecycle',
              icon: Icons.add_circle_outline,
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.counter),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Notes',
              description: 'Demonstrates aggregates and repository pattern',
              icon: Icons.note_outlined,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
