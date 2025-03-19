import 'package:bloc/bloc.dart';
import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:equatable/equatable.dart';

part 'popular_movies_event.dart';
part 'popular_movies_state.dart';

class PopularMoviesBloc extends Bloc<PopularMoviesEvent, PopularMoviesState> {
  final Api api;

  PopularMoviesBloc({required this.api}) : super(PopularMoviesInitial()) {
    on<LoadPopularMovies>((event, emit) async {
      try {
        emit(PopularMoviesLoading());
        final movies = await api.getPopularMovies();
        emit(PopularMoviesLoaded(movies));
      } catch (e) {
        emit(PopularMoviesError(e.toString()));
      }
    });
  }
}
