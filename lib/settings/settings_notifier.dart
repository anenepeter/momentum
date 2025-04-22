import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the state for the Settings module
class SettingsState {
  final bool darkMode;
  final int pomodoroWorkTime;
  final int pomodoroBreakTime;
  final int stepGoal;

  SettingsState({
    required this.darkMode,
    required this.pomodoroWorkTime,
    required this.pomodoroBreakTime,
    required this.stepGoal,
  });

  SettingsState copyWith({
    bool? darkMode,
    int? pomodoroWorkTime,
    int? pomodoroBreakTime,
    int? stepGoal,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      pomodoroWorkTime: pomodoroWorkTime ?? this.pomodoroWorkTime,
      pomodoroBreakTime: pomodoroBreakTime ?? this.pomodoroBreakTime,
      stepGoal: stepGoal ?? this.stepGoal,
    );
  }
}

// Define the StateNotifier for the Settings module
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(
    darkMode: false,
    pomodoroWorkTime: 25,
    pomodoroBreakTime: 5,
    stepGoal: 10000,
  )) {
    loadSettings();
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    await _saveSettings();
  }

  Future<void> setPomodoroTimes({int? workTime, int? breakTime}) async {
    state = state.copyWith(
      pomodoroWorkTime: workTime ?? state.pomodoroWorkTime,
      pomodoroBreakTime: breakTime ?? state.pomodoroBreakTime,
    );
    await _saveSettings();
  }

  Future<void> setStepGoal(int goal) async {
    state = state.copyWith(stepGoal: goal);
    await _saveSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('darkMode') ?? false;
    final pomodoroWorkTime = prefs.getInt('pomodoroWorkTime') ?? 25;
    final pomodoroBreakTime = prefs.getInt('pomodoroBreakTime') ?? 5;
    final stepGoal = prefs.getInt('stepGoal') ?? 10000;

    state = state.copyWith(
      darkMode: darkMode,
      pomodoroWorkTime: pomodoroWorkTime,
      pomodoroBreakTime: pomodoroBreakTime,
      stepGoal: stepGoal,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', state.darkMode);
    await prefs.setInt('pomodoroWorkTime', state.pomodoroWorkTime);
    await prefs.setInt('pomodoroBreakTime', state.pomodoroBreakTime);
    await prefs.setInt('stepGoal', state.stepGoal);
  }
}

// Define the Riverpod provider for the SettingsNotifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});