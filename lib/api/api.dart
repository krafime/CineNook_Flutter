import 'dart:convert';
import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:http/http.dart' as http;

class Api {
  static const _popularUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=${Constants.apiKey}';
  static const _nowPlayingUrl =
      'https://api.themoviedb.org/3/movie/now_playing?api_key=${Constants.apiKey}';
  static const _upcomingMoviesUrl =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=${Constants.apiKey}';

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(Uri.parse(_popularUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(Uri.parse(_nowPlayingUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load playing movies');
    }
  }

  Future<List<Movie>> getUpcomingPlayingMovies() async {
    final response = await http.get(Uri.parse(_upcomingMoviesUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<MovieDetail> getDetailMovie(int id) async {
    final detailMovieUrl =
        'https://api.themoviedb.org/3/movie/$id?api_key=${Constants.apiKey}';
    final response = await http.get(Uri.parse(detailMovieUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return MovieDetail.fromJson(data);
    } else {
      throw Exception('Failed to load detail movie');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final searchUrl =
        'https://api.themoviedb.org/3/search/movie?api_key=${Constants.apiKey}&query=$query';
    final response = await http.get(Uri.parse(searchUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<Movie>> getSimilarMovies(int id) async {
    final similarMoviesUrl =
        'https://api.themoviedb.org/3/movie/$id/recommendations?api_key=${Constants.apiKey}';
    final response = await http.get(Uri.parse(similarMoviesUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load similar movies');
    }
  }
}
