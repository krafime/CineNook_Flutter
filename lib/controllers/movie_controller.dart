import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:get/get.dart';

class MovieController extends GetxController {
  final Api api;

  // Separate loading indicators for different operations
  var isLoadingDetails = false.obs;
  var isLoadingPopular = false.obs;
  var isLoadingNowPlaying = false.obs;
  var isLoadingUpcoming = false.obs;
  var isLoadingSearch = false.obs;
  var isLoadingSimilar = false.obs;

  // General loading state (used for backward compatibility)
  var isLoading = false.obs;

  var errorMessage = ''.obs;

  // Observable lists for different movie categories
  var popularMovies = <Movie>[].obs;
  var nowPlayingMovies = <Movie>[].obs;
  var upcomingMovies = <Movie>[].obs;
  var searchResults = <Movie>[].obs;
  var similarMovies = <Movie>[].obs;

  // Observable for movie details
  var movieDetail = Rxn<MovieDetail>();

  // Flag to track if we're currently navigating to a movie detail screen
  final RxBool isNavigatingToMovie = false.obs;

  MovieController({required this.api});

  Future<void> getPopularMovies() async {
    isLoadingPopular.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final movies = await api.getPopularMovies();
      popularMovies.assignAll(movies);
    } catch (e) {
      errorMessage.value = 'Failed to load popular movies: ${e.toString()}';
    } finally {
      isLoadingPopular.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getNowPlayingMovies() async {
    isLoadingNowPlaying.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final movies = await api.getNowPlayingMovies();
      nowPlayingMovies.assignAll(movies);
    } catch (e) {
      errorMessage.value = 'Failed to load now playing movies: ${e.toString()}';
    } finally {
      isLoadingNowPlaying.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getUpcomingMovies() async {
    isLoadingUpcoming.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final movies = await api.getUpcomingMovies();
      upcomingMovies.assignAll(movies);
    } catch (e) {
      errorMessage.value = 'Failed to load upcoming movies: ${e.toString()}';
    } finally {
      isLoadingUpcoming.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getMovieDetails(int id) async {
    if (isLoading.value && !isNavigatingToMovie.value) return;

    // If we already have this movie's details and are just navigating, don't reload
    if (movieDetail.value?.id == id && isNavigatingToMovie.value) {
      return;
    }

    isLoading.value = true;
    isLoadingDetails.value = true;
    errorMessage.value = '';

    try {
      final details = await api.getDetailMovie(id);
      movieDetail.value = details;
    } catch (e) {
      errorMessage.value = 'Failed to load movie details: ${e.toString()}';
    } finally {
      isLoadingDetails.value = false;
      isLoading.value = false;
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoadingSearch.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final movies = await api.searchMovies(query);
      searchResults.assignAll(movies);
    } catch (e) {
      errorMessage.value = 'Failed to search movies: ${e.toString()}';
    } finally {
      isLoadingSearch.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getSimilarMovies(int movieId) async {
    isLoadingSimilar.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final movies = await api.getSimilarMovies(movieId);
      similarMovies.assignAll(movies);
    } catch (e) {
      errorMessage.value = 'Failed to load similar movies: ${e.toString()}';
    } finally {
      isLoadingSimilar.value = false;
      isLoading.value = false;
    }
  }
}
