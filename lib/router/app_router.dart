import 'dart:async'; // Add this import for StreamSubscription
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:cinenook/screens/home_screen.dart';
import 'package:cinenook/screens/login_screen.dart';
import 'package:cinenook/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
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
          // Parse the ID safely with better error handling
          final idParam = state.pathParameters['id'];
          final id = int.tryParse(idParam ?? '0') ?? 0;

          // Log navigation to help debug
          debugPrint('Navigating to movie details: $id');

          // Create the detail screen with a unique key based on the movie id
          // This ensures Flutter creates a new widget when id changes
          return DetailScreen(
            key: ValueKey('detail_screen_$id'),
            id: id,
          );
        },
        redirect: (context, state) => _checkAuth(context, state),
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is Authenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';

      // If the user is not logged in and not headed to login or splash, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isSplash) {
        return '/login';
      }

      // If user is logged in and headed to login, redirect to home
      if (isLoggedIn && isGoingToLogin) {
        return '/';
      }

      // If user is on splash and the auth state is determined, redirect accordingly
      if (isSplash && authState is! AuthInitial && authState is! AuthLoading) {
        return isLoggedIn ? '/' : '/login';
      }

      return null;
    },
  );

  String? _checkAuth(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    if (authState is! Authenticated) {
      return '/login';
    }
    return null;
  }
}

// Helper class to convert BLoC stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
