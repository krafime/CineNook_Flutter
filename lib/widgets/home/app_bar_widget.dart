import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_glow/flutter_glow.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSubmitted;
  final VoidCallback toggleSearch;
  final VoidCallback signOut;
  final double screenWidth;
  final VoidCallback clearSearchQuery;
  final VoidCallback exitSearchMode;

  const HomeAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSubmitted,
    required this.toggleSearch,
    required this.signOut,
    required this.screenWidth,
    required this.clearSearchQuery,
    required this.exitSearchMode,
  });

  @override
  Size get preferredSize {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    return Size.fromHeight(isLargeScreen ? 80 : (isMediumScreen ? 70 : 60));
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      focusNode: searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search movies',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildAppTitle(double fontSize) {
    return GlowText(
      'CineNook',
      style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.red,
          decoration: TextDecoration.none),
      glowColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    final maxContentWidth = screenWidth > 1200 ? 1200.0 : double.infinity;

    // Horizontal padding that matches content padding
    final horizontalPadding =
        screenWidth > 900 ? 32.0 : (screenWidth > 600 ? 24.0 : 16.0);

    if (isLargeScreen) {
      // For large screens, use centered layout with title in center
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Add back button if in search mode (left side)
                if (isSearching)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 32,
                      ),
                      onPressed: exitSearchMode,
                      tooltip: 'Back to home',
                      padding: const EdgeInsets.all(8.0),
                    ),
                  ),

                // Centered title or search field
                Center(
                  child: isSearching
                      ? SizedBox(
                          width: maxContentWidth * 0.5,
                          child: _buildSearchField(),
                        )
                      : _buildAppTitle(42.0),
                ),

                // Right-aligned action buttons
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSearching)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 32,
                          ),
                          onPressed: clearSearchQuery,
                          tooltip: 'Clear search',
                          padding: const EdgeInsets.all(8.0),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            size: 32,
                          ),
                          onPressed: toggleSearch,
                          tooltip: 'Search',
                          padding: const EdgeInsets.all(8.0),
                        ),
                      if (!isSearching) const SizedBox(width: 8),
                      if (!isSearching)
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 32,
                          ),
                          onPressed: signOut,
                          tooltip: 'Logout',
                          padding: const EdgeInsets.all(8.0),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // For small and medium screens, use standard row layout
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isMediumScreen ? 70 : 60,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button or app title
                if (isSearching)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: isMediumScreen ? 28 : 24,
                    ),
                    onPressed: exitSearchMode,
                    tooltip: 'Back to home',
                    padding: const EdgeInsets.all(8.0),
                  )
                else
                  _buildAppTitle(isMediumScreen ? 36.0 : 32.0),

                // Search field (only in search mode)
                if (isSearching)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchField(),
                    ),
                  ),

                // Action buttons with proper spacing
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSearching)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: isMediumScreen ? 28 : 24,
                        ),
                        onPressed: clearSearchQuery,
                        tooltip: 'Clear search',
                        padding: const EdgeInsets.all(8.0),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          size: isMediumScreen ? 28 : 24,
                        ),
                        onPressed: toggleSearch,
                        tooltip: 'Search',
                        padding: const EdgeInsets.all(8.0),
                      ),
                    if (!isSearching) const SizedBox(width: 8),
                    if (!isSearching)
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          size: isMediumScreen ? 28 : 24,
                        ),
                        onPressed: signOut,
                        tooltip: 'Logout',
                        padding: const EdgeInsets.all(8.0),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
