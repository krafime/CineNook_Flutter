import 'package:cinenook/controllers/movie_controller.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _lastSearchQuery;

  // Use GetX controller
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState(); // AuthGuardMixin will call checkAuthentication()
    _searchController.addListener(_onSearchTextChanged);

    // Berikan controller dan focus node ke homeController
    _homeController.setupSearchController(_searchController, _searchFocusNode);

    // Load movies data
    _homeController.loadMovies();

    // Periksa apakah perlu mengaktifkan mode pencarian
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Jika mode pencarian aktif, atur state UI sesuai
      if (_homeController.isSearchModeActive.value &&
          _searchController.text.isNotEmpty) {
        setState(() {
          _lastSearchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();

    // Clear controller references di homeController
    _homeController.clearSearchControllers();

    super.dispose();
  }

  void _onSearchTextChanged() {
    // Use debounced search as user types for better UX
    if (_searchController.text.length >= 3) {
      _homeController.performDebouncedSearch(_searchController.text);
      setState(() {
        _lastSearchQuery = _searchController.text;
      });
    } else if (_searchController.text.isEmpty) {
      // Clear results if search is empty
      _homeController.performDebouncedSearch("");
      setState(() {
        _lastSearchQuery = null;
      });
    }
  }

  void _toggleSearch() {
    if (_homeController.isSearchModeActive.value) {
      // Exit search mode and clear the search query
      _homeController.isSearchModeActive.value = false;
      setState(() {
        _searchController.clear();
        _lastSearchQuery = null; // Clear last search query
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });

      // Reset search results di movie controller
      Get.find<MovieController>().clearSearchResults();
    } else {
      // Enter search mode
      _homeController.isSearchModeActive.value = true;
      setState(() {
        // Request focus after the frame is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
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

    _homeController
        .handleBackPress(context, _homeController.isSearchModeActive.value, () {
      _homeController.isSearchModeActive.value = false;
      setState(() {
        _searchController.clear();
        _lastSearchQuery = null; // clear search results query
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });

      // Reset search results di movie controller saat keluar dari mode pencarian
      Get.find<MovieController>().clearSearchResults();
    });
  }

  // Method untuk menghapus query pencarian tanpa keluar dari mode search
  void _clearSearchQuery() {
    setState(() {
      _searchController.clear();
      _lastSearchQuery = null;
    });
    // Hapus hasil pencarian di movie controller
    Get.find<MovieController>().clearSearchResults();
    // Request focus kembali ke search field agar user dapat langsung mengetik
    _searchFocusNode.requestFocus();
  }

  // Method untuk keluar dari mode search dan kembali ke home
  void _exitSearchMode() {
    _homeController.isSearchModeActive.value = false;
    setState(() {
      _searchController.clear();
      _lastSearchQuery = null;
      if (_searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
    });
    // Reset search results di movie controller
    Get.find<MovieController>().clearSearchResults();
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
        canPop: !_homeController.isSearchModeActive.value &&
            _homeController.lastPressed.value != null &&
            DateTime.now().difference(_homeController.lastPressed.value!) <=
                const Duration(seconds: 2),
        onPopInvokedWithResult: _handlePopInvoked,
        child: Scaffold(
          appBar: HomeAppBar(
            isSearching: _homeController.isSearchModeActive.value,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSubmitted: _performSearch,
            toggleSearch: _toggleSearch,
            signOut: _homeController.signOut,
            screenWidth: screenWidth,
            clearSearchQuery: _clearSearchQuery,
            exitSearchMode: _exitSearchMode,
          ),
          body: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Obx(() => _homeController.isSearchModeActive.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 900
                              ? 32
                              : (screenWidth > 600 ? 24 : 16),
                          vertical: 16.0,
                        ),
                        child: SearchWidget(
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          performSearch: _performSearch,
                          lastSearchQuery: _lastSearchQuery,
                          screenWidth: screenWidth,
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 900
                                ? 32
                                : (screenWidth > 600 ? 24 : 16),
                            vertical: screenWidth > 600 ? 24 : 16,
                          ),
                          child: _getMovieSections(screenWidth),
                        ),
                      )),
              ),
            ),
          ),
        ),
      );
    });
  }
}
