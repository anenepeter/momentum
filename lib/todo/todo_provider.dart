import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo.dart';
import 'todo_storage_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _tasks = [];
  final _todoStorageService = TodoStorageService();

  List<Todo> get tasks => _tasks;

  Future<void> addTask(String description) async {
    final todo = Todo.create(description: description);
    _tasks.add(todo);
    notifyListeners();
    await _todoStorageService.saveTasks(_tasks);
  }

  Future<void> editTask(String id, String newDescription) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].description = newDescription;
      notifyListeners();
      await _todoStorageService.saveTasks(_tasks);
    }
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await _todoStorageService.saveTasks(_tasks);
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
      await _todoStorageService.saveTasks(_tasks);
    }
  }

  Future<void> loadTasks() async {
    _tasks = await _todoStorageService.loadTasks();
    notifyListeners();
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
    await _todoStorageService.saveTasks(_tasks);
  }
}