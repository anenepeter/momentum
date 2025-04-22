import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/todo/todo_notifier.dart';
import 'package:momentum/todo/todo.dart';
import 'package:momentum/todo/task_input_modal.dart'; // Assuming TaskInputModal is reusable

// Todo View Component
class TodoView extends ConsumerWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final todoNotifier = ref.read(todoProvider.notifier);

    if (todoState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todoState.error != null) {
      return Center(child: Text('Error: ${todoState.error}'));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todoState.tasks.length,
              itemBuilder: (context, index) {
                final task = todoState.tasks[index];
                return TodoItem(task: task);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                todoNotifier.clearCompletedTasks();
              },
              child: const Text('Clear Completed'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskInputModal(onTaskSaved: (String description) {
                todoNotifier.addTask(description);
              });
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Reusing or adapting the existing TodoItem widget
class TodoItem extends ConsumerWidget {
  final Todo task;

  const TodoItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoNotifier = ref.read(todoProvider.notifier);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        todoNotifier.removeTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.description} dismissed')),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              task.description,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                todoNotifier.toggleTask(task.id);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                todoNotifier.removeTask(task.id);
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TaskInputModal(
                    task: task,
                    onTaskSaved: (String updatedDescription) {
                      if (updatedDescription.isNotEmpty) {
                        todoNotifier.editTask(task.id, updatedDescription);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}