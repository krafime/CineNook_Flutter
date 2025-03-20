import 'package:cinenook/widgets/common/movie_card.dart';
import 'package:flutter/material.dart';

class GridMovies extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final int crossAxisCount;
  final String? searchQuery;

  const GridMovies({
    super.key,
    required this.snapshot,
    this.crossAxisCount = 2,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // Safe handling of data with null check
    if (!snapshot.hasData || snapshot.data == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No data available")),
      );
    }

    final movies = snapshot.data ?? [];

    if (movies.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No movies found")),
      );
    }

    // Calculate dynamic height based on item count and screen dimensions
    final itemCount = movies.length;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use a more moderate height - 50% of screen height instead of 70%
    final containerHeight = screenHeight; // Reduced from 0.7 to 0.5

    return SizedBox(
      height: containerHeight, // More dynamic height
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actualCrossAxisCount = crossAxisCount > 0
              ? crossAxisCount
              : _getCrossAxisCount(constraints.maxWidth);

          // Calculate better aspect ratio based on screen dimensions
          final aspectRatio = screenWidth > 600 ? 0.65 : 0.6;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: actualCrossAxisCount,
              crossAxisSpacing: 12, // Increased spacing
              mainAxisSpacing: 12, // Increased spacing
              childAspectRatio:
                  aspectRatio, // Better aspect ratio for movie posters
            ),
            // Allow scrolling when content overflows
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            shrinkWrap: false, // Don't shrink wrap to allow full height
            itemBuilder: (context, index) {
              if (index < 0 || index >= movies.length) {
                return const SizedBox.shrink();
              }
              final movie = movies[index];
              if (movie == null) {
                return const SizedBox.shrink();
              }
              return MovieCard(
                movie: movie,
                showTitle: true,
                searchQuery: searchQuery,
              );
            },
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth <= 600) return 2;
    if (maxWidth <= 1200) return 4;
    return 6;
  }
}
