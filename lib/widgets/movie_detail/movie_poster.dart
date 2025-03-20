import 'package:flutter/material.dart';
import 'package:cinenook/constants.dart';

class MoviePoster extends StatelessWidget {
  final String posterPath;
  final double height;
  final double? width;
  // Standard movie poster aspect ratio is typically 2:3
  static const double aspectRatio = 2 / 3;

  const MoviePoster({
    super.key,
    required this.posterPath,
    this.width,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate width based on height if width is not provided
    final double calculatedWidth = width ?? height * aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: calculatedWidth,
        height: height,
        child: posterPath.isNotEmpty
            ? Image.network(
                '${Constants.imagePath}$posterPath',
                fit: BoxFit
                    .fill, // Changed from cover to fill to maintain exact dimensions
                filterQuality: FilterQuality.high,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black12), // Placeholder color
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
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                },
              )
            : Image.asset(
                'assets/placeholder.png',
                fit: BoxFit.fill, // Changed from cover to fill
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}
