import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cupertino/flutter_cupertino.dart';

void main() {
  testWidgets('CupertinoAdaptiveMenu builds correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CupertinoAdaptiveMenu(
            items: const [CupertinoAdaptiveMenuItem(label: 'Action 1')],
            child: const Text('Menu'),
          ),
        ),
      ),
    );

    expect(find.text('Menu'), findsOneWidget);
    expect(find.byType(CupertinoAdaptiveMenu), findsOneWidget);
    // Platform views might not render fully in standard widget tests without mocked platform,
    // but the widget tree construction matches.
  });
}
