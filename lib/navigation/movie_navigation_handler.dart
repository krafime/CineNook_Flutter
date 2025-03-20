import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieNavigationHandler {
  static Future<void> navigateToMovieDetails(
    BuildContext context,
    int movieId, {
    String? searchQuery,
  }) async {
    // Get the current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Check if we're already on a detail screen
    final bool isDetailScreen = currentRoute == '/details' ||
        currentRoute?.startsWith('/details/') == true;

    if (isDetailScreen) {
      // Navigate within detail screens
      await Navigator.of(context).pushReplacementNamed('/details/$movieId');
    } else {
      // Navigate from home/other screens to detail screen
      await Navigator.of(context).pushNamed('/details/$movieId');
    }

    // When returning from detail screen, restore search if needed
    if (searchQuery != null && context.mounted) {
      context.read<MoviesBloc>().add(SearchMovies(searchQuery));
    }
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  static void goBack(BuildContext context, {bool fromDetailScreen = false}) {
    if (fromDetailScreen) {
      navigateToHome(context);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      navigateToHome(context);
    }
  }
}
