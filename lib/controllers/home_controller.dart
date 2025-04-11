import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:cinenook/controllers/movie_controller.dart';

class HomeController extends GetxController {
  // Observable for back press handling
  Rx<DateTime?> lastPressed = Rx<DateTime?>(null);

  // Get other controllers via dependency injection
  final AuthController _authController = Get.find<AuthController>();
  final MovieController _movieController = Get.find<MovieController>();

  // Observable to track if we're loading more results
  var isLoadingMore = false.obs;

  void loadMovies() {
    _movieController.getPopularMovies();
    _movieController.getNowPlayingMovies();
    _movieController.getUpcomingMovies();
  }

  void signOut() {
    if (_authController.isLoggedIn) {
      _authController.signOut();
    }
  }

  void performSearch(String query) {
    if (query.isNotEmpty) {
      _movieController.searchMovies(query);
    }
  }

  // New method for debounced search
  void performDebouncedSearch(String query) {
    if (query.isNotEmpty) {
      _movieController.searchMoviesWithDebounce(query);
    } else {
      // Clear results if search is empty
      _movieController.cancelSearch();
    }
  }

  // Method to load more search results for pagination
  Future<void> loadMoreSearchResults(String query) async {
    if (query.isEmpty ||
        isLoadingMore.value ||
        !_movieController.hasMoreSearchResults.value) {
      return Future.value(); // Return completed Future if conditions not met
    }

    isLoadingMore.value = true;
    try {
      await _movieController.loadMoreSearchResults(query);
      return Future.value(); // Explicitly return completed Future
    } catch (e) {
      // Handle error silently
      return Future.value();
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Method untuk mengaktifkan mode pencarian dan restore query
  void activateSearchMode(String query) {
    // Perlu mengambil referensi controller pencarian dari home screen
    // Biasanya ini dipanggil setelah navigasi ke Home selesai

    // Tunggu sampai homeScreen mounted dan widget tree sudah dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Aktifkan mode pencarian di home screen
      isSearchModeActive.value = true;

      // Restore query pencarian terakhir
      if (searchController != null) {
        searchController!.text = query;

        // Lakukan pencarian dengan query tersebut
        performSearch(query);
      }
    });
  }

  // Controller dan state untuk search mode
  TextEditingController? searchController;
  FocusNode? searchFocusNode;
  var isSearchModeActive = false.obs;

  // Method untuk melakukan setup controller search
  void setupSearchController(
      TextEditingController controller, FocusNode focusNode) {
    searchController = controller;
    searchFocusNode = focusNode;
  }

  // Method untuk clear search controller ketika tidak digunakan
  void clearSearchControllers() {
    searchController = null;
    searchFocusNode = null;
  }

  void handleBackPress(
      BuildContext context, bool isSearching, Function exitSearchMode) {
    final now = DateTime.now();

    if (isSearching) {
      exitSearchMode();
      return;
    }

    if (lastPressed.value == null) {
      // Show a toast message
      lastPressed.value = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        // Only reset if no second press happened
        if (lastPressed.value != null &&
            now.difference(lastPressed.value!) <= const Duration(seconds: 2)) {
          lastPressed.value = null;
        }
      });
    } else {
      // Second press within 2 seconds, exit the app
      SystemNavigator.pop();
    }
  }
}
