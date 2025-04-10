import 'package:cinenook/auth/auth_guard_mixin.dart';
import 'package:cinenook/controllers/movie_controller.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/navigation/movie_navigation_handler.dart';
import 'package:cinenook/widgets/movie_detail/movie_backdrop.dart';
import 'package:cinenook/widgets/movie_detail/movie_details_section.dart';
import 'package:cinenook/widgets/movie_detail/movie_header_info.dart';
import 'package:cinenook/widgets/movie_detail/movie_overview_section.dart';
import 'package:cinenook/widgets/movie_detail/movie_poster.dart';
import 'package:cinenook/widgets/movie_detail/related_movies_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final bool fromDetailScreen;

  const DetailScreen({
    super.key,
    required this.id,
    this.fromDetailScreen = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with AuthGuardMixin {
  // Get movie controller instance
  final MovieController movieController = Get.find<MovieController>();

  // Store the current movie ID to detect changes
  late int _currentMovieId;

  // Track if initial data has been loaded to prevent repeated loading
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState(); // AuthGuardMixin will call checkAuthentication()
    _currentMovieId = widget.id;

    // Initial data load using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialDataLoaded) {
        _loadMovieData(_currentMovieId);
        _initialDataLoaded = true;
      }
    });
  }

  @override
  void didUpdateWidget(DetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the ID changes, reload the data using post-frame callback
    if (oldWidget.id != widget.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _currentMovieId = widget.id;
        _loadMovieData(_currentMovieId);
      });
    }
  }

  void _loadMovieData(int movieId) {
    // Check if we already have the movie details to prevent unnecessary reloads
    if (movieController.movieDetail.value?.id != movieId) {
      // Load movie details using GetX controller
      movieController.getMovieDetails(movieId);
    }

    // Always fetch similar movies as they may have changed
    movieController.getSimilarMovies(movieId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          MovieNavigationHandler.goBack(context,
              fromDetailScreen: widget.fromDetailScreen);
        }
      },
      child: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth <= 600;
          final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
          final isLargeScreen = screenWidth > 900;

          return Obx(() {
            // Check if we have data for a different movie (wrong movie showing)
            final bool showingWrongMovie =
                movieController.movieDetail.value != null &&
                    movieController.movieDetail.value!.id != _currentMovieId;

            if (movieController.errorMessage.isNotEmpty &&
                movieController.movieDetail.value == null) {
              // Error state - keep this as is
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isSmallScreen ? 40 : (isMediumScreen ? 60 : 80),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading movie details',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        movieController.errorMessage.value,
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            } else if (movieController.movieDetail.value != null &&
                !showingWrongMovie) {
              // We have the movie data for the correct movie - show full UI
              final MovieDetail movieDetail =
                  movieController.movieDetail.value!;

              // Wrap content in a fade transition for smoother appearance
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isLargeScreen ? 1400 : double.infinity,
                    ),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(context, movieDetail, constraints),
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    isLargeScreen ? 1200 : double.infinity,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen
                                    ? 16
                                    : (isMediumScreen ? 24 : 32),
                                vertical: isSmallScreen
                                    ? 16
                                    : (isMediumScreen ? 24 : 32),
                              ),
                              child: isLargeScreen
                                  ? _buildWideLayout(movieDetail, constraints)
                                  : (isMediumScreen
                                      ? _buildMediumLayout(
                                          movieDetail, constraints)
                                      : _buildMovieDetails(movieDetail)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // LOADING OR WRONG MOVIE: Show skeleton UI instead of just a loading screen
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 1400 : double.infinity,
                  ),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Skeleton app bar
                      _buildSkeletonAppBar(context, constraints),
                      SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isLargeScreen ? 1200 : double.infinity,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen
                                  ? 16
                                  : (isMediumScreen ? 24 : 32),
                              vertical: isSmallScreen
                                  ? 16
                                  : (isMediumScreen ? 24 : 32),
                            ),
                            child: isLargeScreen
                                ? _buildSkeletonWideLayout(constraints)
                                : (isMediumScreen
                                    ? _buildSkeletonMediumLayout(constraints)
                                    : _buildSkeletonDetails()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          });
        }),
      ),
    );
  }

  // SKELETON UI BUILDERS
  SliverAppBar _buildSkeletonAppBar(
      BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth <= 600;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final borderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    );

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: isSmallScreen
          ? 300
          : (isMediumScreen ? 350 : (screenWidth > 1200 ? 500 : 400)),
      pinned: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(color: Colors.grey.shade800),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((0.8 * 255).toInt()),
                  ],
                ),
              ),
            ),
            _buildSkeletonPosterAndInfo(context, constraints),
            _buildBackButton(),
            // Loading indicator overlay
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonPosterAndInfo(
      BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth <= 600;
    final isLargeScreen = screenWidth > 900;

    return Positioned(
      bottom: isLargeScreen ? 20 : 10,
      left: isLargeScreen ? 40 : 20,
      right: isLargeScreen ? 40 : 20,
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Skeleton poster
                    Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Skeleton info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 24,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 16,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  height: 20,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Skeleton poster
                Container(
                  height: screenWidth > 1200
                      ? 240
                      : (screenWidth > 900 ? 200 : 180),
                  width: screenWidth > 1200
                      ? 160
                      : (screenWidth > 900 ? 133 : 120),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                // Skeleton info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 32,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeletonWideLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.black.withAlpha(76),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSkeletonDetailItems(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.black.withAlpha(76),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildSkeletonRelatedMovies(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonMediumLayout(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSkeletonInfoItems(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSkeletonOverviewItems(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildSkeletonRelatedMovies(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildSkeletonOverviewItems(),
                const SizedBox(height: 16),
                ..._buildSkeletonInfoItems(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSkeletonRelatedMovies(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSkeletonDetailItems() {
    return [
      ..._buildSkeletonInfoItems(),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 24),
      ..._buildSkeletonOverviewItems(),
    ];
  }

  List<Widget> _buildSkeletonInfoItems() {
    return [
      // Duration and Release Date row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Language and Popularity row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSkeletonOverviewItems() {
    return [
      Container(
        height: 24,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        height: 14,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 14,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 14,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 14,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ];
  }

  Widget _buildSkeletonRelatedMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(MovieDetail movieDetail, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.black.withAlpha(76),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MovieDetailsSection(
                        movieDetail: movieDetail, isLargeScreen: true),
                    const SizedBox(height: 24),
                    if (movieDetail.tagline.isNotEmpty) ...[
                      _buildTagline(movieDetail.tagline),
                      const SizedBox(height: 24),
                    ],
                    MovieOverviewSection(
                      overview: movieDetail.overview,
                      fontSize: screenWidth > 1200 ? 20 : 18,
                      titleSize: screenWidth > 1200 ? 28 : 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.black.withAlpha(76),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: RelatedMoviesSection(
                  movieId: movieDetail.id,
                  title: 'Similar Movies',
                  titleSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumLayout(
      MovieDetail movieDetail, BoxConstraints constraints) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.black.withAlpha(76),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: MovieDetailsSection(movieDetail: movieDetail),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (movieDetail.tagline.isNotEmpty) ...[
                              _buildTagline(movieDetail.tagline),
                              const SizedBox(height: 16),
                            ],
                            MovieOverviewSection(
                              overview: movieDetail.overview,
                              fontSize: 16,
                              titleSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.black.withAlpha(76),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: RelatedMoviesSection(
                movieId: movieDetail.id,
                title: 'Similar Movies You Might Like',
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, MovieDetail movieDetail,
      BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth <= 600;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final borderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    );

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: isSmallScreen
          ? 300
          : (isMediumScreen ? 350 : (screenWidth > 1200 ? 500 : 400)),
      pinned: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: MovieBackdrop(backdropPath: movieDetail.backdropPath),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((0.8 * 255).toInt()),
                  ],
                ),
              ),
            ),
            _buildPosterAndInfo(context, movieDetail, constraints),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20,
      left: 10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.5 * 255).toInt()),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            // Use post-frame callback for navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                MovieNavigationHandler.goBack(context,
                    fromDetailScreen: widget.fromDetailScreen);
              }
            });
          },
          tooltip: 'Back to previous screen',
        ),
      ),
    );
  }

  Widget _buildPosterAndInfo(BuildContext context, MovieDetail movieDetail,
      BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth <= 600;
    final isLargeScreen = screenWidth > 900;

    return Positioned(
      bottom: isLargeScreen ? 20 : 10,
      left: isLargeScreen ? 40 : 20,
      right: isLargeScreen ? 40 : 20,
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoviePoster(
                      posterPath: movieDetail.posterPath,
                      height: 150,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MovieHeaderInfo(
                        movieDetail: movieDetail,
                        constraints: constraints,
                        compactMode: true,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MoviePoster(
                  posterPath: movieDetail.posterPath,
                  height: screenWidth > 1200
                      ? 240
                      : (screenWidth > 900 ? 200 : 180),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MovieHeaderInfo(
                    movieDetail: movieDetail,
                    constraints: constraints,
                    compactMode: false,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMovieDetails(MovieDetail movieDetail) {
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movieDetail.tagline.isNotEmpty) ...[
                  _buildTagline(movieDetail.tagline),
                  const SizedBox(height: 16),
                ],
                MovieOverviewSection(overview: movieDetail.overview),
                const SizedBox(height: 16),
                MovieDetailsSection(
                  movieDetail: movieDetail,
                  isLargeScreen: isLargeScreen,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withAlpha(76),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RelatedMoviesSection(
              movieId: movieDetail.id,
              title: 'Similar Movies',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline(String tagline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withAlpha(76),
      ),
      child: Text(
        '"$tagline"',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
          fontStyle: FontStyle.italic,
          fontSize: MediaQuery.of(context).size.width > 1200 ? 18 : 16,
        ),
      ),
    );
  }
}
