import 'package:flutter/material.dart';
import 'package:cinenook/constants.dart';

class MovieBackdrop extends StatelessWidget {
  final String backdropPath;

  const MovieBackdrop({
    super.key,
    required this.backdropPath,
  });

  @override
  Widget build(BuildContext context) {
    return backdropPath.isNotEmpty
        ? Image.network(
            '${Constants.imageBackdropPath}$backdropPath',
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
          );
  }
}
