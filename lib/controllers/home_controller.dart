import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:cinenook/controllers/movie_controller.dart';

class HomeController extends GetxController {
  // Observable for back press handling
  Rx<DateTime?> lastPressed = Rx<DateTime?>(null);

  // Get other controllers via dependency injection
  final AuthController _authController = Get.find<AuthController>();
  final MovieController _movieController = Get.find<MovieController>();

  void loadMovies() {
    _movieController.getPopularMovies();
    _movieController.getNowPlayingMovies();
    _movieController.getUpcomingMovies();
  }

  void signOut() {
    if (_authController.isLoggedIn) {
      _authController.signOut();
    }
  }

  void performSearch(String query) {
    if (query.isNotEmpty) {
      _movieController.searchMovies(query);
    }
  }

  void handleBackPress(
      BuildContext context, bool isSearching, Function exitSearchMode) {
    final now = DateTime.now();

    if (isSearching) {
      exitSearchMode();
      return;
    }

    if (lastPressed.value == null ||
        now.difference(lastPressed.value!) > const Duration(seconds: 2)) {
      lastPressed.value = now;

      // Show snackbar using microtask to avoid build phase issues
      Future.microtask(() {
        if (context.mounted) {
          // Delay SnackBar presentation slightly
          Future.delayed(const Duration(milliseconds: 50), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Press back again to exit'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        }
      });
    } else {
      // Perform navigation using microtask to avoid build phase issues
      Future.microtask(() {
        SystemNavigator.pop();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
