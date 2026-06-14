import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'config/api_config.dart';

void main() {
  runApp(const ProjekTaskApp());
}

class ProjekTaskApp extends StatelessWidget {
  const ProjekTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjekTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
        useMaterial3: true,
      ),
      // Checkpoint 1: a temporary connectivity screen that proves the EC2
      // backend is reachable over cleartext HTTP. Replaced by the real
      // splash/auth flow in Checkpoint 2.
      home: const ConnectionTestScreen(),
    );
  }
}

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

enum _Status { loading, success, error }

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  _Status _status = _Status.loading;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _status = _Status.loading;
      _message = '';
    });
    try {
      final res = await _dio.get<dynamic>(ApiConfig.healthUrl);
      setState(() {
        _status = _Status.success;
        _message = 'Health: ${res.data}';
      });
    } catch (e) {
      setState(() {
        _status = _Status.error;
        _message =
            e is DioException ? (e.message ?? e.toString()) : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProjekTask · Connection Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatus(),
              const SizedBox(height: 16),
              Text(
                'Target: ${ApiConfig.healthUrl}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_message, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              if (_status != _Status.loading)
                FilledButton.icon(
                  onPressed: _checkHealth,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    switch (_status) {
      case _Status.loading:
        return const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Contacting backend...'),
          ],
        );
      case _Status.success:
        return const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 8),
            Text('Connected', style: TextStyle(fontSize: 20)),
          ],
        );
      case _Status.error:
        return const Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 8),
            Text('Connection failed', style: TextStyle(fontSize: 20)),
          ],
        );
    }
  }
}
