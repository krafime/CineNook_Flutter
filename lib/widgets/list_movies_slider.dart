import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/widgets/common/movie_card.dart';
import 'package:flutter/material.dart';

class ListMovies extends StatefulWidget {
  const ListMovies({
    super.key,
    required this.snapshot,
    this.itemWidth = 140,
    this.searchQuery,
    this.fromSimilarMovies = false,
  });

  final AsyncSnapshot<List<Movie>> snapshot;
  final double itemWidth;
  final String? searchQuery;
  final bool fromSimilarMovies;

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
              return MovieCard(
                movie: movie,
                width: widget.itemWidth,
                height: 200,
                searchQuery: widget.searchQuery,
                padding: const EdgeInsets.only(right: 8.0),
                fromSimilarMovies: widget.fromSimilarMovies,
              );
            },
          ),
        ),
      ),
    );
  }
}
