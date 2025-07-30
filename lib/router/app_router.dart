import 'package:cinenook/controllers/auth_controller.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:cinenook/screens/home_screen.dart';
import 'package:cinenook/screens/login_screen.dart';
import 'package:cinenook/screens/splash_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthController authController;

  AppRouter(this.authController);

  late final GoRouter router = _createRouter();

  GoRouter _createRouter() {
    // Untuk web, langsung mulai dari halaman login/home (skip splash screen)
    final String initialLocation =
        kIsWeb ? (authController.isLoggedIn ? '/' : '/login') : '/splash';

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: GetXRouterRefreshStream(authController),
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          redirect: (context, state) => _checkAuth(context, state),
        ),
        GoRoute(
          path: '/details/:id',
          name: 'details',
          builder: (context, state) {
            final idParam = state.pathParameters['id'];
            final id = int.tryParse(idParam ?? '0') ?? 0;
            return DetailScreen(
              key: ValueKey('detail_screen_$id'),
              id: id,
            );
          },
          redirect: (context, state) => _checkAuth(context, state),
        ),
      ],
      // Use a non-reactive approach for redirects
      redirect: (context, state) {
        final loggedIn = authController.isLoggedIn;
        final loggingIn = state.matchedLocation == '/login';
        final splashing = state.matchedLocation == '/splash';

        // Web specific handling - skip splash screen
        if (kIsWeb && splashing) {
          return loggedIn ? '/' : '/login';
        }

        // Don't redirect away from splash screen initially on mobile
        if (splashing && !kIsWeb) return null;

        // If not logged in and not heading to login, redirect to login
        if (!loggedIn && !loggingIn) return '/login';

        // If logged in and heading to login, redirect to home
        if (loggedIn && loggingIn) return '/';

        // No redirection needed
        return null;
      },
      // Add error builder
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }

  String? _checkAuth(BuildContext context, GoRouterState state) {
    final isLoggedIn = authController.isLoggedIn;
    if (!isLoggedIn) {
      return '/login';
    }
    return null;
  }
}

// Helper class to convert GetX controller to Listenable for GoRouter
class GetXRouterRefreshStream extends ChangeNotifier {
  final AuthController controller;
  late Worker _worker;
  bool _isNotifying = false;

  GetXRouterRefreshStream(this.controller) {
    // Listen for changes to the currentUser and notify router to refresh
    _worker = ever(controller.currentUser, (_) {
      // Use a microtask to avoid rebuilding during build cycle
      if (!_isNotifying) {
        _isNotifying = true;
        Future.microtask(() {
          notifyListeners();
          _isNotifying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }
}
