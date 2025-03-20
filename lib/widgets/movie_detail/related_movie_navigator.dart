import 'package:flutter/material.dart';
import 'package:cinenook/navigation/movie_navigation_handler.dart';

@Deprecated('Use MovieNavigationHandler instead')
class RelatedMovieNavigator {
  static Future<void> navigateToMovie(BuildContext context, int movieId) async {
    // Delegate to the new handler
    return MovieNavigationHandler.navigateToMovieDetails(context, movieId);
  }
}
