import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinenook/controllers/movie_controller.dart';
import 'package:cinenook/widgets/popular_movies_slider.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';

class MovieSections extends StatelessWidget {
  final double screenWidth;

  const MovieSections({super.key, required this.screenWidth});

  // Use GetX controller instead of BLoC
  MovieController get movieController => Get.find<MovieController>();

  Widget _buildPopularMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final isVerySmallScreen =
        screenWidth < 400; // Tambahkan pengecekan untuk layar sangat kecil

    return Container(
      padding: EdgeInsets.all(isVerySmallScreen
          ? 8
          : (isLargeScreen ? 24 : (isMediumScreen ? 16 : 12))),
      margin: EdgeInsets.symmetric(
          vertical: isVerySmallScreen
              ? 8
              : (isLargeScreen ? 24 : (isMediumScreen ? 16 : 12))),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha(76),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Movies',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isVerySmallScreen
                ? 240
                : (isLargeScreen ? 400 : (isMediumScreen ? 350 : 300)),
            child: Obx(() {
              if (movieController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (movieController.popularMovies.isNotEmpty) {
                return PopularMovies(
                  snapshot: AsyncSnapshot.withData(
                      ConnectionState.done, movieController.popularMovies),
                );
              } else if (movieController.errorMessage.isNotEmpty) {
                return Center(child: Text(movieController.errorMessage.value));
              }
              return const SizedBox(height: 200);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final isVerySmallScreen =
        screenWidth < 400; // Tambahkan pengecekan untuk layar sangat kecil

    return Container(
      padding: EdgeInsets.all(isVerySmallScreen
          ? 8
          : (isLargeScreen ? 24 : (isMediumScreen ? 16 : 12))),
      margin: EdgeInsets.symmetric(
          vertical: isVerySmallScreen
              ? 8
              : (isLargeScreen ? 24 : (isMediumScreen ? 16 : 12))),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha(76),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.movie,
                color: Colors.blue,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Now Playing',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isVerySmallScreen
                ? 160
                : (isLargeScreen ? 240 : (isMediumScreen ? 220 : 200)),
            child: Obx(() {
              if (movieController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (movieController.nowPlayingMovies.isNotEmpty) {
                return ListMovies(
                  snapshot: AsyncSnapshot.withData(
                      ConnectionState.done, movieController.nowPlayingMovies),
                  itemWidth: isLargeScreen ? 160 : (isMediumScreen ? 140 : 120),
                );
              } else if (movieController.errorMessage.isNotEmpty) {
                return Center(child: Text(movieController.errorMessage.value));
              }
              return const SizedBox(height: 200);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final isVerySmallScreen =
        screenWidth < 400; // Tambahkan pengecekan untuk layar sangat kecil

    return Container(
      padding: EdgeInsets.all(isVerySmallScreen
          ? 8
          : (isLargeScreen ? 24 : (isMediumScreen ? 16 : 12))),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha(76),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.green,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Movies',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isVerySmallScreen
                ? 160
                : (isLargeScreen ? 240 : (isMediumScreen ? 220 : 200)),
            child: Obx(() {
              if (movieController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (movieController.upcomingMovies.isNotEmpty) {
                return ListMovies(
                  snapshot: AsyncSnapshot.withData(
                      ConnectionState.done, movieController.upcomingMovies),
                  itemWidth: isLargeScreen ? 160 : (isMediumScreen ? 140 : 120),
                );
              } else if (movieController.errorMessage.isNotEmpty) {
                return Center(child: Text(movieController.errorMessage.value));
              }
              return const SizedBox(height: 200);
            }),
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    final isLargeScreen = screenWidth > 900;

    if (isLargeScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPopularMoviesSection(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildNowPlayingMoviesSection(),
                _buildUpcomingMoviesSection(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopularMoviesSection(),
          _buildNowPlayingMoviesSection(),
          _buildUpcomingMoviesSection(),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize data loading when the widget is built
    _initData();
    return buildHomeContent();
  }

  void _initData() {
    // Load all movie data if not already loaded
    if (movieController.popularMovies.isEmpty) {
      movieController.getPopularMovies();
    }

    if (movieController.nowPlayingMovies.isEmpty) {
      movieController.getNowPlayingMovies();
    }

    if (movieController.upcomingMovies.isEmpty) {
      movieController.getUpcomingMovies();
    }
  }
}
