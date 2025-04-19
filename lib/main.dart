import 'package:flutter/material.dart';
import 'todo/task_input_modal.dart';

import 'todo/todo.dart';
import 'package:momentum/steps/steps.dart';
import 'package:provider/provider.dart';
import 'package:momentum/weather/weather_provider.dart';
import 'package:momentum/todo/todo_provider.dart';
import 'package:momentum/pomodoro/pomodoro_provider.dart';
import 'package:momentum/steps/steps_provider.dart';
import 'package:momentum/pomodoro/constants.dart'; // Import the new constants file

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PomodoroProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Momentum'),
          bottom: const TabBar(
            tabs: [
              const Tab(icon: Icon(Icons.wb_sunny), text: 'Weather'),
              const Tab(icon: Icon(Icons.list), text: 'Todo'),
              const Tab(icon: Icon(Icons.timer), text: 'Pomodoro'),
              const Tab(icon: Icon(Icons.directions_walk), text: 'Steps'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChangeNotifierProvider(
              create: (context) => WeatherProvider(),
              child: const WeatherTab(),
            ),
            ChangeNotifierProvider(
              create: (context) => TodoProvider(),
              child: const TodoTab(),
            ),
            const PomodoroTab(),
            ChangeNotifierProvider(
              create: (context) => StepsProvider(),
              child: const StepsTab(),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Temperature: ${weatherProvider.temperature}'),
          Text('Forecast: ${weatherProvider.forecast}'),
          ElevatedButton(
            onPressed: () {
              Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class TodoTab extends StatefulWidget {
  const TodoTab({super.key});

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  @override
  void initState() {
    super.initState();
    Provider.of<TodoProvider>(context, listen: false).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todoProvider.tasks.length,
             itemBuilder: (context, index) {
               final task = todoProvider.tasks[index];
               return TodoItem(task: task,);
             },
           ),
         ),
         ElevatedButton(
           onPressed: () {
             todoProvider.clearCompletedTasks();
           },
           child: const Text('Clear Completed'),
         ),
       ],
     ),
     floatingActionButton: FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TaskInputModal(onTaskSaved: (String task) {
              todoProvider.addTask(task);
            });
          },
        );
      },
      child: const Icon(Icons.add),
    ),
  );
}
}

class TodoItem extends StatelessWidget {
  final Todo task;

  const TodoItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        todoProvider.removeTask(task.id);
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
                todoProvider.toggleTask(task.id);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                todoProvider.removeTask(task.id);
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TaskInputModal(
                    task: task,
                    onTaskSaved: (String updatedTask) {
                      if (updatedTask.isNotEmpty) {
                        todoProvider.editTask(task.id, updatedTask);
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

class PomodoroTab extends StatelessWidget {
  const PomodoroTab({super.key});

  // Helper function to format time from seconds into MM:SS string
  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Access the PomodoroProvider to get the current state
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);

    // Determine colors based on the current session type (work or break)
    // Uses constants defined in pomodoro/constants.dart for better readability and maintainability
    // Revert background color to match the rest of the app
    Color textColor = pomodoroProvider.isWorkSession ? PomodoroColors.workTextColor : PomodoroColors.breakTextColor;

    // Calculate the progress value for the LinearProgressIndicator
    // The progress is calculated as 1.0 minus the ratio of current time to the total session time.
    // This makes the progress bar fill up as time decreases.
    double progressValue = 1.0 - (pomodoroProvider.currentTime / (pomodoroProvider.isWorkSession ? pomodoroProvider.workTime * 60 : pomodoroProvider.breakTime * 60));
    // If the timer is reset and not running, set progress to 0.0 to show an empty progress bar
    if (pomodoroProvider.currentTime == 0 && !pomodoroProvider.isRunning) {
        progressValue = 0.0;
    }


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the formatted current time
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center, // Center the children in the stack
            children: [
              // CircularProgressIndicator to visualize the remaining time
              SizedBox(
                width: 200, // Adjust size as needed
                height: 200, // Adjust size as needed
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 10, // Adjust for visual prominence
                  backgroundColor: Colors.grey[300], // Background color of the track
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor), // Color of the progress indicator (changed to primary color)
                ),
              ),
              // Display the formatted current time and session number inside the circle
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTime(pomodoroProvider.currentTime),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    'Session ${pomodoroProvider.currentSession}',
                    style: TextStyle(fontSize: 20, color: textColor), // Increased font size
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Start/Pause button
          ElevatedButton(
            onPressed: () {
              if (pomodoroProvider.isRunning) {
                pomodoroProvider.pauseTimer();
              } else {
                pomodoroProvider.startTimer();
              }
            },
            child: Text(pomodoroProvider.isRunning ? 'Pause' : 'Start'),
          ),
          // Reset button
          ElevatedButton(
            onPressed: () {
              pomodoroProvider.resetTimer();
            },
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20),
          // Display current work and break times
          Text('Work Time: ${pomodoroProvider.workTime} minutes', style: TextStyle(color: textColor)),
          Text('Break Time: ${pomodoroProvider.breakTime} minutes', style: TextStyle(color: textColor)),
          // Button to open settings dialog
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  int workTime = pomodoroProvider.workTime;
                  int breakTime = pomodoroProvider.breakTime;
                  // Controllers for text fields to manage input and display validation errors
                  final TextEditingController workTimeController = TextEditingController(text: pomodoroProvider.workTime.toString());
                  final TextEditingController breakTimeController = TextEditingController(text: pomodoroProvider.breakTime.toString());
                  // Keys for form validation
                  final _formKey = GlobalKey<FormState>();

                  // AlertDialog for setting Pomodoro times
                  return AlertDialog(
                    title: const Text('Set Pomodoro Settings'),
                    content: Form( // Wrap content in a Form widget for validation
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TextFormField for Work Time input with validation
                          TextFormField(
                            controller: workTimeController,
                            decoration: const InputDecoration(labelText: 'Work Time (minutes)'),
                            keyboardType: TextInputType.number,
                            // Add validator for input validation
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter work time';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Please enter a valid positive integer';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              workTime = int.tryParse(value) ?? pomodoroProvider.workTime;
                            },
                          ),
                          // TextFormField for Break Time input with validation
                          TextFormField(
                            controller: breakTimeController,
                            decoration: const InputDecoration(labelText: 'Break Time (minutes)'),
                            keyboardType: TextInputType.number,
                            // Add validator for input validation
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter break time';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Please enter a valid positive integer';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              breakTime = int.tryParse(value) ?? pomodoroProvider.breakTime;
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      // Cancel button for the dialog
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      // Save button for the dialog with validation
                      ElevatedButton(
                        onPressed: () {
                          // Validate the form before saving
                          if (_formKey.currentState!.validate()) {
                             pomodoroProvider.setSettings(workTime, breakTime);
                             Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Set Settings'),
          ),
        ],
      ),
    );
  }
}

class StepsTab extends StatelessWidget {
  const StepsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Steps();
  }
}
