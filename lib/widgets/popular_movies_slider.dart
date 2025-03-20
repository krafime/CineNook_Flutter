import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/widgets/common/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PopularMovies extends StatelessWidget {
  const PopularMovies({
    super.key,
    required this.snapshot,
  });

  final AsyncSnapshot<List<Movie>> snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double viewportFraction;
        double height;
        int itemCount;

        if (constraints.maxWidth <= 600) {
          viewportFraction = 0.5;
          height = 250;
          itemCount = 3;
        } else if (constraints.maxWidth <= 1200) {
          viewportFraction = 0.4;
          height = 300;
          itemCount = 5;
        } else {
          viewportFraction = 0.3;
          height = 350;
          itemCount = 7;
        }

        return SizedBox(
          width: double.infinity,
          child: CarouselSlider.builder(
            itemCount: snapshot.data!.length.clamp(0, itemCount),
            options: CarouselOptions(
              height: height,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: viewportFraction,
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
            ),
            itemBuilder: (context, itemIndex, pageViewIndex) {
              return MovieCard(
                movie: snapshot.data![itemIndex],
                height: height,
              );
            },
          ),
        );
      },
    );
  }
}
