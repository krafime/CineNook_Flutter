import 'package:bloc/bloc.dart';
import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:equatable/equatable.dart';

part 'upcoming_movies_event.dart';
part 'upcoming_movies_state.dart';

class UpcomingMoviesBloc
    extends Bloc<UpcomingMoviesEvent, UpcomingMoviesState> {
  final Api api;

  UpcomingMoviesBloc({required this.api}) : super(UpcomingMoviesInitial()) {
    on<LoadUpcomingMovies>((event, emit) async {
      try {
        emit(UpcomingMoviesLoading());
        final movies = await api.getUpcomingMovies();
        emit(UpcomingMoviesLoaded(movies));
      } catch (e) {
        emit(UpcomingMoviesError(e.toString()));
      }
    });
  }
}
