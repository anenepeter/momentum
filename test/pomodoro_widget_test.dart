import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:momentum/main.dart'; // Assuming MyApp and HomePage are in main.dart


void main() {
  testWidgets('PomodoroTab displays initial time and controls', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(), // Wrap with MyApp to get MaterialApp and other providers if needed
      ),
    );

    // Navigate to the Pomodoro tab
    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle(); // Wait for the tab transition to complete

    // Verify that the initial time is displayed (e.g., 25:00 for default work time)
    // You might need to adjust this based on your PomodoroProvider's initial state
    expect(find.text('25:00'), findsOneWidget);

    // Verify that Start and Reset buttons are displayed
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Set Settings'), findsOneWidget);
  });

  testWidgets('PomodoroTab starts and pauses timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    // Tap the Start button
    await tester.tap(find.text('Start'));
    await tester.pump(); // Pump to trigger the timer start

    // Verify the button text changes to Pause
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Start'), findsNothing);

    // Wait for a few seconds to see if the time changes (optional, might make test flaky)
    // await tester.pump(const Duration(seconds: 2));
    // expect(find.text('24:58'), findsOneWidget); // Adjust expected time

    // Tap the Pause button
    await tester.tap(find.text('Pause'));
    await tester.pump(); // Pump to trigger the timer pause

    // Verify the button text changes back to Start
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
  });

  testWidgets('PomodoroTab resets timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    // Tap the Start button and wait a bit
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 5)); // Let timer run for 5 seconds

    // Tap the Reset button
    await tester.tap(find.text('Reset'));
    await tester.pump(); // Pump to trigger the timer reset

    // Verify the time resets to the initial work time
    expect(find.text('25:00'), findsOneWidget); // Adjust based on initial work time
    expect(find.text('Start'), findsOneWidget); // Verify button is Start again
  });

  testWidgets('PomodoroTab settings dialog opens and saves', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    // Tap the Set Settings button
    await tester.tap(find.text('Set Settings'));
    await tester.pumpAndSettle(); // Wait for the dialog to open

    // Verify the dialog title is displayed
    expect(find.text('Set Pomodoro Settings'), findsOneWidget);

    // Enter new values into the text fields
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(0), '30'); // Work Time
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(1), '10'); // Break Time

    // Tap the Save button
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(); // Wait for the dialog to close

    // Verify the displayed work and break times are updated
    expect(find.text('Work Time: 30 minutes'), findsOneWidget);
    expect(find.text('Break Time: 10 minutes'), findsOneWidget);
  });

   testWidgets('PomodoroTab settings dialog input validation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    // Tap the Set Settings button
    await tester.tap(find.text('Set Settings'));
    await tester.pumpAndSettle(); // Wait for the dialog to open

    // Enter invalid values
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(0), '-5'); // Invalid Work Time
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(1), 'abc'); // Invalid Break Time

    // Tap the Save button
    await tester.tap(find.text('Save'));
    await tester.pump(); // Pump to show validation errors

    // Verify validation error messages are displayed
    expect(find.text('Please enter a valid positive integer'), findsNWidgets(2));

    // Enter valid values
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(0), '25'); // Valid Work Time
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.keyboardType == TextInputType.number).at(1), '5'); // Valid Break Time

    // Tap the Save button again
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(); // Wait for the dialog to close

    // Verify the dialog is closed and settings are updated
    expect(find.text('Set Pomodoro Settings'), findsNothing);
    expect(find.text('Work Time: 25 minutes'), findsOneWidget);
    expect(find.text('Break Time: 5 minutes'), findsOneWidget);
  });
}