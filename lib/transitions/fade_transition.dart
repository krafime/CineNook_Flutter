import 'package:flutter/material.dart';

// Fungsi untuk membuat route dengan transisi fade
Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ));

      return FadeTransition(
        opacity: fadeAnimation,
        child: child,
      );
    },
  );
}
