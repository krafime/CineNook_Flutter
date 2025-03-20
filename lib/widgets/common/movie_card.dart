import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/navigation/movie_navigation_handler.dart';
import 'package:cinenook/widgets/common/network_image_with_loading.dart';
import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final String? searchQuery;
  final bool showTitle;
  final double aspectRatio;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
    this.searchQuery,
    this.showTitle = false,
    this.aspectRatio = 2 / 3,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () {
          MovieNavigationHandler.navigateToMovieDetails(
            context,
            movie.id,
            searchQuery: searchQuery,
          );
        },
        child: showTitle ? _buildCardWithTitle(context) : _buildPoster(),
      ),
    );
  }

  Widget _buildPoster() {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: NetworkImageWithLoading(
        imagePath: movie.posterPath,
        borderRadius: borderRadius,
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildCardWithTitle(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.inversePrimary,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: NetworkImageWithLoading(
                  imagePath: movie.posterPath,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movie.title ??
                  'Untitled Movie', // Fixed: Add null check with fallback
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
