import 'package:cinenook/widgets/common/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

    // Hitung height yang lebih masuk akal - jangan gunakan seluruh screenHeight
    final containerHeight = screenHeight * 0.7; // Gunakan sebagian layar saja

    return SizedBox(
      height: containerHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actualCrossAxisCount = crossAxisCount > 0
              ? crossAxisCount
              : _getCrossAxisCount(constraints.maxWidth);

          // Pastikan spacing lebih kecil untuk layar kecil
          final spacing = constraints.maxWidth < 400 ? 8.0 : 12.0;

          return MasonryGridView.builder(
            itemCount: itemCount,
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: actualCrossAxisCount,
            ),
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index < 0 || index >= movies.length) {
                return const SizedBox.shrink();
              }

              final movie = movies[index];
              if (movie == null) {
                return const SizedBox.shrink();
              }

              // Variasi tinggi poster untuk efek staggered
              // Berdasarkan nilai tertentu dari film (misalnya rating atau ID)
              final extraHeight = (movie.id ?? index) % 3 * 20.0;

              return LayoutBuilder(builder: (context, constraints) {
                // Dapatkan lebar maksimum yang tersedia untuk item
                final itemWidth = constraints.maxWidth;
                // Base height untuk poster film dengan aspek ratio poster film (2:3)
                final baseHeight = itemWidth * 1.5;

                return SizedBox(
                  height: baseHeight + extraHeight,
                  child: MovieCard(
                    movie: movie,
                    showTitle: true,
                    searchQuery: searchQuery,
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }

  // Tambahkan lebih banyak breakpoint untuk layar kecil
  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth <= 320) return 1; // Layar sangat kecil
    if (maxWidth <= 600) return 2;
    if (maxWidth <= 1200) return 4;
    return 6;
  }
}
