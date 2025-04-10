import 'package:cinenook/constants.dart';
import 'package:flutter/material.dart';

class NetworkImageWithLoading extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final FilterQuality filterQuality;
  final String placeholderAssetPath;
  final bool useImagePath;

  const NetworkImageWithLoading({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.filterQuality = FilterQuality.high,
    this.placeholderAssetPath = 'assets/placeholder.png',
    this.useImagePath = true,
  });

  @override
  Widget build(BuildContext context) {
    final finalImagePath = (imagePath != null && useImagePath)
        ? '${Constants.imagePosterPath}$imagePath'
        : imagePath;

    Widget imageWidget;

    if (finalImagePath != null) {
      imageWidget = Image.network(
        finalImagePath,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
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
          return Image.asset(
            placeholderAssetPath,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        placeholderAssetPath,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
      );
    }

    return borderRadius != null
        ? ClipRRect(
            borderRadius: borderRadius!,
            child: imageWidget,
          )
        : imageWidget;
  }
}
