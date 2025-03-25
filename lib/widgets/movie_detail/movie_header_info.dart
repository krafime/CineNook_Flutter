import 'package:flutter/material.dart';
import 'package:cinenook/colors.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MovieHeaderInfo extends StatelessWidget {
  final MovieDetail movieDetail;
  final BoxConstraints constraints;
  final bool compactMode;

  const MovieHeaderInfo({
    super.key,
    required this.movieDetail,
    required this.constraints,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetail.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: compactMode ? 16 : 32,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildRating(context),
        const SizedBox(height: 4),
        _buildGenres(context),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: ListColors.ratingColor),
        const SizedBox(width: 4),
        Text(
            '${movieDetail.voteAverage.toStringAsFixed(2)}/10 (${movieDetail.voteCount})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: compactMode ? 12 : 18,
            )),
      ],
    );
  }

  Widget _buildGenres(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: kIsWeb ? 4 : -8,
      clipBehavior: Clip.antiAlias,
      children: movieDetail.genres
          .map((genre) => Chip(
                padding: const EdgeInsets.symmetric(horizontal: -3),
                label: Text(
                  genre.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: compactMode ? 10 : 16,
                  ),
                ),
                backgroundColor: Colors.grey[800],
              ))
          .toList(),
    );
  }
}
