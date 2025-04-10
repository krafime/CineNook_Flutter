import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/scheduler.dart';

class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Observable variables for state management
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  Rxn<User> currentUser = Rxn<User>();

  AuthController({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  void onInit() {
    super.onInit();

    // Configure persistence for web platform
    _configurePersistence();

    // Set up auth state changes listener
    _firebaseAuth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      handleAuthChanges();
    });

    // Check current user on initialization
    checkCurrentUser();
  }

  Future<void> _configurePersistence() async {
    if (kIsWeb) {
      try {
        // Set persistence to LOCAL to maintain the session across page reloads
        await _firebaseAuth.setPersistence(Persistence.LOCAL);
      } catch (e) {
        errorMessage.value = 'Error setting persistence: ${e.toString()}';
      }
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  void checkCurrentUser() {
    isLoading.value = true;

    try {
      // Get current Firebase user
      final user = _firebaseAuth.currentUser;

      // Update current user value atomically to prevent multiple rebuilds
      if (user != null) {
        debugPrint('User already signed in: ${user.displayName}');
        currentUser.value = user;
      } else {
        debugPrint('No user signed in');
        currentUser.value = null;
      }
    } catch (e) {
      debugPrint('Error checking current user: $e');
      currentUser.value = null;
    } finally {
      // Always set loading to false when done
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _firebaseAuth.signOut();
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      errorMessage.value = 'Failed to sign out: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');

        UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        if (userCredential.user == null) {
          errorMessage.value = 'Google sign in failed';
        }
      } else {
        // Mobile implementation
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          isLoading.value = false;
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user == null) {
          errorMessage.value = 'Google sign in failed';
        }
      }
    } catch (e) {
      errorMessage.value = 'Google sign in failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Use a separate non-observable method for navigation logic
  void handleAuthChanges() {
    // Schedule this after the current build cycle
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Navigate based on the current static value, not the observable
      if (isLoggedIn) {
        // Navigate to home if app is already initialized
        if (Get.context != null) {
          // Use context-less navigation to avoid build issues
          Get.offAllNamed('/home');
        }
      } else {
        // Navigate to login if app is already initialized
        if (Get.context != null) {
          Get.offAllNamed('/login');
        }
      }
    });
  }

  // Use this method instead of direct navigation when not in a widget
  Future<void> navigateAfterAuthChange(BuildContext? context) async {
    await Future.delayed(Duration.zero); // Ensure initialization is complete

    try {
      if (context != null && context.mounted) {
        if (isLoggedIn) {
          context.goNamed('home');
        } else {
          context.goNamed('login');
        }
      } else {
        debugPrint('No valid context available for navigation');
      }
    } catch (e) {
      debugPrint('Auth navigation error: $e');
    }
  }
}
