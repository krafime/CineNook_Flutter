import 'package:equatable/equatable.dart';
import 'package:cinenook/models/movie_response.dart';

abstract class SimilarMoviesState extends Equatable {
  const SimilarMoviesState();

  @override
  List<Object?> get props => [];
}

class SimilarMoviesInitial extends SimilarMoviesState {}

class SimilarMoviesLoading extends SimilarMoviesState {}

class SimilarMoviesLoaded extends SimilarMoviesState {
  final List<Movie> movies;

  const SimilarMoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class SimilarMoviesError extends SimilarMoviesState {
  final String message;

  const SimilarMoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
