import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_event.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/movies/movies_event.dart';
import 'package:cinenook/blocs/movies/movies_state.dart';
import 'package:cinenook/blocs/popular_movies/popular_movies_bloc.dart'
    as popular;
import 'package:cinenook/blocs/now_playing_movies/now_playing_movies_bloc.dart'
    as now_playing;
import 'package:cinenook/blocs/upcoming_movies/upcoming_movies_bloc.dart'
    as upcoming;
import 'package:cinenook/widgets/grid_movies_slider.dart';
import 'package:cinenook/widgets/popular_movies_slider.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  DateTime? lastPressed;
  String? _lastSearchQuery;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadMovies() {
    context.read<popular.PopularMoviesBloc>().add(popular.LoadPopularMovies());
    context
        .read<now_playing.NowPlayingMoviesBloc>()
        .add(now_playing.LoadNowPlayingMovies());
    context
        .read<upcoming.UpcomingMoviesBloc>()
        .add(upcoming.LoadUpcomingMovies());
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  void _toggleSearch() {
    if (_isSearching) {
      // Exit search mode and clear the search query
      setState(() {
        _isSearching = false;
        _searchController.clear();
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });
    } else {
      // Enter search mode
      setState(() {
        _isSearching = true;
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
    if (didPop) {
      return;
    }

    if (_isSearching) {
      // Simplify: directly exit search mode without requiring two presses and clear the search query
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _lastSearchQuery = null; // clear search results query
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });
      return;
    }

    // If not in search mode (we're on home screen), handle double-press to exit
    final now = DateTime.now();
    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
      Navigator.of(context).pop();
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      context.read<MoviesBloc>().add(SearchMovies(query));
      setState(() {
        _isSearching = true;
        _lastSearchQuery = query;
      });
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(LoggedOut());
  }

  Widget _buildAppBar(double screenWidth) {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return AppBar(
      title: _isSearching
          ? _buildSearchField()
          : _buildAppTitle(
              isLargeScreen ? 42.0 : (isMediumScreen ? 36.0 : 32.0)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: isLargeScreen,
      toolbarHeight: isLargeScreen ? 80 : (isMediumScreen ? 70 : 60),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Cancel search' : 'Search',
        ),
        if (!_isSearching)
          IconButton(
            icon: Icon(
              Icons.logout,
              size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
            ),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        SizedBox(width: isLargeScreen ? 24 : (isMediumScreen ? 16 : 8)),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search movies',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onSubmitted: _performSearch,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildAppTitle(double fontSize) {
    return Hero(
      tag: 'logo',
      child: GlowText(
        'CineNook',
        style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            decoration: TextDecoration.none),
        glowColor:
            Colors.red.withValues(red: 255, green: 0, blue: 0, alpha: 0.5),
      ),
    );
  }

  Widget _buildSearchResults(double screenWidth) {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;

    return BlocBuilder<MoviesBloc, MoviesState>(
      builder: (context, state) {
        if (state is MoviesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchResultsLoaded) {
          if (state.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              GridMovies(
                snapshot:
                    AsyncSnapshot.withData(ConnectionState.done, state.movies),
                crossAxisCount: isLargeScreen ? 5 : (isMediumScreen ? 3 : 2),
                searchQuery: _lastSearchQuery, // modified
              ),
            ],
          );
        } else if (state is MoviesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
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
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHomeContent(double screenWidth) {
    final isLargeScreen = screenWidth > 900;

    if (isLargeScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPopularMoviesSection(screenWidth),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildNowPlayingMoviesSection(screenWidth),
                _buildUpcomingMoviesSection(screenWidth),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopularMoviesSection(screenWidth),
          _buildNowPlayingMoviesSection(screenWidth),
          _buildUpcomingMoviesSection(screenWidth),
        ],
      );
    }
  }

  Widget _buildPopularMoviesSection(double screenWidth) {
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
                  color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildNowPlayingMoviesSection(double screenWidth) {
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
                  color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildUpcomingMoviesSection(double screenWidth) {
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
                  color: Theme.of(context).colorScheme.onSurface,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;

      return PopScope(
        canPop: !_isSearching &&
            lastPressed != null &&
            DateTime.now().difference(lastPressed!) <=
                const Duration(seconds: 2),
        onPopInvokedWithResult: _handlePopInvoked,
        child: Scaffold(
          appBar: _buildAppBar(screenWidth) as PreferredSizeWidget,
          body: Center(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: screenWidth > 1200 ? 1200 : double.infinity),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth > 900 ? 32 : (screenWidth > 600 ? 24 : 16),
                    vertical: screenWidth > 600 ? 24 : 16,
                  ),
                  child: _isSearching
                      ? _buildSearchResults(screenWidth)
                      : _buildHomeContent(screenWidth),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
