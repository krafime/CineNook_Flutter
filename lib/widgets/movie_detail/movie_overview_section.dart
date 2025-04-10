import 'package:flutter/material.dart';

class MovieOverviewSection extends StatelessWidget {
  final String overview;
  final double fontSize;
  final double titleSize;

  const MovieOverviewSection({
    super.key,
    required this.overview,
    this.fontSize = 12.0,
    this.titleSize = 14.0,
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
        Text(
          overview.isEmpty ? 'No overview available.' : overview,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: fontSize,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
