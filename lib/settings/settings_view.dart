// Author: Peter Anene

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/pomodoro/pomodoro_notifier.dart';
import 'package:momentum/steps/steps_notifier.dart';
import 'package:momentum/theme/theme_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers to rebuild the widget when their state changes
    final pomodoroState = ref.watch(pomodoroProvider);
    final stepsState = ref.watch(stepsProvider);
    final themeState = ref.watch(themeNotifierProvider);

    // Get the notifiers to call methods that change state
    final pomodoroNotifier = ref.read(pomodoroProvider.notifier);
    final stepsNotifier = ref.read(stepsProvider.notifier);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Pomodoro Settings Section
          SettingsSection(
            title: 'Pomodoro Timer',
            icon: Icons.timer,
            children: [
              ListTile(
                title: const Text('Work Duration'),
                subtitle: Text('${pomodoroState.workTime} minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimeSettingDialog(
                  context,
                  'Work Duration',
                  pomodoroState.workTime,
                  (value) => pomodoroNotifier.setSettings(value, pomodoroState.breakTime),
                ),
              ),
              ListTile(
                title: const Text('Break Duration'),
                subtitle: Text('${pomodoroState.breakTime} minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimeSettingDialog(
                  context,
                  'Break Duration',
                  pomodoroState.breakTime,
                  (value) => pomodoroNotifier.setSettings(pomodoroState.workTime, value),
                ),
              ),
            ],
          ),

          // Steps Settings Section
          SettingsSection(
            title: 'Steps Tracking',
            icon: Icons.directions_walk,
            children: [
              ListTile(
                title: const Text('Daily Step Goal'),
                subtitle: Text('${stepsState.goal} steps'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNumberInputDialog(
                  context,
                  'Daily Step Goal',
                  stepsState.goal,
                  stepsNotifier.setGoal,
                ),
              ),
            ],
          ),

          // Theme Settings Section
          SettingsSection(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeState == ThemeMode.dark,
                  onChanged: (_) => themeNotifier.toggleTheme(),
                ),
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'About',
            icon: Icons.info,
            children: [
              const ListTile(
                title: Text('App Name'),
                subtitle: Text('Momentum App'), // Replace with actual app name if available
              ),
              const ListTile(
                title: Text('Author'),
                subtitle: Text('Peter Anene'),
              ),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'), // Replace with actual version if available
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReusableNumberInputDialog({
    required BuildContext context,
    required String title,
    required int currentValue,
    required Function(int) onSave,
    String? labelText,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              final number = int.tryParse(value);
              if (number == null || number <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSave(int.parse(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimeSettingDialog(
    BuildContext context,
    String title,
    int currentValue,
    Function(int) onSave,
  ) async {
    return _showReusableNumberInputDialog(
      context: context,
      title: title,
      currentValue: currentValue,
      onSave: onSave,
      labelText: 'Minutes',
    );
  }

  Future<void> _showNumberInputDialog(
    BuildContext context,
    String title,
    int currentValue,
    Function(int) onSave,
  ) async {
    return _showReusableNumberInputDialog(
      context: context,
      title: title,
      currentValue: currentValue,
      onSave: onSave,
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.deepPurple,
                    ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}