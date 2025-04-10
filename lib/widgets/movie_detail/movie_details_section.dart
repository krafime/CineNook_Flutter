import 'package:flutter/material.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:intl/intl.dart';

class MovieDetailsSection extends StatelessWidget {
  final MovieDetail movieDetail;
  final bool isLargeScreen;

  const MovieDetailsSection({
    super.key,
    required this.movieDetail,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width to make responsive adjustments
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 800 : 600,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            leftTitle: 'Duration',
            leftValue: movieDetail.runtime > 0
                ? _formatDuration(movieDetail.runtime)
                : 'No data',
            rightTitle: 'Release Date',
            rightValue: _formatReleaseDate(movieDetail.releaseDate),
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          _buildInfoRow(
            context,
            leftTitle: 'Original Language',
            leftValue: movieDetail.spokenLanguages.isNotEmpty
                ? movieDetail.spokenLanguages.first.name
                : 'No data',
            rightTitle: 'Popularity',
            rightValue: movieDetail.popularity > 0
                ? movieDetail.popularity.toStringAsFixed(1)
                : 'No data',
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoColumn(
          context,
          leftTitle,
          leftValue,
          isSmallScreen,
          isMediumScreen,
        ),
        _buildInfoColumn(
          context,
          rightTitle,
          rightValue,
          isSmallScreen,
          isMediumScreen,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String title,
    String value,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    // Calculate font sizes based on screen size
    final titleSize = isSmallScreen
        ? 14.0
        : (isMediumScreen ? 16.0 : (isLargeScreen ? 20.0 : 18.0));

    final valueSize = isSmallScreen
        ? 12.0
        : (isMediumScreen ? 14.0 : (isLargeScreen ? 16.0 : 14.0));

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 0 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLargeScreen ? 8.0 : 4.0),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: valueSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReleaseDate(DateTime? releaseDate) {
    if (releaseDate == null) {
      return 'No data';
    }
    try {
      return DateFormat.yMMMEd().format(releaseDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
