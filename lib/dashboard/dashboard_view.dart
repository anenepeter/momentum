import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/steps/steps_notifier.dart';

import 'package:momentum/weather/widgets/weather_card.dart';
import 'package:momentum/pomodoro/widgets/pomodoro_card.dart';
import 'package:momentum/steps/widgets/steps_card.dart';
import 'package:momentum/todo/widgets/todo_summary_card.dart';
import 'package:momentum/motivation/widgets/motivational_message_widget.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

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
                  const WeatherCard(),
                  // Pomodoro Card
                  const PomodoroCard(),
                  // Steps Card
                  const StepsCard(),
                  // Add more dashboard items here
                  // Todo Summary Card
                  const TodoSummaryCard(),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const MotivationalMessageWidget(),
            ),
          ),
        ],
      ),
    );
  }
}