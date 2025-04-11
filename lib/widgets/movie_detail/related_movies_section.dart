import 'package:cinenook/controllers/movie_controller.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RelatedMoviesSection extends StatefulWidget {
  final int movieId;
  final String title;
  final double titleSize;

  const RelatedMoviesSection({
    super.key,
    required this.movieId,
    this.title = 'Similar Movies',
    this.titleSize = 14,
  });

  @override
  State<RelatedMoviesSection> createState() => _RelatedMoviesSectionState();
}

class _RelatedMoviesSectionState extends State<RelatedMoviesSection> {
  // Get movie controller instance
  final MovieController movieController = Get.find<MovieController>();
  // Track the last movie ID to prevent repeated refreshes
  int? _lastLoadedMovieId;

  @override
  void initState() {
    super.initState();
    _loadMoviesIfNeeded();
  }

  @override
  void didUpdateWidget(RelatedMoviesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the movie ID changes
    if (oldWidget.movieId != widget.movieId) {
      _loadMoviesIfNeeded();
    }
  }

  void _loadMoviesIfNeeded() {
    // Only load similar movies if we haven't loaded them before
    // or if we're showing a different movie now
    if (_lastLoadedMovieId != widget.movieId) {
      _lastLoadedMovieId = widget.movieId;

      // Check if we need to load similar movies
      if (movieController.similarMovies.isEmpty ||
          movieController.movieDetail.value?.id != widget.movieId) {
        // Wait until the next frame to avoid build-time issues
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            movieController.getSimilarMovies(widget.movieId);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section
        Row(
          children: [
            Icon(
              Icons.movie_filter,
              size: widget.titleSize + 2,
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: widget.titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Similar movies content
        Obx(() {
          // Check if we're loading similar movies for THIS specific movie
          final bool isCurrentlyLoadingThis =
              movieController.isLoadingSimilar.value &&
                  _lastLoadedMovieId == widget.movieId;

          if (isCurrentlyLoadingThis) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (movieController.errorMessage.isNotEmpty) {
            return SizedBox(
              height: 100,
              child: Center(
                  child: Text('Error: ${movieController.errorMessage.value}')),
            );
          } else if (movieController.similarMovies.isNotEmpty) {
            // Create snapshot for ListMovies widget
            final snapshot = AsyncSnapshot.withData(
              ConnectionState.done,
              movieController.similarMovies,
            );

            // Tandai jelas bahwa ini adalah "similar movies" sehingga akan diperlakukan khusus
            // pada navigasi
            return ListMovies(
              snapshot: snapshot,
              itemWidth: 140,
              fromSimilarMovies: true,
            );
          } else {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('No similar movies found')),
            );
          }
        }),
      ],
    );
  }
}
