import 'package:flutter/material.dart';

/// Shown while [AuthProvider.bootstrap] decides whether a valid session exists.
/// The router redirects away from here as soon as the status is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rounded, size: 72),
            SizedBox(height: 16),
            Text('ProjekTask', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
