import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/widgets/grid_movies_slider.dart';
import 'package:cinenook/widgets/popular_movies_slider.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_glow/flutter_glow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> nowPlayingMovies;
  late Future<List<Movie>> upcomingMovies;
  bool _isSearching = false;
  List<Movie>? searchMovies;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    _initializeMovieLists();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _initializeMovieLists() {
    popularMovies = Api().getPopularMovies();
    nowPlayingMovies = Api().getNowPlayingMovies();
    upcomingMovies = Api().getUpcomingPlayingMovies();
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  void _toggleSearch() {
    if (_searchController.text.isNotEmpty) {
      _clearSearch();
      _searchFocusNode.requestFocus();
    } else {
      setState(() {
        _isSearching = true;
        if (_isSearching) {
          _searchFocusNode.requestFocus();
        } else {
          _clearSearch();
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchMovies = null;
    });
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isNotEmpty) {
      try {
        final searchResults = await Api().searchMovies(query);
        setState(() {
          searchMovies = searchResults;
        });
      } catch (e) {
        setState(() {
          searchMovies = [];
        });
      }
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      title: _isSearching ? _buildSearchField() : _buildAppTitle(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Cancel search' : 'Search',
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search movies',
        hintStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white),
      onSubmitted: _performSearch,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildAppTitle() {
    return GlowText(
      'CineNook',
      style: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  Widget _buildMovieSection(String title, Future<List<Movie>> moviesFuture,
      Widget Function(AsyncSnapshot<List<Movie>>) builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        SizedBox(
          child: FutureBuilder(
            future: moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData) {
                return builder(snapshot);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (searchMovies == null) {
      return const SizedBox.shrink();
    } else if (searchMovies!.isEmpty) {
      return Center(
        child: Text('No movies found',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Results',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          GridMovies(
            snapshot:
                AsyncSnapshot.withData(ConnectionState.done, searchMovies!),
          ),
        ],
      );
    }
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMovieSection('Popular Movies', popularMovies,
            (snapshot) => PopularMovies(snapshot: snapshot)),
        _buildMovieSection('Now Playing', nowPlayingMovies,
            (snapshot) => ListMovies(snapshot: snapshot)),
        _buildMovieSection('Upcoming Movies', upcomingMovies,
            (snapshot) => ListMovies(snapshot: snapshot)),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    if (_isSearching) {
      _clearSearch();
      _isSearching = false;
      return false;
    }

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
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isSearching ? _buildSearchResults() : _buildHomeContent(),
          ),
        ),
      ),
    );
  }
}
