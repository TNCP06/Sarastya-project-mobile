import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/project_detail_provider.dart';
import 'providers/project_provider.dart';
import 'router/app_router.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/project_service.dart';
import 'services/task_service.dart';
import 'services/token_storage.dart';

void main() {
  runApp(const ProjekTaskApp());
}

class ProjekTaskApp extends StatefulWidget {
  const ProjekTaskApp({super.key});

  @override
  State<ProjekTaskApp> createState() => _ProjekTaskAppState();
}

class _ProjekTaskAppState extends State<ProjekTaskApp> {
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final AuthProvider _authProvider;
  late final ProjectService _projectService;
  late final ProjectProvider _projectProvider;
  late final TaskService _taskService;
  late final ProjectDetailProvider _projectDetailProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Compose the dependency graph once for the app's lifetime.
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(_tokenStorage);
    _authService = AuthService(_apiClient);
    _authProvider = AuthProvider(_authService, _tokenStorage, _apiClient);
    _projectService = ProjectService(_apiClient);
    _projectProvider = ProjectProvider(_projectService);
    _taskService = TaskService(_apiClient);
    _projectDetailProvider =
        ProjectDetailProvider(_projectService, _taskService);
    _router = createRouter(_authProvider);

    // Validate any stored session, then let the router redirect accordingly.
    _authProvider.bootstrap();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _projectProvider.dispose();
    _projectDetailProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: _projectProvider),
        ChangeNotifierProvider<ProjectDetailProvider>.value(
            value: _projectDetailProvider),
      ],
      child: MaterialApp.router(
        title: 'ProjekTask',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
