import 'package:flutter/material.dart';
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
  late HomeController _homeController;

  @override
  void initState() {
    super.initState(); // AuthGuardMixin will call checkAuthentication()
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeController = HomeController(context);
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

    _homeController.handleBackPress(_isSearching, () {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final maxContentWidth = screenWidth > 1200 ? 1200.0 : double.infinity;

      return PopScope(
        canPop: !_isSearching &&
            _homeController.lastPressed != null &&
            DateTime.now().difference(_homeController.lastPressed!) <=
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
            // Added SafeArea
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    // Wrapped with Column to add SizedBox
                    children: [
                      SizedBox(
                          height: screenWidth > 600
                              ? 8
                              : 4), // Reduced space at top
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth > 900
                              ? 32
                              : (screenWidth > 600 ? 24 : 16),
                          right: screenWidth > 900
                              ? 32
                              : (screenWidth > 600 ? 24 : 16),
                          top: screenWidth > 600
                              ? 24
                              : 16, // Reduced top padding
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
                            : MovieSections(screenWidth: screenWidth),
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
