# Momentum

A minimalist productivity and wellness application built with Flutter, designed to help users manage daily activities and track personal metrics simply and effectively.

## App Overview

Momentum integrates essential tools like weather forecasting, task management, a focus timer (Pomodoro), and step tracking into a single, clean interface. It's aimed at individuals seeking straightforward tools to enhance productivity, manage daily tasks, and monitor basic wellness goals.

## Features

*   **Dashboard:** A central hub providing a quick overview of key information from different modules (Weather, Todo Summary, Steps, Motivation).
*   **Todo:** Manage your daily tasks. You can add, view, mark tasks as complete, and delete them. Task data persists between app sessions using `shared_preferences`.
*   **Pomodoro:** A configurable focus timer based on the Pomodoro technique. Set work and break intervals to manage your work sessions effectively. Timer settings persist using `shared_preferences`.
*   **Steps:** Track your daily step count using your device's pedometer sensor. Monitor your progress towards a user-defined daily goal. Step count and goal persist using `shared_preferences`. Requires Activity Recognition permission.
*   **Weather:** Get current temperature and a simple prediction of upcoming rain based on your current location. Uses the Open-Meteo API and requires Location permissions via `geolocator`.
*   **Motivation:** Displays motivational messages (likely on the Dashboard).
*   **Settings:** Configure various aspects of the application, including theme (light/dark), Pomodoro work/break times, and your daily step goal.
*   **Theme:** Switch between light and dark themes for a personalized user experience.

## Technology Stack

*   **Framework:** Flutter
*   **State Management:** Riverpod
*   **Weather Data:** Open-Meteo API (fetched via `weather_service.dart`)
*   **Local Storage:** `shared_preferences` (for Todo, Pomodoro settings, and Steps data)
*   **Sensors/Permissions:** `geolocator` (for Location), `pedometer` (for Step Tracking), `permission_handler` (for requesting permissions)
*   **Notifications:** `flutter_local_notifications` (basic setup, likely for Pomodoro timer completion)

## Project Structure

The project follows a modular structure, with features organized into separate directories within the `lib` folder:

*   `lib/main.dart`: Application entry point and main navigation setup.
*   `lib/dashboard/`: Contains the main dashboard view and related widgets.
*   `lib/todo/`: Contains logic and UI for the Todo feature.
*   `lib/pomodoro/`: Contains logic and UI for the Pomodoro timer.
*   `lib/steps/`: Contains logic and UI for the Step Tracking feature.
*   `lib/weather/`: Contains logic and services for fetching and displaying weather data.
*   `lib/settings/`: Contains logic and UI for the application settings.
*   `lib/theme/`: Contains theme-related logic and definitions.
*   `lib/utils/`: Contains utility functions.

Each feature typically has a `*_notifier.dart` file for state management using Riverpod and corresponding view or widget files.

## Getting Started

This project is a standard Flutter application. To get started:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/anenepeter/momentum
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd momentum
    ```
3.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

