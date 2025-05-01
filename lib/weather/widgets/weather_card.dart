import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/weather/weather_notifier.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.cloud, size: 50.0),
          const SizedBox(height: 8.0),
          const Text('Weather', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 4.0),
          if (weatherState.isLoading)
            const CircularProgressIndicator()
          else if (weatherState.error != null)
            Text('Error: ${weatherState.error}', style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.error))
          else
            Column(
              children: [
                Text(weatherState.temperature, style: const TextStyle(fontSize: 14.0)),
                Text(weatherState.forecast, style: const TextStyle(fontSize: 14.0)),
              ],
            ),
        ],
      ),
    );
  }
}