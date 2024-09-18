import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:flutter/material.dart';

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
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.6,
            ),
            physics: const BouncingScrollPhysics(),
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
        : 'assets/placeholder.png'; // Ganti dengan asset path yang benar

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(id: movie.id),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wraps the content based on its size
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: movie.posterPath != null
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    : Image.asset(
                        'assets/placeholder.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                movie.title.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Limit text to avoid overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
