part of 'upcoming_movies_bloc.dart';

abstract class UpcomingMoviesState extends Equatable {
  const UpcomingMoviesState();

  @override
  List<Object> get props => [];
}

class UpcomingMoviesInitial extends UpcomingMoviesState {}

class UpcomingMoviesLoading extends UpcomingMoviesState {}

class UpcomingMoviesLoaded extends UpcomingMoviesState {
  final List<Movie> movies;

  const UpcomingMoviesLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class UpcomingMoviesError extends UpcomingMoviesState {
  final String message;

  const UpcomingMoviesError(this.message);

  @override
  List<Object> get props => [message];
}
