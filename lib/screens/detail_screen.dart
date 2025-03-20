import 'package:cinenook/auth/auth_guard_mixin.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_event.dart';
import 'package:cinenook/blocs/movies/movies_state.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_bloc.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_event.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/navigation/movie_navigation_handler.dart';
import 'package:cinenook/widgets/movie_detail/movie_backdrop.dart';
import 'package:cinenook/widgets/movie_detail/movie_details_section.dart';
import 'package:cinenook/widgets/movie_detail/movie_header_info.dart';
import 'package:cinenook/widgets/movie_detail/movie_overview_section.dart';
import 'package:cinenook/widgets/movie_detail/movie_poster.dart';
import 'package:cinenook/widgets/movie_detail/related_movies_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  @override
  void initState() {
    super.initState(); // AuthGuardMixin will call checkAuthentication()

    // Request movie details via bloc
    context.read<MoviesBloc>().add(LoadMovieDetails(widget.id));
    // Load similar movies
    context.read<SimilarMoviesBloc>().add(LoadSimilarMovies(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    // Use navigation replacement when coming from another detail screen
    // This prevents building up a stack of detail screens

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth <= 600;
        final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
        final isLargeScreen = screenWidth > 900;

        return BlocBuilder<MoviesBloc, MoviesState>(
          buildWhen: (previous, current) =>
              current is MoviesLoading ||
              current is MovieDetailsLoaded ||
              current is MoviesError,
          builder: (context, state) {
            if (state is MoviesLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading movie details...',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is MoviesError) {
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
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize:
                            isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            } else if (state is MovieDetailsLoaded) {
              final movieDetail = state.movie;
              return Center(
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
              );
            } else {
              return const Center(child: Text('No data found'));
            }
          },
        );
      }),
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
            MovieNavigationHandler.goBack(context,
                fromDetailScreen: widget.fromDetailScreen);
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
