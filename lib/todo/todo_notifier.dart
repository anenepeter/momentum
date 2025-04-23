import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo.dart';
import 'todo_storage_service.dart';

// Define the state for the Todo module
class TodoState {
  final List<Todo> tasks;
  final bool isLoading;
  final String? error;

  TodoState({
    required this.tasks,
    required this.isLoading,
    this.error,
  });

  TodoState copyWith({
    List<Todo>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow setting error to null
    );
  }
}

// Define the StateNotifier for the Todo module
class TodoNotifier extends StateNotifier<TodoState> {
  final TodoStorageService _todoStorageService;

  TodoNotifier(this._todoStorageService) : super(TodoState(tasks: [], isLoading: true)) {
    loadTasks();
  }

  Future<void> addTask(String description) async {
    final todo = Todo.create(description: description);
    final updatedTasks = [...state.tasks, todo];
    state = state.copyWith(tasks: updatedTasks);
    await _todoStorageService.saveTasks(updatedTasks);
  }

  Future<void> editTask(String id, String newDescription) async {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(description: newDescription);
      }
      return task;
    }).toList();
    state = state.copyWith(tasks: updatedTasks);
    await _todoStorageService.saveTasks(updatedTasks);
  }

  Future<void> removeTask(String id) async {
    final updatedTasks = state.tasks.where((task) => task.id != id).toList();
    state = state.copyWith(tasks: updatedTasks);
    await _todoStorageService.saveTasks(updatedTasks);
  }

  Future<void> toggleTask(String id) async {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
    state = state.copyWith(tasks: updatedTasks);
    await _todoStorageService.saveTasks(updatedTasks);
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _todoStorageService.loadTasks();
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');
    state = state.copyWith(tasks: []);
  }

  Future<void> clearCompletedTasks() async {
    final updatedTasks = state.tasks.where((task) => !task.isCompleted).toList();
    state = state.copyWith(tasks: updatedTasks);
    await _todoStorageService.saveTasks(updatedTasks);
  }
  int get completedTaskCount {
    return state.tasks.where((task) => task.isCompleted).length;
  }

  int get incompleteTaskCount {
    return state.tasks.where((task) => !task.isCompleted).length;
  }
}

// Define the Riverpod provider for the TodoStorageService
final todoStorageServiceProvider = Provider((ref) => TodoStorageService());

// Define the Riverpod provider for the TodoNotifier
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final todoStorageService = ref.watch(todoStorageServiceProvider);
  return TodoNotifier(todoStorageService);
});