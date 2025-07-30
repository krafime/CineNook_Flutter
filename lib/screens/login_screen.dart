import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cinenook/controllers/js_interop.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // GetX controller untuk autentikasi
  final AuthController authController = Get.find<AuthController>();

  // Animation controller untuk loading indicator
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Reset state saat masuk screen login
    authController.isLoading.value = false;
    authController.errorMessage.value = '';

    // Setup listener untuk perubahan user
    _setupAuthListeners();

    // Cek apakah user sudah login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isLoggedIn) {
        _navigateToHome();
      } else {
        _checkJsLoginState();
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  // Cek status login di JavaScript
  void _checkJsLoginState() {
    if (!kIsWeb) return;

    try {
      // Menggunakan helper method dari JS untuk cek login
      final isLoggedInJs = isUserLoggedInJs();
      if (isLoggedInJs) {
        debugPrint('User terdeteksi login via JavaScript, mengarahkan ke home');
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('Error checking JS login state: $e');
    }
  }

  // Navigasi ke home screen
  void _navigateToHome() {
    try {
      context.go('/');
    } catch (e) {
      debugPrint('Error navigasi: $e');

      // Fallback: navigasi langsung via JavaScript jika di web
      if (kIsWeb) {
        navigateToHomeJs();
      }
    }
  }

  // Setup listener untuk state autentikasi
  void _setupAuthListeners() {
    // Listen untuk perubahan user
    ever(authController.currentUser, (user) {
      if (user != null) {
        // User login berhasil, navigasi ke home
        _navigateToHome();
      }
    });

    // Listen untuk pesan error
    ever(authController.errorMessage, (message) {
      // Error handling sudah ditangani di UI dengan Obx
    });
  }

  /// Builds the logo section with app name and tagline
  Widget _buildLogoSection(double logoSize, bool isSmallScreen) {
    return Column(
      children: [
        GlowText(
          'CineNook',
          style: GoogleFonts.poppins(
            fontSize: logoSize,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.center,
          glowColor: Colors.red,
        ),
        Text(
          'Your Personalized Film Explorer',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the Google sign-in button
  Widget _buildGoogleSignInButton(bool isSmallScreen, bool isLoading) {
    return OutlinedButton.icon(
      icon: Image.asset('assets/google_logo.png', height: 24),
      label: Text(
        'Sign in with Google',
        style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
      ),
      onPressed: isLoading
          ? null
          : () async {
              await authController.signInWithGoogle();
            },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 16 : 24,
        ),
      ),
    );
  }

  /// Builds loading indicator dengan animasi
  Widget _buildLoadingIndicator() {
    return Obx(() {
      final isSigningIn = authController.isSigningIn.value;
      final progress = authController.signInProgress.value;

      if (!isSigningIn) return const SizedBox.shrink();

      return Column(
        children: [
          const SizedBox(height: 24),
          // Progress bar animasi
          LinearProgressIndicator(
            value: progress > 0 ? progress : null,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 16),
          // Teks loading dengan animasi titik
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getLoadingMessage(progress),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              _buildLoadingDots(),
            ],
          ),
        ],
      );
    });
  }

  // Animated loading dots
  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final position = _loadingController.value - delay;
            final opacity = position > 0.0 && position < 1.0
                ? position < 0.5
                    ? position * 2
                    : (1.0 - position) * 2
                : 0.3;

            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: opacity,
                child: const Text(
                  '.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Helper untuk mendapatkan pesan loading berdasarkan progress
  String _getLoadingMessage(double progress) {
    if (progress < 0.3) return 'Starting login';
    if (progress < 0.6) return 'Getting account';
    if (progress < 0.9) return 'Authenticating';
    return 'Finishing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ukuran responsif
          final width = constraints.maxWidth;
          final isSmallScreen = width < 600;
          final isMediumScreen = width >= 600 && width < 900;
          final isLargeScreen = width >= 900;

          final horizontalPadding =
              isSmallScreen ? 24.0 : (isMediumScreen ? 48.0 : 64.0);
          final logoSize =
              isSmallScreen ? 48.0 : (isMediumScreen ? 64.0 : 72.0);
          final contentMaxWidth = isLargeScreen ? 500.0 : width;
          final verticalSpacing = isSmallScreen ? 20.0 : 40.0;

          return SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: verticalSpacing),

                      // Logo dan judul
                      _buildLogoSection(logoSize, isSmallScreen),

                      SizedBox(height: isSmallScreen ? 36 : 48),

                      // Pesan error - menggunakan Obx untuk UI reaktif
                      Obx(() {
                        final errorMessage = authController.errorMessage.value;
                        if (errorMessage.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.red.shade200)),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }),

                      // Google Sign In Button
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 400 : double.infinity,
                        ),
                        alignment: Alignment.center,
                        child: Obx(() => _buildGoogleSignInButton(
                            isSmallScreen,
                            authController.isLoading.value ||
                                authController.isSigningIn.value)),
                      ),

                      // Loading indicator
                      _buildLoadingIndicator(),

                      SizedBox(height: verticalSpacing),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
