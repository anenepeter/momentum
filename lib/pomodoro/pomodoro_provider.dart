import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PomodoroProvider extends ChangeNotifier {
  int _workTime = 25;
  int _breakTime = 5;
  bool _isRunning = false;
  int _currentTime = 25 * 60; // Work time in seconds
  Timer? _timer;

  int get workTime => _workTime;
  int get breakTime => _breakTime;
  bool get isRunning => _isRunning;
  int get currentTime => _currentTime;

  Future<void> startTimer() async {
    _isRunning = true;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        _currentTime--;
        notifyListeners();
      } else {
        stopTimer();
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
    _currentTime = _workTime * 60;
    notifyListeners();
  }

  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
    _currentTime = _workTime * 60;
    notifyListeners();
  }

  Future<void> setSettings(int workTime, int breakTime) async {
    _workTime = workTime;
    _breakTime = breakTime;
    notifyListeners();
    await _saveSettings();
    resetTimer();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workTime = prefs.getInt('workTime') ?? 25;
    _breakTime = prefs.getInt('breakTime') ?? 5;
    _currentTime = prefs.getInt('currentTime') ?? _workTime * 60;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workTime', _workTime);
    await prefs.setInt('breakTime', _breakTime);
    await prefs.setInt('currentTime', _currentTime);
  }
}