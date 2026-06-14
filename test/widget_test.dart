// Basic smoke test for the ProjekTask app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projektask/main.dart';

void main() {
  testWidgets('App boots and shows the connection test screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProjekTaskApp());

    // The connection screen starts in a loading state contacting the backend.
    expect(find.text('Contacting backend...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
