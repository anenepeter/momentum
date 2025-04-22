import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Define the state for the Pomodoro module
class PomodoroState {
  final int workTime;
  final int breakTime;
  final bool isRunning;
  final int currentTime;
  final bool isWorkSession;
  final int currentSession;

  PomodoroState({
    required this.workTime,
    required this.breakTime,
    required this.isRunning,
    required this.currentTime,
    required this.isWorkSession,
    required this.currentSession,
  });

  PomodoroState copyWith({
    int? workTime,
    int? breakTime,
    bool? isRunning,
    int? currentTime,
    bool? isWorkSession,
    int? currentSession,
  }) {
    return PomodoroState(
      workTime: workTime ?? this.workTime,
      breakTime: breakTime ?? this.breakTime,
      isRunning: isRunning ?? this.isRunning,
      currentTime: currentTime ?? this.currentTime,
      isWorkSession: isWorkSession ?? this.isWorkSession,
      currentSession: currentSession ?? this.currentSession,
    );
  }
}

// Define the StateNotifier for the Pomodoro module
class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier() : super(PomodoroState(
    workTime: 25,
    breakTime: 5,
    isRunning: false,
    currentTime: 25 * 60,
    isWorkSession: true,
    currentSession: 1,
  )) {
    loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startTimer() async {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentTime > 0) {
        state = state.copyWith(currentTime: state.currentTime - 1);
      } else {
        _timer?.cancel();
        int nextSession = state.currentSession;
        if (!state.isWorkSession) {
          nextSession++;
        }
        bool nextIsWorkSession = !state.isWorkSession;
        int nextCurrentTime = nextIsWorkSession ? state.workTime * 60 : state.breakTime * 60;

        state = state.copyWith(
          isWorkSession: nextIsWorkSession,
          currentTime: nextCurrentTime,
          isRunning: false, // Pause after session ends
          currentSession: nextSession,
        );
        // Optionally, add a notification or sound here
      }
    });
  }

  Future<void> pauseTimer() async {
    state = state.copyWith(isRunning: false);
    _timer?.cancel();
  }

  Future<void> resetTimer() async {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isWorkSession: true, // Reset to work session on manual reset
      currentTime: state.workTime * 60,
      currentSession: 1, // Reset session counter
    );
  }

  Future<void> setSettings(int workTime, int breakTime) async {
    state = state.copyWith(workTime: workTime, breakTime: breakTime);
    await saveSettings();
    resetTimer();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final workTime = prefs.getInt('workTime') ?? 25;
    final breakTime = prefs.getInt('breakTime') ?? 5;
    final currentTime = prefs.getInt('currentTime') ?? workTime * 60;
    final currentSession = prefs.getInt('currentSession') ?? 1;

    state = state.copyWith(
      workTime: workTime,
      breakTime: breakTime,
      currentTime: currentTime,
      currentSession: currentSession,
    );
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workTime', state.workTime);
    await prefs.setInt('breakTime', state.breakTime);
    await prefs.setInt('currentTime', state.currentTime);
    await prefs.setInt('currentSession', state.currentSession);
  }
}

// Define the Riverpod provider for the PomodoroNotifier
final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});