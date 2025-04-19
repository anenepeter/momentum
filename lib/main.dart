import 'package:flutter/material.dart';
import 'todo/task_input_modal.dart';

import 'todo/todo.dart';
import 'package:momentum/steps/steps.dart';
import 'package:provider/provider.dart';
import 'package:momentum/weather/weather_provider.dart';
import 'package:momentum/todo/todo_provider.dart';
import 'package:momentum/pomodoro/pomodoro_provider.dart';
import 'package:momentum/steps/steps_provider.dart';

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

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current Time: ${formatTime(pomodoroProvider.currentTime)}'),
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
          ElevatedButton(
            onPressed: () {
              pomodoroProvider.resetTimer();
            },
            child: const Text('Reset'),
          ),
          Text('Work Time: ${pomodoroProvider.workTime}'),
          Text('Break Time: ${pomodoroProvider.breakTime}'),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  int workTime = pomodoroProvider.workTime;
                  int breakTime = pomodoroProvider.breakTime;
                  return AlertDialog(
                    title: const Text('Set Pomodoro Settings'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Work Time (minutes)'),
                          keyboardType: TextInputType.number,
                          initialValue: pomodoroProvider.workTime.toString(),
                          onChanged: (value) {
                            workTime = int.tryParse(value) ?? pomodoroProvider.workTime;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Break Time (minutes)'),
                          keyboardType: TextInputType.number,
                          initialValue: pomodoroProvider.breakTime.toString(),
                          onChanged: (value) {
                            breakTime = int.tryParse(value) ?? pomodoroProvider.breakTime;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          pomodoroProvider.setSettings(workTime, breakTime);
                          Navigator.of(context).pop();
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
