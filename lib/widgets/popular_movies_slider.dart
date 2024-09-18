import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/screens/detail_screen.dart';
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
        // Menentukan parameter berdasarkan lebar layar
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
              return MoviePoster(
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

class MoviePoster extends StatelessWidget {
  const MoviePoster({
    super.key,
    required this.movie,
    required this.height,
  });

  final Movie movie;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(id: movie.id),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 2 / 3, // Rasio poster film standar
          child: Image.network(
            '${Constants.imagePath}${movie.posterPath}',
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
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),
      ),
    );
  }
}
