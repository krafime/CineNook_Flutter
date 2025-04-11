import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinenook/controllers/movie_controller.dart';
import 'package:cinenook/controllers/home_controller.dart';
import 'package:cinenook/widgets/common/movie_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchWidget extends StatefulWidget {
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
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // Use GetX controllers
  MovieController get movieController => Get.find<MovieController>();
  HomeController get homeController => Get.find<HomeController>();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Simplified scroll handler
  void _onScroll() {
    // Check if we're near the bottom of the list
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      // Load more results if we have a query and there are more results to load
      if (widget.lastSearchQuery != null &&
          widget.lastSearchQuery!.isNotEmpty &&
          movieController.hasMoreSearchResults.value &&
          !movieController.isLoadingMore.value) {
        movieController.loadMoreSearchResults(widget.lastSearchQuery!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = widget.screenWidth > 900;
    final isMediumScreen =
        widget.screenWidth > 600 && widget.screenWidth <= 900;

    return Obx(() {
      // Show loading indicator when first loading results
      if (movieController.isLoadingSearch.value &&
          movieController.searchResults.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Results found - show grid
      if (movieController.searchResults.isNotEmpty) {
        return _buildResultsView(context, isLargeScreen, isMediumScreen);
      }

      // Error state
      if (movieController.errorMessage.isNotEmpty) {
        return _buildErrorState(context, movieController.errorMessage.value,
            isLargeScreen, isMediumScreen);
      }

      // Empty results state (if we've searched but found nothing)
      if (widget.lastSearchQuery != null &&
          widget.lastSearchQuery!.isNotEmpty) {
        return _buildEmptyState(context, isLargeScreen, isMediumScreen);
      }

      // Default state - show placeholder
      return _buildPlaceholderState(context, isLargeScreen, isMediumScreen);
    });
  }

  Widget _buildResultsView(
      BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200) {
          if (widget.lastSearchQuery != null &&
              widget.lastSearchQuery!.isNotEmpty &&
              movieController.hasMoreSearchResults.value &&
              !movieController.isLoadingMore.value) {
            movieController.loadMoreSearchResults(widget.lastSearchQuery!);
          }
        }
        return true;
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
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

          // Kustom grid dengan loading indicator di dalam grid
          _buildCustomGrid(
            context,
            isLargeScreen,
            isMediumScreen,
            movieController.searchResults,
            widget.lastSearchQuery ?? "",
          ),
        ],
      ),
    );
  }

  Widget _buildCustomGrid(
    BuildContext context,
    bool isLargeScreen,
    bool isMediumScreen,
    List<dynamic> movies,
    String searchQuery,
  ) {
    // Tentukan jumlah kolom berdasarkan ukuran layar
    final crossAxisCount = isLargeScreen ? 5 : (isMediumScreen ? 3 : 2);

    // Hitung jumlah item termasuk loading indicator jika perlu
    final itemCount =
        movies.length + (movieController.hasMoreSearchResults.value ? 1 : 0);

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isLargeScreen ? 2 : 0, vertical: 0),
      child: MasonryGridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemBuilder: (context, index) {
          // Item terakhir dan hasMoreResults = true? Tampilkan loading indicator
          if (index == movies.length &&
              movieController.hasMoreSearchResults.value) {
            return _buildLoadingItem(crossAxisCount);
          }

          // Item normal dalam grid
          if (index < movies.length) {
            final movie = movies[index];

            // Variasi tinggi poster untuk efek staggered
            final extraHeight = (movie.id ?? index) % 3 * 20.0;

            return LayoutBuilder(builder: (context, constraints) {
              // Dapatkan lebar maksimum yang tersedia untuk item
              final itemWidth = constraints.maxWidth;
              // Base height untuk poster film dengan aspek ratio poster film (2:3)
              final baseHeight = itemWidth * 1.5;

              return SizedBox(
                height: baseHeight + extraHeight,
                child: MovieCard(
                  movie: movie,
                  showTitle: true,
                  searchQuery: searchQuery,
                ),
              );
            });
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget untuk menampilkan loading indicator di dalam grid
  Widget _buildLoadingItem(int crossAxisCount) {
    return Obx(
      () => movieController.isLoadingMore.value
          ? Container(
              height: 120,
              alignment: Alignment.center,
              child: const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : const SizedBox(height: 120),
    );
  }

  Widget _buildPlaceholderState(
      BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    return Center(
      child: Text(
        'Search for movies',
        style: TextStyle(
          fontSize: isLargeScreen ? 22 : (isMediumScreen ? 20 : 18),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
        ),
      ),
    );
  }

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
