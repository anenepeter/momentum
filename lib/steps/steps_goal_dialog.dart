import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/steps/steps_notifier.dart';

class StepsGoalDialog extends ConsumerStatefulWidget {
  const StepsGoalDialog({Key? key}) : super(key: key);

  @override
  _StepsGoalDialogState createState() => _StepsGoalDialogState();
}

class _StepsGoalDialogState extends ConsumerState<StepsGoalDialog> {
  final _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load current goal when the dialog opens
    final stepsState = ref.read(stepsProvider);
    _goalController.text = stepsState.goal.toString();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = int.parse(_goalController.text);
      ref.read(stepsProvider.notifier).setGoal(goal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Steps Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Steps Goal'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a goal';
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
          onPressed: _saveGoal,
          child: const Text('Save'),
        ),
      ],
    );
  }
}