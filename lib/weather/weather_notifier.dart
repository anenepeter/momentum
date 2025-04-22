import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';

// Define the state for the Weather module
class WeatherState {
  final String temperature;
  final String forecast;
  final bool isLoading;
  final String? error;

  WeatherState({
    required this.temperature,
    required this.forecast,
    required this.isLoading,
    this.error,
  });

  WeatherState copyWith({
    String? temperature,
    String? forecast,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      temperature: temperature ?? this.temperature,
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow setting error to null
    );
  }
}

// Define the StateNotifier for the Weather module
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _weatherService;

  WeatherNotifier(this._weatherService) : super(WeatherState(temperature: 'Loading...', forecast: 'Loading...', isLoading: true)) {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      Position position = await _determinePosition();
      final weatherData = await _weatherService.getWeatherData(position.latitude, position.longitude);

      final temperature = '${weatherData['current']['temperature_2m']}°C';
      final forecast = 'Chance of rain: ${weatherData['current']['precipitation_probability']}%';

      state = state.copyWith(
        temperature: temperature,
        forecast: forecast,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        temperature: 'Error',
        forecast: e.toString(),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}

// Define the Riverpod provider for the WeatherNotifier
final weatherServiceProvider = Provider((ref) => WeatherService());

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherNotifier(weatherService);
});