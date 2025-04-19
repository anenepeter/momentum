import 'package:flutter/material.dart';
import 'todo.dart';

class TaskInputModal extends StatefulWidget {
  final Function(String) onTaskSaved;
  final Todo? task;

  const TaskInputModal({super.key, required this.onTaskSaved, this.task});

  @override
  _TaskInputModalState createState() => _TaskInputModalState();
}

class _TaskInputModalState extends State<TaskInputModal> {
  String taskDescription = '';

  @override
  void initState() {
    super.initState();
    taskDescription = widget.task?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.task != null;

    return AlertDialog(
      title: Text(isEditMode ? 'Edit Task' : 'Add New Task'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter task description",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          controller: TextEditingController(text: taskDescription),
          onChanged: (text) {
            taskDescription = text;
          },
          onSubmitted: (text) {
            taskDescription = text;
            if (isEditMode) {
              widget.onTaskSaved(taskDescription);
            } else {
              widget.onTaskSaved(taskDescription);
            }
            Navigator.pop(context);
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (widget.task != null) {
              widget.onTaskSaved(taskDescription);
            } else {
              widget.onTaskSaved(taskDescription);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}