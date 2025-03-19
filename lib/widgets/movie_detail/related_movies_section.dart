import 'package:cinenook/blocs/similar_movies/similar_movies_bloc.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_state.dart';
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
    this.title = 'Related Movies',
    this.titleSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BlocBuilder<SimilarMoviesBloc, SimilarMoviesState>(
            builder: (context, state) {
              if (state is SimilarMoviesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SimilarMoviesError) {
                return Center(child: Text(state.message));
              } else if (state is SimilarMoviesLoaded) {
                if (state.movies.isEmpty) {
                  return Text('No similar movies found',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface));
                }
                return ListMovies(
                  snapshot: AsyncSnapshot.withData(
                      ConnectionState.done, state.movies),
                );
              } else {
                return Text('No data found',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface));
              }
            },
          ),
        ),
      ],
    );
  }
}
