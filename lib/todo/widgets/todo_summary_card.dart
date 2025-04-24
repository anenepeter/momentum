import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/todo/todo_notifier.dart';

class TodoSummaryCard extends ConsumerWidget {
  const TodoSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoNotifier = ref.watch(todoProvider.notifier);

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.list, size: 50.0),
          const SizedBox(height: 8.0),
          const Text('Todo Summary', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 4.0),
          Text('Completed: ${todoNotifier.completedTaskCount}', style: const TextStyle(fontSize: 14.0)),
          Text('Undone: ${todoNotifier.incompleteTaskCount}', style: const TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}