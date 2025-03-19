import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';

class MovieRepository {
  final Api api;

  MovieRepository({required this.api});

  Future<List<Movie>> getPopularMovies() async {
    try {
      return await api.getPopularMovies();
    } catch (e) {
      throw Exception('Failed to load popular movies: ${e.toString()}');
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      return await api.getNowPlayingMovies();
    } catch (e) {
      throw Exception('Failed to load now playing movies: ${e.toString()}');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    try {
      return await api.getUpcomingMovies();
    } catch (e) {
      throw Exception('Failed to load upcoming movies: ${e.toString()}');
    }
  }

  Future<MovieDetail> getMovieDetails(int id) async {
    try {
      return await api.getDetailMovie(id);
    } catch (e) {
      throw Exception('Failed to load movie details: ${e.toString()}');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      return await api.searchMovies(query);
    } catch (e) {
      throw Exception('Failed to search movies: ${e.toString()}');
    }
  }

  Future<List<Movie>> getSimilarMovies(int id) async {
    try {
      return await api.getSimilarMovies(id);
    } catch (e) {
      throw Exception('Failed to load similar movies: ${e.toString()}');
    }
  }
}
