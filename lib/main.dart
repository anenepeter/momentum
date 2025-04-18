import 'package:flutter/material.dart';

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
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Momentum'),
          bottom: const TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.wb_sunny), text: 'Weather'),
              Tab(icon: Icon(Icons.list), text: 'Todo'),
              Tab(icon: Icon(Icons.timer), text: 'Pomodoro'),
              Tab(icon: Icon(Icons.directions_walk), text: 'Steps'),
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
  const WeatherTab({Key? key}) : super(key: key);

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
  const TodoTab({Key? key}) : super(key: key);

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
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Row(
             children: [
               Expanded(
                 child: TextField(
                   decoration: const InputDecoration(hintText: 'Add task'),
                   onSubmitted: (value) {
                     todoProvider.addTask(value);
                   },
                 ),
               ),
               IconButton(
                 icon: const Icon(Icons.add),
                 onPressed: () {
                   // TODO: Implement add task logic
                 },
               ),
             ],
           ),
         ),
       ],
     ),
   );
 }
}

class TodoItem extends StatelessWidget {
 final Todo task;

 const TodoItem({
   Key? key,
   required this.task,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   final todoProvider = Provider.of<TodoProvider>(context, listen: false);
   return ListTile(
     title: Text(task.description),
     leading: Checkbox(
       value: task.isCompleted,
       onChanged: (bool? value) {
         todoProvider.toggleTask(task.id);
       },
     ),
     trailing: IconButton(
       icon: const Icon(Icons.delete),
       onPressed: () {
         todoProvider.removeTask(task.id);
       },
     ),
   );
 }
}

class PomodoroTab extends StatefulWidget {
  const PomodoroTab({Key? key}) : super(key: key);

  @override
  State<PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<PomodoroTab> {
  final _workTimeController = TextEditingController(text: '25');
  final _breakTimeController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    Provider.of<PomodoroProvider>(context, listen: false).loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroProvider = Provider.of<PomodoroProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current Time: ${pomodoroProvider.currentTime}'),
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
                  return AlertDialog(
                    title: const Text('Set Pomodoro Settings'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _workTimeController,
                          decoration: const InputDecoration(labelText: 'Work Time (minutes)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: _breakTimeController,
                          decoration: const InputDecoration(labelText: 'Break Time (minutes)'),
                          keyboardType: TextInputType.number,
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
                          int workTime = int.tryParse(_workTimeController.text) ?? 25;
                          int breakTime = int.tryParse(_breakTimeController.text) ?? 5;
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
  const StepsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Steps();
  }
}
