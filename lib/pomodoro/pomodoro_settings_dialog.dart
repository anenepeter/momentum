import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/pomodoro/pomodoro_notifier.dart';

class PomodoroSettingsDialog extends ConsumerStatefulWidget {
  const PomodoroSettingsDialog({Key? key}) : super(key: key);

  @override
  _PomodoroSettingsDialogState createState() => _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends ConsumerState<PomodoroSettingsDialog> {
  final _workTimeController = TextEditingController();
  final _breakTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load current settings when the dialog opens
    final pomodoroState = ref.read(pomodoroProvider);
    _workTimeController.text = pomodoroState.workTime.toString();
    _breakTimeController.text = pomodoroState.breakTime.toString();
  }

  @override
  void dispose() {
    _workTimeController.dispose();
    _breakTimeController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final workTime = int.parse(_workTimeController.text);
      final breakTime = int.parse(_breakTimeController.text);
      ref.read(pomodoroProvider.notifier).setSettings(workTime, breakTime);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Pomodoro Settings'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _workTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Work Time (minutes)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter work time';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive integer';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _breakTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Break Time (minutes)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter break time';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive integer';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }
}