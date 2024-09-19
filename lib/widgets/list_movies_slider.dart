import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:flutter/material.dart';

class ListMovies extends StatefulWidget {
  const ListMovies({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<List<Movie>> snapshot;

  @override
  State<ListMovies> createState() => _ListMoviesState();
}

class _ListMoviesState extends State<ListMovies> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Scrollbar(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = widget.snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _navigateToDetailScreen(movie.id),
                  child: _buildMoviePoster(movie),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToDetailScreen(int movieId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(id: movieId),
      ),
    );

    // After returning from DetailScreen
    if (mounted) {
      setState(() {
        // Refresh the state if necessary
      });
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildMoviePoster(Movie movie) {
    final imagePath = movie.posterPath != null
        ? '${Constants.imagePath}${movie.posterPath}'
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 200,
        width: 120,
        child: imagePath != null
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
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              )
            : Image.asset(
                'assets/placeholder.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
