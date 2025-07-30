import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Get auth controller instance
  final AuthController authController = Get.find<AuthController>();

  // Track animation and navigation state
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final RxBool _isReadyToNavigate = false.obs;

  // Special handling for web to avoid unnecessary splash screen
  final bool _isWeb = kIsWeb;

  // Track auth sync attempts
  bool _didAttemptAuthSync = false;

  @override
  void initState() {
    super.initState();

    // Reset loading state when splash screen initializes
    authController.isLoading.value = false;

    // Check user authentication status - this method is now public in AuthController
    authController.checkCurrentUser();

    // For web, force auth sync with JavaScript
    if (kIsWeb) {
      _forceAuthSync();
    }

    // Set up animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Move all the setup of reaction observers to post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationObservers();

      // For web, use a shorter delay
      final splashDuration = _isWeb ? 800 : 2000;

      // Set a minimum display time for splash screen
      Future.delayed(Duration(milliseconds: splashDuration), () {
        _isReadyToNavigate.value = true;
        _checkAndNavigate();
      });
    });
  }

  // Force authentication sync with JavaScript
  Future<void> _forceAuthSync() async {
    if (!_didAttemptAuthSync) {
      _didAttemptAuthSync = true;
      debugPrint('Attempting to force auth sync from splash screen');
      await authController.forceAuthSyncWithJS();
    }
  }

  void _setupNavigationObservers() {
    // For web, we want to navigate almost immediately without showing the splash for too long
    if (_isWeb) {
      // Listen for auth controller changes
      ever(authController.currentUser, (_) {
        if (_isReadyToNavigate.value && !authController.isLoading.value) {
          // Use schedulerBinding to safely perform navigation after build completes
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _checkAndNavigate();
          });
        }
      });
    }

    // Listen for changes in authentication loading state
    ever(authController.isLoading, (isLoading) {
      if (_isReadyToNavigate.value && !isLoading) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _checkAndNavigate();
        });
      }
    });

    // Listen for changes in ready-to-navigate state
    ever(_isReadyToNavigate, (_) {
      if (_isReadyToNavigate.value && !authController.isLoading.value) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _checkAndNavigate();
        });
      }
    });
  }

  void _checkAndNavigate() {
    if (!mounted) return;

    // Only navigate if minimum time has passed
    if (_isReadyToNavigate.value) {
      // If auth state is already determined (not loading)
      if (!authController.isLoading.value) {
        if (kIsWeb && !_didAttemptAuthSync) {
          // Ensure we've tried to sync auth state before navigating
          _forceAuthSync().then((_) {
            _navigateToNextScreen();
          });
        } else {
          _navigateToNextScreen();
        }
      }
      // If still loading, wait for it to complete via the auth listener
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Get a stable snapshot of the current state to avoid reactivity issues
    final bool isUserLoggedIn = authController.isLoggedIn;
    debugPrint('Navigating from splash. User logged in: $isUserLoggedIn');

    // Defer navigation to after the current build cycle
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        if (isUserLoggedIn) {
          // Use GoRouter directly which is safe with GetMaterialApp.router
          context.goNamed('home');
        } else {
          context.goNamed('login');
        }
      } catch (e) {
        debugPrint('Navigation error: $e');

        // If the Go Router navigation fails, try a safer approach
        // that doesn't use contextless navigation
        Future.microtask(() {
          if (mounted) {
            if (isUserLoggedIn) {
              Navigator.of(context).pushReplacementNamed('/');
            } else {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build method should not contain any observers or navigation logic
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withRed(30),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GlowText(
                        'CineNook',
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        glowColor: Colors.red.withAlpha(50),
                        blurRadius: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Your Personalized Film Explorer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
