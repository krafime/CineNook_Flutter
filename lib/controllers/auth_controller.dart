import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

// Import JS hanya untuk web
import 'js_interop.dart';

class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  Rxn<User> currentUser = Rxn<User>();
  var isSigningIn = false.obs;
  var signInProgress = 0.0.obs; // 0.0 to 1.0 for loading animation

  // Flag untuk mencegah navigasi ganda
  var _isNavigating = false;

  @override
  void onInit() {
    super.onInit();

    // Set up auth state listener
    _firebaseAuth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      _handleNavigation();
    });

    // Setup web JS callback
    if (kIsWeb) {
      _setupJsCallbacks();
    }

    // Check current user
    checkCurrentUser();
  }

  // Fungsi untuk mengatur callback dari JavaScript
  void _setupJsCallbacks() {
    // Setup callback JS->Flutter
    setupJsCallback();

    // Definisikan handler untuk callback
    if (kIsWeb) {
      // Fungsi yang akan dipanggil ketika ada event dari JavaScript
      authCallbackHandler(String type, String? userDataJson) {
        if (type == 'SIGNED_IN' && userDataJson != null) {
          _reloadFirebaseUser();
          signInProgress.value = 1.0;
          isSigningIn.value = false;
          _forceNavigateToHome(); // Ini adalah pemanggilan metode yang sebelumnya tidak direferensikan
        } else if (type == 'SIGNED_OUT') {
          currentUser.value = null;
        }
      }

      // Register callback handler ke JavaScript
      registerJsAuthCallback(authCallbackHandler);
    }
  }

  // Method untuk memeriksa user saat ini
  void checkCurrentUser() {
    isLoading.value = true;
    try {
      // Periksa Firebase Auth
      final user = _firebaseAuth.currentUser;
      currentUser.value = user;

      // Jika di web dan user null, cek localStorage
      if (kIsWeb && user == null) {
        _checkJsUserLogin();
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  // Periksa status login di JavaScript (web only)
  void _checkJsUserLogin() {
    if (!kIsWeb) return;

    try {
      final isLoggedIn = isUserLoggedInJs();
      if (isLoggedIn) {
        _reloadFirebaseUser();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Reload Firebase user
  Future<void> _reloadFirebaseUser() async {
    try {
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.reload();
        currentUser.value = _firebaseAuth.currentUser;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Force navigasi ke home (untuk web)
  void _forceNavigateToHome() {
    // Langsung gunakan JavaScript untuk navigasi
    if (kIsWeb) {
      try {
        navigateToHomeJs();
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Handle navigasi berdasarkan auth state
  void _handleNavigation() {
    if (_isNavigating) return;
    _isNavigating = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        final bool isLoggedIn = currentUser.value != null;

        if (Get.context != null && Get.context!.mounted) {
          final context = Get.context!;
          final router = GoRouter.of(context);

          if (isLoggedIn) {
            router.go('/');
          } else {
            router.go('/login');
          }
        }
      } catch (e) {
        // Fallback untuk web: gunakan JavaScript
        if (kIsWeb) {
          final isLoggedIn = currentUser.value != null;
          final route = isLoggedIn ? '/' : '/login';
          navigateToRouteJs(route);
        }
      } finally {
        Future.delayed(const Duration(milliseconds: 300), () {
          _isNavigating = false;
        });
      }
    });
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    isSigningIn.value = true;
    signInProgress.value = 0.3;
    errorMessage.value = '';

    try {
      if (kIsWeb) {
        // Web: gunakan JavaScript untuk login
        loginWithGoogleJs();
      } else {
        // Mobile implementation
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          isLoading.value = false;
          isSigningIn.value = false;
          signInProgress.value = 0.0;
          return;
        }

        signInProgress.value = 0.6;
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        signInProgress.value = 0.8;
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        signInProgress.value = 1.0;
        currentUser.value = userCredential.user;
        isSigningIn.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Login gagal: ${e.toString()}';
      signInProgress.value = 0.0;
      isSigningIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    isLoading.value = true;

    try {
      await _firebaseAuth.signOut();
      if (!kIsWeb && _googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      if (kIsWeb) {
        signOutFromGoogleJs();
      }

      currentUser.value = null;
    } catch (e) {
      errorMessage.value = 'Sign out failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Getter for convenience
  bool get isLoggedIn => currentUser.value != null;

  // Untuk SplashScreen
  Future<void> forceAuthSyncWithJS() async {
    if (!kIsWeb) return;
    _checkJsUserLogin();
  }
}
