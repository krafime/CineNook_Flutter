import 'package:flutter/material.dart';

class MovieOverviewSection extends StatelessWidget {
  final String overview;
  final double fontSize;
  final String title;
  final double titleSize;

  const MovieOverviewSection({
    super.key,
    required this.overview,
    this.fontSize = 14,
    this.title = 'Overview',
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
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          style: TextStyle(
            fontSize: fontSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
