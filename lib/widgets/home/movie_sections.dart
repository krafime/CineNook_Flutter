import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinenook/blocs/popular_movies/popular_movies_bloc.dart'
    as popular;
import 'package:cinenook/blocs/now_playing_movies/now_playing_movies_bloc.dart'
    as now_playing;
import 'package:cinenook/blocs/upcoming_movies/upcoming_movies_bloc.dart'
    as upcoming;
import 'package:cinenook/widgets/popular_movies_slider.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';

class MovieSections extends StatelessWidget {
  final double screenWidth;

  const MovieSections({super.key, required this.screenWidth});

  Widget _buildPopularMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
      margin: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(red: 255, green: 0, blue: 0, alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Movies',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isLargeScreen ? 400 : (isMediumScreen ? 350 : 300),
            child: BlocBuilder<popular.PopularMoviesBloc,
                popular.PopularMoviesState>(
              builder: (context, state) {
                if (state is popular.PopularMoviesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is popular.PopularMoviesLoaded) {
                  return PopularMovies(
                    snapshot: AsyncSnapshot.withData(
                        ConnectionState.done, state.movies),
                  );
                } else if (state is popular.PopularMoviesError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox(height: 200);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
      margin: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(red: 0, green: 0, blue: 255, alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.movie,
                color: Colors.blue,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Now Playing',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isLargeScreen ? 240 : (isMediumScreen ? 220 : 200),
            child: BlocBuilder<now_playing.NowPlayingMoviesBloc,
                now_playing.NowPlayingMoviesState>(
              builder: (context, state) {
                if (state is now_playing.NowPlayingMoviesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is now_playing.NowPlayingMoviesLoaded) {
                  return ListMovies(
                    snapshot: AsyncSnapshot.withData(
                        ConnectionState.done, state.movies),
                    itemWidth:
                        isLargeScreen ? 160 : (isMediumScreen ? 140 : 120),
                  );
                } else if (state is now_playing.NowPlayingMoviesError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox(height: 200);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMoviesSection() {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : (isMediumScreen ? 16 : 12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(red: 0, green: 255, blue: 0, alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.green,
                size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Movies',
                style: GoogleFonts.poppins(
                  fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isLargeScreen ? 240 : (isMediumScreen ? 220 : 200),
            child: BlocBuilder<upcoming.UpcomingMoviesBloc,
                upcoming.UpcomingMoviesState>(
              builder: (context, state) {
                if (state is upcoming.UpcomingMoviesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is upcoming.UpcomingMoviesLoaded) {
                  return ListMovies(
                    snapshot: AsyncSnapshot.withData(
                        ConnectionState.done, state.movies),
                    itemWidth:
                        isLargeScreen ? 160 : (isMediumScreen ? 140 : 120),
                  );
                } else if (state is upcoming.UpcomingMoviesError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox(height: 200);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    final isLargeScreen = screenWidth > 900;

    if (isLargeScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPopularMoviesSection(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildNowPlayingMoviesSection(),
                _buildUpcomingMoviesSection(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopularMoviesSection(),
          _buildNowPlayingMoviesSection(),
          _buildUpcomingMoviesSection(),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildHomeContent();
  }
}
