import 'package:bloc/bloc.dart';
import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:equatable/equatable.dart';

part 'now_playing_movies_event.dart';
part 'now_playing_movies_state.dart';

class NowPlayingMoviesBloc
    extends Bloc<NowPlayingMoviesEvent, NowPlayingMoviesState> {
  final Api api;

  NowPlayingMoviesBloc({required this.api}) : super(NowPlayingMoviesInitial()) {
    on<LoadNowPlayingMovies>((event, emit) async {
      try {
        emit(NowPlayingMoviesLoading());
        final movies = await api.getNowPlayingMovies();
        emit(NowPlayingMoviesLoaded(movies));
      } catch (e) {
        emit(NowPlayingMoviesError(e.toString()));
      }
    });
  }
}
