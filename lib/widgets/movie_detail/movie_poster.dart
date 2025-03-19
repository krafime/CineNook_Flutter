import 'package:flutter/material.dart';
import 'package:cinenook/constants.dart';

class MoviePoster extends StatelessWidget {
  final String posterPath;
  final double width;
  final double height;

  const MoviePoster({
    super.key,
    required this.posterPath,
    this.width = 120,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: posterPath.isNotEmpty
          ? Image.network(
              '${Constants.imagePath}$posterPath',
              width: width,
              height: height,
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
              width: width,
              height: height,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
    );
  }
}
