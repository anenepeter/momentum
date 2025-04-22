import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/pomodoro/pomodoro_settings_dialog.dart'; // Import PomodoroSettingsDialog
import 'package:momentum/steps/steps_goal_dialog.dart'; // Import StepsGoalDialog
import 'package:momentum/theme/theme_notifier.dart'; // Import theme_notifier.dart

class SettingsView extends ConsumerWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          // Pomodoro Settings
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Pomodoro Settings'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const PomodoroSettingsDialog();
                },
              );
            },
          ),
          const Divider(),
          // Steps Goal Settings
           ListTile(
            leading: const Icon(Icons.directions_walk),
            title: const Text('Steps Goal'),
            onTap: () {
               showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const StepsGoalDialog(); // Assuming you will create this dialog
                },
              );
            },
          ),
          const Divider(),
          // Theme Settings
          ListTile(
            leading: const Icon(Icons.brightness_6), // Or Icons.dark_mode
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ref.watch(themeNotifierProvider) == ThemeMode.dark,
              onChanged: (bool value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          // Add more settings items here
        ],
      ),
    );
  }
}