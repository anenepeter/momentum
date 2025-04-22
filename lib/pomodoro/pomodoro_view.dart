import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/pomodoro/pomodoro_notifier.dart';
import 'package:momentum/pomodoro/pomodoro_settings_dialog.dart'; // Import the new settings dialog widget

class PomodoroView extends ConsumerWidget {
  const PomodoroView({super.key});

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroProvider);
    final pomodoroNotifier = ref.read(pomodoroProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            formatTime(pomodoroState.currentTime),
            style: const TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          Text(
            pomodoroState.isWorkSession ? 'Work Session' : 'Break Session',
            style: const TextStyle(fontSize: 24.0),
          ),
           const SizedBox(height: 10.0),
          Text(
            'Session: ${pomodoroState.currentSession}',
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: pomodoroState.isRunning
                    ? pomodoroNotifier.pauseTimer
                    : pomodoroNotifier.startTimer,
                child: Text(pomodoroState.isRunning ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: pomodoroNotifier.resetTimer,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
           ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const PomodoroSettingsDialog(); // Use the PomodoroSettingsDialog widget
                },
              );
            },
            child: const Text('Set Settings'),
          ),
        ],
      ),
    );
  }
}