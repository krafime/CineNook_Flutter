import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MovieNavigationHandler {
  // Track the current movie ID to detect navigation to the same movie
  static int? _currentMovieId;

  static Future<void> navigateToMovieDetails(
    BuildContext context,
    int movieId, {
    String? searchQuery,
  }) async {
    // Get the current route
    final String currentPath = GoRouterState.of(context).matchedLocation;

    // Check if we're already on a detail screen
    final bool isDetailScreen = currentPath.startsWith('/details/');

    // If we're on the same movie already, do nothing
    if (_currentMovieId == movieId && isDetailScreen) {
      return;
    }

    // Update current movie ID
    _currentMovieId = movieId;

    try {
      // First load the movie details to ensure a smooth transition
      context.read<MoviesBloc>().add(LoadMovieDetails(movieId));

      if (isDetailScreen) {
        // If already on detail screen, replace the current route instead of pushing
        context.goNamed('details', pathParameters: {'id': movieId.toString()});
      } else {
        // Navigate from home/search screens to detail screen by pushing
        context
            .pushNamed('details', pathParameters: {'id': movieId.toString()});
      }

      // When returning from detail screen, restore search if needed
      if (searchQuery != null && context.mounted) {
        context.read<MoviesBloc>().add(SearchMovies(searchQuery));
      }
    } catch (e) {
      // Fallback navigation method if the named route approach fails
      context.go('/details/$movieId');
    }
  }

  static void navigateToHome(BuildContext context) {
    // Clear current movie ID when going home
    _currentMovieId = null;
    context.goNamed('home');
  }

  static void goBack(BuildContext context, {bool fromDetailScreen = false}) {
    if (fromDetailScreen) {
      navigateToHome(context);
    } else if (context.canPop()) {
      // Clear current movie ID when going back
      _currentMovieId = null;
      context.pop();
    } else {
      navigateToHome(context);
    }
  }
}
