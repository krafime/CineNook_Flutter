import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/api/api.dart';
import 'similar_movies_event.dart';
import 'similar_movies_state.dart';

class SimilarMoviesBloc extends Bloc<SimilarMoviesEvent, SimilarMoviesState> {
  final Api api;

  SimilarMoviesBloc({required this.api}) : super(SimilarMoviesInitial()) {
    on<LoadSimilarMovies>(_onLoadSimilarMovies);
  }

  void _onLoadSimilarMovies(
      LoadSimilarMovies event, Emitter<SimilarMoviesState> emit) async {
    emit(SimilarMoviesLoading());
    try {
      final movies = await api.getSimilarMovies(event.movieId);
      emit(SimilarMoviesLoaded(movies));
    } catch (e) {
      emit(
          SimilarMoviesError('Failed to load similar movies: ${e.toString()}'));
    }
  }
}
