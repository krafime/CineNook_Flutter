import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_state.dart';
import 'package:cinenook/widgets/grid_movies_slider.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) performSearch;
  final String? lastSearchQuery;
  final double screenWidth;

  const SearchWidget({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.performSearch,
    required this.lastSearchQuery,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    // Size constants to avoid unbounded constraints
    final double minContentHeight = MediaQuery.of(context).size.height * 0.5;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: minContentHeight,
      ),
      child: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          // Loading state
          if (state is MoviesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Results loaded state
          else if (state is SearchResultsLoaded) {
            // Handle empty results
            if (state.movies.isEmpty) {
              return _buildEmptyState(context, isLargeScreen, isMediumScreen);
            }

            // Results found - show grid
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Search Results',
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                // Fix: Wrap GridMovies in a container with defined constraints
                Container(
                  constraints: BoxConstraints(
                    // Set minimum height but allow it to grow
                    minHeight: 200,
                  ),
                  child: GridMovies(
                    snapshot: AsyncSnapshot.withData(
                      ConnectionState.done,
                      state.movies, // Add null check
                    ),
                    crossAxisCount:
                        isLargeScreen ? 5 : (isMediumScreen ? 3 : 2),
                    searchQuery: lastSearchQuery ?? "",
                  ),
                ),
              ],
            );
          }
          // Error state
          else if (state is MoviesError) {
            return _buildErrorState(
                context, state.message, isLargeScreen, isMediumScreen);
          }

          // Default state - show placeholder with proper height
          return SizedBox(
            width: double.infinity,
            height: minContentHeight,
            child: Center(
              child: Text(
                'Search for movies',
                style: TextStyle(
                  fontSize: isLargeScreen ? 22 : (isMediumScreen ? 20 : 18),
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build empty state UI
  Widget _buildEmptyState(
      BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No movies found',
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : (isMediumScreen ? 20 : 16),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build error state UI
  Widget _buildErrorState(BuildContext context, String message,
      bool isLargeScreen, bool isMediumScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : (isMediumScreen ? 18 : 16),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
