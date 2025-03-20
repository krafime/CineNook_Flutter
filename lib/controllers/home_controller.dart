import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_event.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_event.dart';
import 'package:cinenook/blocs/popular_movies/popular_movies_bloc.dart'
    as popular;
import 'package:cinenook/blocs/now_playing_movies/now_playing_movies_bloc.dart'
    as now_playing;
import 'package:cinenook/blocs/upcoming_movies/upcoming_movies_bloc.dart'
    as upcoming;

class HomeController {
  final BuildContext context;
  DateTime? lastPressed;

  HomeController(this.context);

  void loadMovies() {
    context.read<popular.PopularMoviesBloc>().add(popular.LoadPopularMovies());
    context
        .read<now_playing.NowPlayingMoviesBloc>()
        .add(now_playing.LoadNowPlayingMovies());
    context
        .read<upcoming.UpcomingMoviesBloc>()
        .add(upcoming.LoadUpcomingMovies());
  }

  void signOut() {
    context.read<AuthBloc>().add(LoggedOut());
  }

  void performSearch(String query) {
    if (query.isNotEmpty) {
      context.read<MoviesBloc>().add(SearchMovies(query));
    }
  }

  void handleBackPress(bool isSearching, Function exitSearchMode) {
    final now = DateTime.now();

    if (isSearching) {
      exitSearchMode();
      return;
    }

    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
      Navigator.of(context).pop();
    }
  }
}
