import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders CustomNavBar with Home, Camera, and Ingredients', (
    tester,
  ) async {
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavBar(
            selectedIndex: 2,
            onDestinationSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

    await tester.tap(find.text('Home'));
    expect(selected, 0);

    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    expect(selected, 1);

    await tester.tap(find.text('Ingredients'));
    expect(selected, 2);
  });

  testWidgets('custom onCameraTap callback is called when provided', (
    tester,
  ) async {
    var cameraTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onCameraTap: () => cameraTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    expect(cameraTapped, isTrue);
  });
}
