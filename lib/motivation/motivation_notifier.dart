import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a list of motivational messages
final List<String> _motivationalMessages = [
  "Believe you can and you're halfway there.",
  "The only way to do great work is to love what you do.",
  "Success is not final, failure is not fatal: It is the courage to continue that counts.",
  "The body achieves what the mind believes.",
  "Push yourself because no one else is going to do it for you.",
  "Today's actions are tomorrow's results.",
  "It does not matter how slowly you go as long as you do not stop.",
  "It always seems impossible until it's done.",
  "Start where you are. Use what you have. Do what you can.",
];

// StateNotifier to manage the current motivational message
class MotivationNotifier extends StateNotifier<String> {
  Timer? _timer;
  int _currentIndex = 0;

  MotivationNotifier() : super(_motivationalMessages.first) {
    // Initialize the timer to cycle messages every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _cycleMessage();
    });
  }

  // Method to get the current message (state)
  String getCurrentMessage() {
    return state;
  }

  // Method to cycle to the next message and update state
  void _cycleMessage() {
    _currentIndex = (_currentIndex + 1) % _motivationalMessages.length;
    state = _motivationalMessages[_currentIndex]; // Update state
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }
}

// Riverpod provider for the MotivationNotifier
final motivationProvider = StateNotifierProvider<MotivationNotifier, String>((ref) {
  return MotivationNotifier();
});