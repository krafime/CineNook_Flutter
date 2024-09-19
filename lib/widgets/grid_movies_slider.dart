import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:cinenook/transitions/fade_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GridMovies extends StatelessWidget {
  const GridMovies({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<List<Movie>> snapshot;

  @override
  Widget build(BuildContext context) {
    final movies = snapshot.data!;

    return SizedBox(
      height: MediaQuery.of(context).size.height - (kToolbarHeight * 2.5),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MasonryGridView.count(
            crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieItem(movie: movie);
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

class MovieItem extends StatelessWidget {
  const MovieItem({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final imagePath = movie.posterPath != null
        ? '${Constants.imagePath}${movie.posterPath}'
        : 'assets/placeholder.png';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          createFadeRoute(
            DetailScreen(id: movie.id),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: movie.posterPath != null
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              child,
                              Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/placeholder.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title.toString(),
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
    );
  }
}
