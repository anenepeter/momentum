import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/steps/steps_notifier.dart';

class StepsView extends ConsumerWidget {
  const StepsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsState = ref.watch(stepsProvider);
    final stepsNotifier = ref.read(stepsProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Steps: ${stepsState.steps}',
            style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Goal: ${stepsState.goal}',
            style: const TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: stepsNotifier.startListening,
            child: const Text('Start Listening'),
          ),
          const SizedBox(height: 20.0),
          // Add a button or input for setting goal if needed
        ],
      ),
    );
  }
}