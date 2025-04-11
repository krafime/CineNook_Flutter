import 'package:cinenook/controllers/home_controller.dart';
import 'package:cinenook/controllers/movie_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class MovieNavigationHandler {
  // Flag untuk menandai apakah sedang melihat similar movie
  static bool _viewingSimilarMovie = false;

  // ID film original yang pertama kali dibuka
  static int? _originalMovieId;

  // Simpan ID movie yang sedang aktif untuk mencegah reload yang tidak perlu
  static int? _currentMovieId;

  // Simpan state asal dari halaman mana user masuk ke detail
  static String _sourceScreen = 'home'; // default: 'home', 'search'

  // Simpan query pencarian jika user datang dari halaman search
  static String? _lastSearchQuery;

  /// Navigasi ke detail film
  static Future<void> navigateToMovieDetails(
    BuildContext context,
    int movieId, {
    String? searchQuery,
    bool fromSimilarMovies = false,
  }) async {
    // Jika sudah di film yang sama, tidak perlu navigasi
    if (_currentMovieId == movieId) return;

    try {
      // Jika ini adalah navigasi dari similar movies
      if (fromSimilarMovies) {
        // Jika belum dalam mode similar movies, simpan ID film original
        if (!_viewingSimilarMovie) {
          _originalMovieId = _currentMovieId;
          _viewingSimilarMovie = true;
        }
      }
      // Jika navigasi normal (bukan dari similar), reset tracking similar movies
      else {
        _viewingSimilarMovie = false;
        _originalMovieId = null;

        // Simpan state asal user (home atau search)
        final currentPath = GoRouterState.of(context).matchedLocation;
        if (currentPath.startsWith('/search')) {
          _sourceScreen = 'search';
          _lastSearchQuery = searchQuery;
        } else {
          _sourceScreen = 'home';
        }
      }

      // Update current movie ID
      _currentMovieId = movieId;

      // Dapatkan controller
      final movieController = Get.find<MovieController>();

      // Set flag untuk mencegah flicker UI selama navigasi
      movieController.isNavigatingToMovie.value = true;

      // Reset pesan error
      movieController.errorMessage.value = '';

      // Navigasi ke halaman detail
      context.goNamed('details', pathParameters: {'id': movieId.toString()});

      // Delay kecil untuk memastikan navigasi selesai
      await Future.delayed(const Duration(milliseconds: 50));

      // Load detail film jika belum ada
      if (movieController.movieDetail.value?.id != movieId) {
        movieController.getMovieDetails(movieId);
      }

      // Load similar movies
      movieController.getSimilarMovies(movieId);

      // Reset flag navigasi
      await Future.delayed(const Duration(milliseconds: 200));
      movieController.isNavigatingToMovie.value = false;

      // Restore search results jika perlu
      if (searchQuery != null && context.mounted) {
        movieController.searchMovies(searchQuery);
      }
    } catch (e) {
      // Fallback navigation
      if (context.mounted) {
        context.push('/details/$movieId');
      }
    }
  }

  /// Navigasi ke home screen
  static void navigateToHome(BuildContext context) {
    // Reset semua state tracking
    _currentMovieId = null;
    _viewingSimilarMovie = false;
    _originalMovieId = null;
    _sourceScreen = 'home';
    _lastSearchQuery = null;

    // Navigate to home
    context.goNamed('home');
  }

  /// Handle tombol back
  static void goBack(BuildContext context, {bool fromDetailScreen = false}) {
    if (fromDetailScreen) {
      // Jika sedang melihat similar movie dan punya original movie ID
      if (_viewingSimilarMovie && _originalMovieId != null) {
        // Buat path ke film original
        final originalMovieRoute = '/details/$_originalMovieId';

        // Reset tracking similar movie
        _viewingSimilarMovie = false;
        _currentMovieId = _originalMovieId;
        _originalMovieId = null;

        // Navigasi langsung ke film original
        context.go(originalMovieRoute);

        // Load data film original
        final movieController = Get.find<MovieController>();
        movieController.getMovieDetails(_currentMovieId!);
        movieController.getSimilarMovies(_currentMovieId!);
      }
      // Kembali ke halaman asal (home atau search)
      else {
        _currentMovieId = null;

        if (_sourceScreen == 'search' && _lastSearchQuery != null) {
          // Kembali ke halaman search dan restore query
          context.goNamed('home');

          // Delay untuk memastikan navigasi selesai
          Future.delayed(const Duration(milliseconds: 100), () {
            // Aktifkan mode pencarian dan restore query
            final homeController = Get.find<HomeController>();
            homeController.activateSearchMode(_lastSearchQuery!);
          });
        } else {
          // Kembali ke home
          navigateToHome(context);
        }
      }
    }
    // Jika dari screen non-detail
    else if (context.canPop()) {
      context.pop();
    } else {
      navigateToHome(context);
    }
  }
}
