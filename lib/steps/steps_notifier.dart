import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Define the state for the Steps module
class StepsState {
  final int steps;
  final int goal;
  final bool isListening;
  final String pedestrianStatus; // Added pedestrian status

  StepsState({
    required this.steps,
    required this.goal,
    required this.isListening,
    this.pedestrianStatus = 'unknown', // Default status
  });

  StepsState copyWith({
    int? steps,
    int? goal,
    bool? isListening,
    String? pedestrianStatus, // Added pedestrian status to copyWith
  }) {
    return StepsState(
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
      isListening: isListening ?? this.isListening,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus, // Copy pedestrian status
    );
  }
}

// Define the StateNotifier for the Steps module
class StepsNotifier extends StateNotifier<StepsState> {
  // SharedPreferences keys
  static const String _dailyStartStepsKey = 'dailyStartSteps';
  static const String _dailyStartDateKey = 'dailyStartDate';
  static const String _goalKey = 'goal';

  int _dailyStartSteps = 0;
  DateTime? _dailyStartDate;

  StepsNotifier() : super(StepsState(steps: 0, goal: 500, isListening: false)) {
    loadData();
  }

  Future<void> startListening() async {
    if (state.isListening) return;

    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
      if (status.isDenied) {
        // Permissions are denied, handle appropriately.
        return;
      }
    }

    if (status.isGranted) {
      state = state.copyWith(isListening: true);

      // Load daily start data before starting the stream
      await _loadDailyStartData();

      // Listen to step count stream
      Pedometer.stepCountStream.listen((event) {
        final currentTotalSteps = event.steps;
        final now = DateTime.now();

        // Check if it's a new day or if daily start data is not set
        if (_dailyStartDate == null || !_isSameDay(_dailyStartDate!, now)) {
          _dailyStartSteps = currentTotalSteps;
          _dailyStartDate = now;
          _saveDailyStartData(); // Save the new start data
          state = state.copyWith(steps: 0); // Reset daily steps to 0 for the new day
        } else {
          // Calculate daily steps
          final dailySteps = currentTotalSteps - _dailyStartSteps;
          state = state.copyWith(steps: dailySteps);
        }
      });

      // Listen to pedestrian status stream
      Pedometer.pedestrianStatusStream.listen((event) {
        state = state.copyWith(pedestrianStatus: event.status); // Update pedestrian status in state
      }).onError((error) {
        print('Pedestrian Status Error: $error');
        state = state.copyWith(pedestrianStatus: 'error'); // Set status to error on error
      });
    }
  }

  Future<void> setGoal(int goal) async {
    state = state.copyWith(goal: goal);
    await _saveGoal(goal);
  }

  Future<void> loadData() async {
    await _loadGoal();
    // Daily start data is loaded in startListening
  }

  Future<void> _loadDailyStartData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyStartSteps = prefs.getInt(_dailyStartStepsKey) ?? 0;
    final dateString = prefs.getString(_dailyStartDateKey);
    if (dateString != null) {
      _dailyStartDate = DateTime.tryParse(dateString);
    }
  }

  Future<void> _saveDailyStartData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyStartStepsKey, _dailyStartSteps);
    await prefs.setString(_dailyStartDateKey, _dailyStartDate?.toIso8601String() ?? '');
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt(_goalKey) ?? 500;
    state = state.copyWith(goal: goal);
  }

  Future<void> _saveGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalKey, goal);
  }

  // Helper to check if two DateTime objects are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

// Define the Riverpod provider for the StepsNotifier
final stepsProvider = StateNotifierProvider<StepsNotifier, StepsState>((ref) {
  return StepsNotifier();
});