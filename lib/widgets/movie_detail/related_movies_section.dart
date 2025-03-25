import 'package:cinenook/blocs/similar_movies/similar_movies_bloc.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_state.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_event.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RelatedMoviesSection extends StatelessWidget {
  final int movieId;
  final String title;
  final double titleSize;

  const RelatedMoviesSection({
    super.key,
    required this.movieId,
    this.title = 'Similar Movies',
    this.titleSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    // Trigger loading of similar movies when the widget is built
    // This ensures fresh data each time the movie changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimilarMoviesBloc>().add(LoadSimilarMovies(movieId));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<SimilarMoviesBloc, SimilarMoviesState>(
          builder: (context, state) {
            if (state is SimilarMoviesLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is SimilarMoviesError) {
              return SizedBox(
                height: 100,
                child: Center(child: Text('Error: ${state.message}')),
              );
            } else if (state is SimilarMoviesLoaded) {
              if (state.movies.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text('No similar movies found')),
                );
              }

              // Create snapshot for ListMovies widget
              final snapshot = AsyncSnapshot.withData(
                ConnectionState.done,
                state.movies,
              );

              return ListMovies(
                snapshot: snapshot,
                itemWidth: 140,
              );
            }

            // Initial state
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }
}
