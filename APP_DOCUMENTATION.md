# Momentum App Documentation

## 1. App Overview

*   **Name:** Momentum
*   **Purpose:** A minimalist productivity and wellness application designed to help users manage daily activities and track personal metrics simply and effectively.
*   **Core Functionality:** Integrates weather forecasting, task management, a focus timer (Pomodoro), and step tracking into a single interface.
*   **Target Audience:** Individuals seeking straightforward tools to enhance productivity, manage daily tasks, and monitor basic wellness goals (like daily steps).
*   **Technology Stack:**
    *   Framework: Flutter
    *   State Management: Provider
    *   Weather Data: Open-Meteo API
    *   Local Storage: `shared_preferences`
    *   Sensors/Permissions: `geolocator`, `pedometer`, `permission_handler`
    *   Notifications: `flutter_local_notifications` (basic setup)

## 2. Project Requirement Document

### 2.1 Requirement Description

The Momentum app aims to provide users with essential tools for daily planning and self-monitoring:

1.  **Weather Awareness:** Display current temperature and a simple prediction of upcoming rain based on the user's current location.
2.  **Task Management:** Enable users to create, view, mark as complete, and delete daily tasks. Task data must persist between app sessions.
3.  **Focus Timer:** Provide a configurable Pomodoro timer to help users manage work/focus sessions and breaks effectively. Timer settings should persist.
4.  **Activity Tracking:** Track the user's daily step count using the device's pedometer sensor and display progress towards a user-defined daily goal. Step count and goal should persist.
5.  **User Experience:** Maintain a clean, intuitive, and minimalist user interface, respecting system light/dark themes.
6.  **Permissions:** Appropriately request necessary device permissions (Location, Activity Recognition) when needed by features.

### 2.2 Expected Behaviour / Outcome

*   **Weather Tab:** Upon granting location permission, the tab displays the current temperature (in Celsius) and a textual forecast indicating if rain is likely soon ("Rain likely soon", "No rain expected", "Chance of rain (X%)", or "Forecast unavailable"). Includes a refresh button.
*   **Todo Tab:** Users can add tasks via a text field. Tasks appear in a list. Users can tap to toggle completion status (visualized, e.g., strikethrough). Tasks can be dismissed (swiped) to remove them. A button allows clearing all completed tasks. The task list is saved and reloaded when the app restarts.
*   **Pomodoro Tab:** Displays a timer counting down remaining seconds for the current phase (Work/Focus or Break). Buttons allow starting, pausing, and resetting the timer. A settings button allows users to configure the duration (in minutes) for work and break periods; these settings are saved. Basic notification placeholders exist for phase completion.
*   **Steps Tab:** Displays the user's step count for the current day relative to their daily goal, shown both numerically and as a circular progress indicator. A button allows the user to set their daily step goal. Goal and daily steps are saved. Requires activity recognition permission.
*   **General:** The app uses a `TabBar` for navigation between the four main features. The overall theme adapts to the system's light/dark mode setting.

## 3. Features

### 3.1 Current Features (Post-Refactor)

*   **Modular Structure:** Code organized into `app`, `core`, and feature-specific (`weather`, `todo`, `pomodoro`, `steps`) directories.
*   **State Management:** Provider package implemented for managing state within each feature module (`WeatherProvider`, `TodoProvider`, `PomodoroProvider`, `StepsProvider`).
*   **Weather Feature:**
    *   Fetches current temperature and precipitation probability from Open-Meteo API based on device location.
    *   Displays simple rain prediction text.
    *   Handles location permission requests.
    *   Includes basic error handling and loading states.
*   **Todo Feature:**
    *   Full CRUD functionality (Create, Read, Update-toggle, Delete) for tasks.
    *   Persistence using `shared_preferences` via `TodoStorageService`.
    *   Loading state indicator.
*   **Pomodoro Feature:**
    *   Functional timer with start/pause/reset.
    *   Configurable work/break durations via a settings dialog.
    *   Persistence of settings using `shared_preferences`.
    *   Visual distinction between work and break phases.
*   **Steps Feature:**
    *   Tracks steps using the `pedometer` package.
    *   Displays daily steps and progress towards a goal.
    *   Allows users to set a daily goal.
    *   Persistence of goal and daily steps (with daily reset logic) using `shared_preferences`.
    *   Handles activity recognition permission requests.
*   **Core:**
    *   Basic `NotificationService` setup for initializing local notifications.
    *   Centralized app setup (`MomentumApp`) and main navigation (`HomePage` with `TabBar`).

### 3.2 Intended / Future Features

*   **Weather:**
    *   Display more detailed forecast information (e.g., hourly breakdown, multi-day forecast).
    *   Show weather condition icons or descriptions based on WMO codes.
    *   Allow manual location input.
*   **Todo:**
    *   Task prioritization or tagging.
    *   Due dates and reminders.
    *   Sub-tasks.
*   **Pomodoro:**
    *   Implement actual timed notifications for session completion using `flutter_local_notifications`.
    *   Sound alerts.
    *   Long break intervals after multiple sessions.
    *   Session history/statistics.
*   **Steps:**
    *   More robust step counting logic (e.g., handling sensor availability, background updates).
    *   Implement scheduled progress notifications.
    *   Step history/charts.
*   **General:**
    *   Improved UI/UX refinement and visual appeal.
    *   More comprehensive error handling and user feedback messages.
    *   Add unit, widget, and integration tests.
    *   Cloud synchronization for data backup/multi-device use.
    *   User profiles/authentication.
    *   Enhanced accessibility features.
    *   Address potential issues with specific package versions (e.g., `flutter_local_notifications` Linux issue).