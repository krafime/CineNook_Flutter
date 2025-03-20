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

  const HomeAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSubmitted,
    required this.toggleSearch,
    required this.signOut,
    required this.screenWidth,
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

    return AppBar(
      title: isSearching
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
            isSearching ? Icons.close : Icons.search,
            size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
          ),
          onPressed: toggleSearch,
          tooltip: isSearching ? 'Cancel search' : 'Search',
        ),
        if (!isSearching)
          IconButton(
            icon: Icon(
              Icons.logout,
              size: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
            ),
            onPressed: signOut,
            tooltip: 'Logout',
          ),
        SizedBox(width: isLargeScreen ? 24 : (isMediumScreen ? 16 : 8)),
      ],
    );
  }
}
