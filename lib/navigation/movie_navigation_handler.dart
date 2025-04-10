import 'package:cinenook/controllers/movie_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class MovieNavigationHandler {
  // Track the current movie ID to detect navigation to the same movie
  static int? _currentMovieId;

  // Track navigation stack to handle back button properly
  static final List<String> _navigationStack = ['/'];

  static Future<void> navigateToMovieDetails(
    BuildContext context,
    int movieId, {
    String? searchQuery,
  }) async {
    // Get the current route
    final String currentPath = GoRouterState.of(context).matchedLocation;

    // Check if we're already on a detail screen
    final bool isDetailScreen = currentPath.startsWith('/details/');

    // Save current path to stack if it's not a detail screen
    if (!isDetailScreen && !_navigationStack.contains(currentPath)) {
      _navigationStack.add(currentPath);
    }

    // If we're on the same movie already, do nothing
    if (_currentMovieId == movieId && isDetailScreen) {
      return;
    }

    try {
      // Update current movie ID
      _currentMovieId = movieId;

      // Get the movie controller
      final movieController = Get.find<MovieController>();

      // Set a flag to indicate we're navigating to avoid UI flicker
      movieController.isNavigatingToMovie.value = true;

      // Clear any existing error message that might be shown
      movieController.errorMessage.value = '';

      // Handle the navigation first - don't wait for data loading
      // This ensures the UI transition is smooth
      if (isDetailScreen) {
        // If already on detail screen, replace the current route
        context.goNamed('details', pathParameters: {'id': movieId.toString()});
      } else {
        // Navigate from home/search screens to detail screen
        context
            .pushNamed('details', pathParameters: {'id': movieId.toString()});
      }

      // Now start loading the data after navigation has occurred
      // Use a small delay to ensure navigation has completed
      await Future.delayed(const Duration(milliseconds: 50));

      // Load movie details if we don't already have them
      if (movieController.movieDetail.value?.id != movieId) {
        movieController.getMovieDetails(movieId);
      }

      // Start loading similar movies after navigation
      movieController.getSimilarMovies(movieId);

      // Reset navigation flag after a short delay
      await Future.delayed(const Duration(milliseconds: 300));
      movieController.isNavigatingToMovie.value = false;

      // When returning from detail screen, restore search if needed
      if (searchQuery != null && context.mounted) {
        movieController.searchMovies(searchQuery);
      }
    } catch (e) {
      // Fallback navigation method if the named route approach fails
      context.go('/details/$movieId');
    }
  }

  static void navigateToHome(BuildContext context) {
    // Clear current movie ID when going home
    _currentMovieId = null;
    // Clear navigation stack except for home
    _navigationStack.clear();
    _navigationStack.add('/');
    context.goNamed('home');
  }

  static void goBack(BuildContext context, {bool fromDetailScreen = false}) {
    if (fromDetailScreen) {
      // Get previous route from stack
      String previousRoute =
          _navigationStack.isNotEmpty ? _navigationStack.last : '/';

      _currentMovieId = null;

      // If we were in search, go back to search, otherwise go home
      if (previousRoute.startsWith('/') && context.canPop()) {
        context.pop();
      } else {
        navigateToHome(context);
      }
    } else if (context.canPop()) {
      // Normal back button behavior - use Navigator pop
      _currentMovieId = null;
      if (_navigationStack.isNotEmpty) {
        _navigationStack.removeLast();
      }
      context.pop();
    } else {
      // Can't pop, go to home
      navigateToHome(context);
    }
  }
}
