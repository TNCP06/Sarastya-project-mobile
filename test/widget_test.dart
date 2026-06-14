// Basic smoke test: the app boots and shows the splash screen while the
// session is being checked.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projektask/main.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (tester) async {
    await tester.pumpWidget(const ProjekTaskApp());

    // First frame: the splash screen with the app name and a spinner.
    expect(find.text('ProjekTask'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
