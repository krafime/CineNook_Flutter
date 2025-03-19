import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/api/api.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final Api api;

  MoviesBloc({required this.api}) : super(MoviesInitial()) {
    on<LoadPopularMovies>(_onLoadPopularMovies);
    on<LoadNowPlayingMovies>(_onLoadNowPlayingMovies);
    on<LoadUpcomingMovies>(_onLoadUpcomingMovies);
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<SearchMovies>(_onSearchMovies);
  }

  void _onLoadPopularMovies(
      LoadPopularMovies event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final movies = await api.getPopularMovies();
      emit(PopularMoviesLoaded(movies));
    } catch (e) {
      emit(MoviesError('Failed to load popular movies: ${e.toString()}'));
    }
  }

  void _onLoadNowPlayingMovies(
      LoadNowPlayingMovies event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final movies = await api.getNowPlayingMovies();
      emit(NowPlayingMoviesLoaded(movies));
    } catch (e) {
      emit(MoviesError('Failed to load now playing movies: ${e.toString()}'));
    }
  }

  void _onLoadUpcomingMovies(
      LoadUpcomingMovies event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final movies = await api.getUpcomingMovies();
      emit(UpcomingMoviesLoaded(movies));
    } catch (e) {
      emit(MoviesError('Failed to load upcoming movies: ${e.toString()}'));
    }
  }

  void _onLoadMovieDetails(
      LoadMovieDetails event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final movieDetail = await api.getDetailMovie(event.movieId);
      emit(MovieDetailsLoaded(movieDetail));
    } catch (e) {
      emit(MoviesError('Failed to load movie details: ${e.toString()}'));
    }
  }

  void _onSearchMovies(SearchMovies event, Emitter<MoviesState> emit) async {
    emit(MoviesLoading());
    try {
      final movies = await api.searchMovies(event.query);
      emit(SearchResultsLoaded(movies));
    } catch (e) {
      emit(MoviesError('Failed to search movies: ${e.toString()}'));
    }
  }
}
