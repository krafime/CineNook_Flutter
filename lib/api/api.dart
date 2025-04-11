import 'dart:convert';
import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class Api {
  // Base URL for TMDB API
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Endpoint URLs for different movie categories
  static const String _popularUrl =
      '$_baseUrl/movie/popular?api_key=${Constants.apiKey}';
  static const String _nowPlayingUrl =
      '$_baseUrl/movie/now_playing?api_key=${Constants.apiKey}';
  static const String _upcomingMoviesUrl =
      '$_baseUrl/movie/upcoming?api_key=${Constants.apiKey}';

  static final Logger _logger = Logger('API');

  // Helper method to handle API requests and parse movie lists
  Future<List<Movie>> _getMovieList(String url, String errorMessage) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        _logger.severe(
            'API Error: $errorMessage with status code: ${response.statusCode}');
        _logger.severe('Response body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.severe('API Exception: $errorMessage: ${e.toString()}');
      throw Exception('$errorMessage: ${e.toString()}');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    return _getMovieList(_popularUrl, 'Failed to load popular movies');
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    return _getMovieList(_nowPlayingUrl, 'Failed to load now playing movies');
  }

  // Renamed from getUpcomingPlayingMovies to getUpcomingMovies to match event naming
  Future<List<Movie>> getUpcomingMovies() async {
    return _getMovieList(_upcomingMoviesUrl, 'Failed to load upcoming movies');
  }

  /// Fetches detailed information about a specific movie
  Future<MovieDetail> getDetailMovie(int id) async {
    try {
      final detailMovieUrl = '$_baseUrl/movie/$id?api_key=${Constants.apiKey}';
      final response = await http.get(Uri.parse(detailMovieUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MovieDetail.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: ${e.toString()}');
    }
  }

  /// Searches for movies based on a query string
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final searchUrl =
        '$_baseUrl/search/movie?api_key=${Constants.apiKey}&query=$query&page=$page';
    return _getMovieList(searchUrl, 'Failed to search movies');
  }

  /// Fetches movies similar to a specific movie
  Future<List<Movie>> getSimilarMovies(int id) async {
    final similarMoviesUrl =
        '$_baseUrl/movie/$id/similar?api_key=${Constants.apiKey}';
    return _getMovieList(similarMoviesUrl, 'Failed to load similar movies');
  }
}
