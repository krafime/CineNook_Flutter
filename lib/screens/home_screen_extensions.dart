import 'package:cinenook/screens/home_screen.dart';
import 'package:flutter/material.dart';

// This extension allows accessing navigateToDetails from other widgets
extension HomeScreenStateExtension on State {
  // Try to call navigateToDetails if it exists on the state
  void navigateToDetails() {
    try {
      // Use reflection to call the method if it exists
      final methodSymbol = #navigateToDetails;
      if (this is State<HomeScreen> &&
          (this as dynamic).respondsTo(methodSymbol)) {
        (this as dynamic).navigateToDetails();
      }
    } catch (e) {
      // Ignore errors if the method doesn't exist
    }
  }

  bool respondsTo(Symbol methodName) {
    try {
      final mirror = reflect(this);
      return mirror.type.instanceMembers.containsKey(methodName);
    } catch (e) {
      return false;
    }
  }

  dynamic reflect(dynamic object) {
    // Simple reflection stub - you would need to implement this
    // or use a proper reflection library if needed
    return object;
  }
}
