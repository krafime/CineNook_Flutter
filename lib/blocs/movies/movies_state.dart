import 'package:equatable/equatable.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/models/movie_details.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class PopularMoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const PopularMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class NowPlayingMoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const NowPlayingMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class UpcomingMoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const UpcomingMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MovieDetailsLoaded extends MoviesState {
  final MovieDetail movie;

  const MovieDetailsLoaded(this.movie);

  @override
  List<Object?> get props => [movie];
}

class SearchResultsLoaded extends MoviesState {
  final List<Movie> movies;

  const SearchResultsLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
