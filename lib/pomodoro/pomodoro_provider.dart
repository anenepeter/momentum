import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PomodoroProvider extends ChangeNotifier {
  int _workTime = 25;
  int _breakTime = 5;
  bool _isRunning = false;
  int _currentTime = 25 * 60; // Work time in seconds
  bool _isWorkSession = true;
  Timer? _timer;
  int _currentSession = 1; // Add session counter

  int get workTime => _workTime;
  int get breakTime => _breakTime;
  bool get isRunning => _isRunning;
  int get currentTime => _currentTime;
  bool get isWorkSession => _isWorkSession;
  int get currentSession => _currentSession; // Getter for session counter

  Future<void> startTimer() async {
    _isRunning = true;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        _currentTime--;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (!_isWorkSession) { // Increment session only after a break
          _currentSession++;
        }
        _isWorkSession = !_isWorkSession;
        _currentTime = _isWorkSession ? _workTime * 60 : _breakTime * 60;
        _isRunning = false; // Pause after session ends
        notifyListeners();
        // Optionally, add a notification or sound here
      }
    });
  }

  Future<void> pauseTimer() async {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> resetTimer() async {
    _isRunning = false;
    _timer?.cancel();
    _isWorkSession = true; // Reset to work session on manual reset
    _currentTime = _workTime * 60;
    _currentSession = 1; // Reset session counter
    notifyListeners();
  }

  int getCurrentTime() {
    return _currentTime;
  }

  Future<void> setSettings(int workTime, int breakTime) async {
    _workTime = workTime;
    _breakTime = breakTime;
    notifyListeners();
    await saveSettings();
    resetTimer();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workTime = prefs.getInt('workTime') ?? 25;
    _breakTime = prefs.getInt('breakTime') ?? 5;
    _currentTime = prefs.getInt('currentTime') ?? _workTime * 60;
    _currentSession = prefs.getInt('currentSession') ?? 1; // Load session counter
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workTime', _workTime);
    await prefs.setInt('breakTime', _breakTime);
    await prefs.setInt('currentTime', _currentTime);
    await prefs.setInt('currentSession', _currentSession); // Save session counter
  }
}