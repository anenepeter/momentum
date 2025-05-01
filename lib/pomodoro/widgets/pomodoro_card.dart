import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/pomodoro/pomodoro_notifier.dart';
import 'package:momentum/utils/format_utils.dart';

class PomodoroCard extends ConsumerWidget {
  const PomodoroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroProvider);

    return Card(
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
    );
  }
}