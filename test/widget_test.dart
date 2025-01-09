// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:llp/main.dart';
import 'package:llp/screens/home_screen.dart';

void main() {

  testWidgets('Main screen contains a BottomNavigationBar with 4 items', (WidgetTester tester) async {
    // Use the shared provider setup from main.dart
    await tester.pumpWidget(
      buildAppWithProviders(
        child: MaterialApp(
          home: HomeScreen(), // Replace with your main screen widget
        ),
      ),
    );

    // Verify that the BottomNavigationBar exists in the widget tree
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Get the BottomNavigationBar widget
    final bottomNavBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );

    // Verify the BottomNavigationBar has exactly 4 items
    expect(bottomNavBar.items.length, 4);

    // Optionally, verify specific icons or labels in the BottomNavigationBar
    expect(bottomNavBar.items[0].label, 'Play'); // Adjust labels as per your app
    expect(bottomNavBar.items[1].label, 'Browse');
    expect(bottomNavBar.items[2].label, 'Flashcards');
    expect(bottomNavBar.items[3].label, 'Settings');
  });
}
