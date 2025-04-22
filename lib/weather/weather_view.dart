import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/weather/weather_notifier.dart';

class WeatherView extends ConsumerWidget {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);

    if (weatherState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weatherState.error != null) {
      return Center(child: Text('Error: ${weatherState.error}'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.cloud, size: 80.0),
          const SizedBox(height: 20.0),
          Text(
            weatherState.temperature,
            style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Text(
            weatherState.forecast,
            style: const TextStyle(fontSize: 24.0),
          ),
        ],
      ),
    );
  }
}