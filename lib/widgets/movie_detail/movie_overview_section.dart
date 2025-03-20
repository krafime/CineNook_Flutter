import 'package:flutter/material.dart';

class MovieOverviewSection extends StatelessWidget {
  final String overview;
  final double fontSize;
  final double titleSize;

  const MovieOverviewSection({
    super.key,
    required this.overview,
    this.fontSize = 16.0,
    this.titleSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Replace deprecated withOpacity with withValues
            color: Theme.of(context).colorScheme.surface.withValues(
                  alpha:
                      150, // Replace withOpacity(0.6) with explicit alpha value
                  // Keep the same hue, saturation and brightness
                ),
          ),
          child: Text(
            overview.isEmpty ? 'No overview available.' : overview,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: fontSize,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
