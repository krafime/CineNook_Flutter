import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:get/get.dart';
import 'dart:async';

class MovieController extends GetxController {
  final Api api;

  // Separate loading indicators for different operations
  var isLoadingDetails = false.obs;
  var isLoadingPopular = false.obs;
  var isLoadingNowPlaying = false.obs;
  var isLoadingUpcoming = false.obs;
  var isLoadingSearch = false.obs;
  var isLoadingSimilar = false.obs;
  var isLoadingMore = false.obs; // Loading indicator for pagination

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

  // Pagination support
  var currentSearchPage = 1.obs;
  var hasMoreSearchResults = true.obs;

  // Search cache
  final Map<String, List<Movie>> _searchCache = {};

  // Debouncer for search
  Timer? _searchDebouncer;

  MovieController({required this.api});

  // Helper method to handle common fetch pattern and reduce code duplication
  Future<List<Movie>> _fetchMovies(
    Future<List<Movie>> Function() apiCall,
    RxBool loadingFlag,
    String errorPrefix,
  ) async {
    loadingFlag.value = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final movies = await apiCall();
      return movies;
    } catch (e) {
      errorMessage.value = '$errorPrefix: ${e.toString()}';
      return [];
    } finally {
      loadingFlag.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getPopularMovies() async {
    final movies = await _fetchMovies(
      api.getPopularMovies,
      isLoadingPopular,
      'Failed to load popular movies',
    );
    popularMovies.assignAll(movies);
  }

  Future<void> getNowPlayingMovies() async {
    final movies = await _fetchMovies(
      api.getNowPlayingMovies,
      isLoadingNowPlaying,
      'Failed to load now playing movies',
    );
    nowPlayingMovies.assignAll(movies);
  }

  Future<void> getUpcomingMovies() async {
    final movies = await _fetchMovies(
      api.getUpcomingMovies,
      isLoadingUpcoming,
      'Failed to load upcoming movies',
    );
    upcomingMovies.assignAll(movies);
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

  Future<void> searchMovies(String query, {bool useCache = true}) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    // Check cache first if enabled
    if (useCache && _searchCache.containsKey(query)) {
      searchResults.assignAll(_searchCache[query]!);
      return;
    }

    isLoadingSearch.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    currentSearchPage.value = 1;
    hasMoreSearchResults.value = true;

    try {
      final movies =
          await api.searchMovies(query, page: currentSearchPage.value);
      searchResults.assignAll(movies);

      // Cache results
      _searchCache[query] = List.from(movies);

      // Check if we can load more (assuming API returns 20 items per page)
      hasMoreSearchResults.value = movies.length >= 20;
    } catch (e) {
      errorMessage.value = 'Failed to search movies: ${e.toString()}';
    } finally {
      isLoadingSearch.value = false;
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSearchResults(String query) async {
    if (query.isEmpty || isLoadingMore.value || !hasMoreSearchResults.value) {
      return;
    }

    isLoadingMore.value = true;
    errorMessage.value = '';

    try {
      currentSearchPage.value++;
      final movies =
          await api.searchMovies(query, page: currentSearchPage.value);

      if (movies.isNotEmpty) {
        searchResults.addAll(movies);
        hasMoreSearchResults.value = movies.length >= 20;
      } else {
        hasMoreSearchResults.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load more results: ${e.toString()}';
      // Jika gagal, kembalikan halaman ke sebelumnya
      if (currentSearchPage.value > 1) {
        currentSearchPage.value--;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Method to perform search with debounce
  void searchMoviesWithDebounce(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      searchMovies(query);
    });
  }

  void cancelSearch() {
    _searchDebouncer?.cancel();
    isLoadingSearch.value = false;
    isLoading.value = false;
  }

  Future<void> getSimilarMovies(int movieId) async {
    final movies = await _fetchMovies(
      () => api.getSimilarMovies(movieId),
      isLoadingSimilar,
      'Failed to load similar movies',
    );
    similarMovies.assignAll(movies);
  }

  // Method untuk membersihkan hasil pencarian
  void clearSearchResults() {
    searchResults.clear();
    currentSearchPage.value = 1;
    hasMoreSearchResults.value = true;
    isLoadingSearch.value = false;
    isLoadingMore.value = false;
    cancelSearch();
    errorMessage.value = '';
  }
}
