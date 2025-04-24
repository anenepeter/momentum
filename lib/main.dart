import 'package:flutter/material.dart';
import 'package:momentum/theme/theme_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

// Import Riverpod notifiers
// Import new settings notifier

// Import view components (will be created/refactored)
import 'package:momentum/todo/todo_view.dart';
import 'package:momentum/settings/settings_view.dart';
import 'package:momentum/dashboard/dashboard_view.dart'; // Import new dashboard view

void main() {
  runApp(
    const ProviderScope( // Wrap the app with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      title: 'Momentum',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of widgets for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardView(), // New Dashboard tab
    TodoView(), // Existing Todo tab (will be refactored)
    SettingsView(), // New Settings tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder widgets for the new views (will be implemented in separate files)
// Existing tab widgets will be refactored or replaced by these.

// Note: The original WeatherTab, TodoTab, PomodoroTab, and StepsTab
// widgets are no longer used directly in the HomePage structure
// and will be refactored into smaller components used within DashboardView
// or updated to use Riverpod within TodoView and SettingsView.

// The original TodoItem widget might be reused or adapted within TodoView.
// The original formatTime helper function from PomodoroTab might be moved
// to a utility file or kept within the Pomodoro view component.
