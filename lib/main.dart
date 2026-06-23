import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/drive_screen.dart';
import 'screens/search_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/video_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DriveService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/drive', builder: (context, state) => DriveScreen()),
      GoRoute(path: '/search', builder: (context, state) => SearchScreen()),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) =>
            ItemDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) =>
            VideoPlayerScreen(id: state.pathParameters['id']!),
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sarastya Drive',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
