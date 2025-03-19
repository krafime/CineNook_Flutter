import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object> get props => [];
}

class LoadPopularMovies extends MoviesEvent {}

class LoadNowPlayingMovies extends MoviesEvent {}

class LoadUpcomingMovies extends MoviesEvent {}

class LoadMovieDetails extends MoviesEvent {
  final int movieId;

  const LoadMovieDetails(this.movieId);

  @override
  List<Object> get props => [movieId];
}

class SearchMovies extends MoviesEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object> get props => [query];
}
