import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

class StepsProvider extends ChangeNotifier {
  int _steps = 0;
  int _goal = 10000;
  bool _isListening = false;

  int get steps => _steps;
  int get goal => _goal;
  bool get isListening => _isListening;

  Future<void> startListening() async {
    print("StepsProvider: startListening called");
    if (_isListening) return;

    var status = await Permission.activityRecognition.status;
    print("StepsProvider: Activity recognition permission status: $status");
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
      print("StepsProvider: Activity recognition permission request result: $status");
      if (status.isDenied) {
        // Permissions are denied, handle appropriately.
        print("StepsProvider: Activity recognition permission denied");
        return;
      }
    }

    if (status.isGranted) {
      _isListening = true;
      Pedometer.stepCountStream.listen((event) {
        print("StepsProvider: Step count event received: ${event.steps}");
        _steps = event.steps;
        notifyListeners();
        _saveSteps();
      });
    }
  }

  Future<void> setGoal(int goal) async {
    _goal = goal;
    notifyListeners();
    await _saveGoal();
  }


  Future<void> loadData() async {
    await _loadSteps();
    await _loadGoal();
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    _steps = prefs.getInt('steps') ?? 0;
    notifyListeners();
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', _steps);
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    _goal = prefs.getInt('goal') ?? 10000;
    notifyListeners();
  }

  Future<void> _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', _goal);
  }
}