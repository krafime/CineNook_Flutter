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
  final int? rank; // Add rank parameter

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
    this.rank, // Add rank parameter to constructor
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
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: NetworkImageWithLoading(
            imagePath: movie.posterPath,
            borderRadius: borderRadius,
            width: width,
            height: height,
          ),
        ),
        // Add rank badge if rank is provided
        if (rank != null) _buildRankBadge(),
      ],
    );
  }

  Widget _buildRankBadge() {
    // Choose badge color based on rank
    Color badgeColor;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFEFBF040); // Gold
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        badgeColor = Colors.grey.withAlpha(80);
    }

    return Positioned(
      left: 8,
      top: 8,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithTitle(BuildContext context) {
    return Stack(
      children: [
        Card(
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
                  movie.title ?? 'Untitled Movie',
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
        ),
        // Add rank badge if rank is provided
        if (rank != null) _buildRankBadge(),
      ],
    );
  }
}
