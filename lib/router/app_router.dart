import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';

/// Builds the app router. Redirects are driven by [AuthProvider]:
///  - while the status is unknown  → stay on the splash screen
///  - unauthenticated              → forced to /login (or /register)
///  - authenticated               → kept inside the app (/home)
GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    // Re-evaluate redirects whenever the auth state changes.
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
    ],
    redirect: (context, state) {
      final status = auth.status;
      final location = state.matchedLocation;

      // Still bootstrapping: hold on the splash screen.
      if (status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }

      final onAuthScreen = location == '/login' || location == '/register';

      if (status == AuthStatus.unauthenticated) {
        // Allow the login and register screens; redirect everything else.
        return onAuthScreen ? null : '/login';
      }

      // Authenticated: keep the user out of the splash/auth screens.
      if (location == '/splash' || onAuthScreen) {
        return '/projects';
      }
      return null;
    },
  );
}
