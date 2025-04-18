import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'todo.dart';

class TodoStorageService {
  Future<List<Todo>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tasks');
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> saveTasks(List<Todo> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((task) => task.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('tasks', jsonString);
  }
}