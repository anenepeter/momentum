import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/steps/steps_notifier.dart';

class StepsCard extends ConsumerWidget {
  const StepsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsState = ref.watch(stepsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for better spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: <Widget>[
            // Dynamic Icon based on pedestrian status
            Icon(
              stepsState.pedestrianStatus == 'walking'
                  ? Icons.directions_walk
                  : stepsState.pedestrianStatus == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error, // Default or error icon
              size: 50.0,
            ),
            const SizedBox(height: 8.0),
            const Text('Steps', style: TextStyle(fontSize: 18.0)),
            const SizedBox(height: 4.0),
            Text('${stepsState.steps} steps', style: const TextStyle(fontSize: 14.0)),
            Text('Goal: ${stepsState.goal} steps', style: const TextStyle(fontSize: 14.0)),
            const SizedBox(height: 8.0), // Spacing before progress bar
            // Progress bar
            LinearProgressIndicator(
              value: stepsState.goal > 0 ? stepsState.steps / stepsState.goal : 0.0, // Calculate progress
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}