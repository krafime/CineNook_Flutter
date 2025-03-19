import 'package:equatable/equatable.dart';

abstract class SimilarMoviesEvent extends Equatable {
  const SimilarMoviesEvent();

  @override
  List<Object> get props => [];
}

class LoadSimilarMovies extends SimilarMoviesEvent {
  final int movieId;

  const LoadSimilarMovies(this.movieId);

  @override
  List<Object> get props => [movieId];
}
