import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/weather/weather_notifier.dart';
import 'package:momentum/pomodoro/pomodoro_notifier.dart';
import 'package:momentum/steps/steps_notifier.dart';
import 'package:momentum/todo/todo_notifier.dart';
import 'package:momentum/motivation/motivation_notifier.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Call startListening when the widget is initialized
    ref.read(stepsProvider.notifier).startListening();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final pomodoroState = ref.watch(pomodoroProvider);
    final stepsState = ref.watch(stepsProvider);
    final todoState = ref.watch(todoProvider);
    final motivationalMessage = ref.watch(motivationProvider);

    String formatTime(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
      return '$minutes:$remainingSeconds';
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // Adjust as needed for layout
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7, // Decrease to make cards taller
                children: <Widget>[
                  // Weather Card
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.cloud, size: 50.0),
                        const SizedBox(height: 8.0),
                        const Text('Weather', style: TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 4.0),
                        if (weatherState.isLoading)
                          const CircularProgressIndicator()
                        else if (weatherState.error != null)
                          Text('Error: ${weatherState.error}', style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.error))
                        else
                          Column(
                            children: [
                              Text(weatherState.temperature, style: const TextStyle(fontSize: 14.0)),
                              Text(weatherState.forecast, style: const TextStyle(fontSize: 14.0)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Pomodoro Card
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.timer, size: 50.0),
                        const SizedBox(height: 8.0),
                        const Text('Pomodoro', style: TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 4.0),
                        Text(formatTime(pomodoroState.currentTime), style: const TextStyle(fontSize: 14.0)),
                        Text('Session: ${pomodoroState.currentSession}', style: const TextStyle(fontSize: 14.0)),
                        const SizedBox(height: 16.0), // Add some spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (pomodoroState.isRunning) {
                                  ref.read(pomodoroProvider.notifier).pauseTimer();
                                } else {
                                  ref.read(pomodoroProvider.notifier).startTimer();
                                }
                              },
                              icon: Icon(pomodoroState.isRunning ? Icons.pause : Icons.play_arrow),
                            ),
                            const SizedBox(width: 16.0), // Spacing between buttons
                            IconButton(
                              onPressed: () {
                                ref.read(pomodoroProvider.notifier).resetTimer();
                              },
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Steps Card
                  Card(
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
                  ),
                  // Add more dashboard items here
                  // Todo Summary Card
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.list, size: 50.0),
                        const SizedBox(height: 8.0),
                        const Text('Todo Summary', style: TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 4.0),
                        Text('Completed: ${ref.watch(todoProvider.notifier).completedTaskCount}', style: const TextStyle(fontSize: 14.0)),
                        Text('Undone: ${ref.watch(todoProvider.notifier).incompleteTaskCount}', style: const TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                motivationalMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}