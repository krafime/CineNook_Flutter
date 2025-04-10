import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/home_controller.dart';
import 'package:cinenook/widgets/home/app_bar_widget.dart';
import 'package:cinenook/widgets/home/movie_sections.dart';
import 'package:cinenook/widgets/search/search_widget.dart';
import 'package:cinenook/auth/auth_guard_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AuthGuardMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _lastSearchQuery;

  // Use GetX controller
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState(); // AuthGuardMixin will call checkAuthentication()
    _searchController.addListener(_onSearchTextChanged);

    // Load movies data
    _homeController.loadMovies();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
        _lastSearchQuery = null; // Clear last search query
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

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      _homeController.performSearch(query);
      setState(() {
        _lastSearchQuery = query;
      });
    }
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
    if (didPop) {
      return;
    }

    _homeController.handleBackPress(context, _isSearching, () {
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _lastSearchQuery = null; // clear search results query
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });
    });
  }

  Widget _getMovieSections(double screenWidth) {
    // Hapus caching untuk memastikan widget dibangun ulang saat ukuran layar berubah
    return MovieSections(screenWidth: screenWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final maxContentWidth = screenWidth > 1200 ? 1200.0 : double.infinity;

      return PopScope(
        canPop: !_isSearching &&
            _homeController.lastPressed.value != null &&
            DateTime.now().difference(_homeController.lastPressed.value!) <=
                const Duration(seconds: 2),
        onPopInvokedWithResult: _handlePopInvoked,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
                kToolbarHeight + 4), // Reduced extra height
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0), // Reduced top padding
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: HomeAppBar(
                    isSearching: _isSearching,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    onSubmitted: _performSearch,
                    toggleSearch: _toggleSearch,
                    signOut: _homeController.signOut,
                    screenWidth: screenWidth,
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth > 600 ? 8 : 4),
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth > 900
                              ? 32
                              : (screenWidth > 600 ? 24 : 16),
                          right: screenWidth > 900
                              ? 32
                              : (screenWidth > 600 ? 24 : 16),
                          top: screenWidth > 600 ? 24 : 16,
                          bottom: screenWidth > 600 ? 24 : 16,
                        ),
                        child: _isSearching
                            ? SearchWidget(
                                searchController: _searchController,
                                searchFocusNode: _searchFocusNode,
                                performSearch: _performSearch,
                                lastSearchQuery: _lastSearchQuery,
                                screenWidth: screenWidth,
                              )
                            : _getMovieSections(screenWidth),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
