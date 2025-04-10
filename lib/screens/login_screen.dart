import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Use GetX controller instead of BLoC
  final AuthController authController = Get.find<AuthController>();

  // Track if welcome message has been shown
  bool _welcomeMessageShown = false;
  // Track if error message has been shown
  String? _lastShownErrorMessage;

  @override
  void initState() {
    super.initState();

    // Reset loading state and error message when login screen initializes
    authController.isLoading.value = false;
    authController.errorMessage.value = '';

    // Setup auth listeners outside of build method
    // Move listener setup to initState
    _setupAuthListeners();

    // Check if user is already authenticated - with a post-frame callback
    // Use Future.microtask instead of addPostFrameCallback to avoid build phase issues
    Future.microtask(() {
      if (authController.isLoggedIn && mounted) {
        // Delay navigation slightly to avoid build phase conflicts
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) context.goNamed('home');
        });
      }
    });
  }

  void _setupAuthListeners() {
    // Listen for changes in the current user
    ever(authController.currentUser, (user) {
      if (user != null && !_welcomeMessageShown) {
        _welcomeMessageShown = true;
        // _showSnackBar(context, 'Welcome, ${user.displayName ?? 'User'}!', true);

        // Navigation after successful login - use Go Router instead of Get.offNamed
        // Use microtask instead of direct navigation to avoid build phase issues
        Future.microtask(() {
          if (mounted) {
            // Delay navigation slightly to avoid build phase conflicts
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                // Use Go Router which works with GetMaterialApp.router
                if (mounted) {
                  context.goNamed('home');
                  authController.isLoading.value = false;
                }
              } catch (e) {
                debugPrint('Navigation error: $e');
                // Fallback navigation using standard Navigator
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              }
            });
          }
        });
      } else if (user == null) {
        // Reset loading state when user is null (logged out)
        authController.isLoading.value = false;
      }
    });

    // Listen for error messages
    ever(authController.errorMessage, (message) {
      if (message.isNotEmpty && _lastShownErrorMessage != message) {
        _lastShownErrorMessage = message;
        // _showSnackBar(context, message, false);
      }
    });
  }

  // /// Shows a custom snackbar with success/error styling
  // void _showSnackBar(BuildContext context, String message, bool isSuccess) {
  //   // Don't show SnackBar during build
  //   if (!mounted) return;

  //   final screenWidth = MediaQuery.of(context).size.width;

  //   // Calculate responsive SnackBar width
  //   double snackBarWidth = screenWidth < 600
  //       ? screenWidth * 0.9
  //       : screenWidth < 900
  //           ? screenWidth * 0.7
  //           : 600;

  //   final snackBar = SnackBar(
  //     content: Row(
  //       children: [
  //         Icon(
  //           isSuccess ? Icons.check_circle : Icons.error_outline,
  //           color: Colors.white,
  //           size: 24,
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Text(
  //             message,
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //         ),
  //       ],
  //     ),
  //     backgroundColor: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
  //     behavior: SnackBarBehavior.floating,
  //     duration: const Duration(seconds: 3),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     margin: EdgeInsets.symmetric(
  //       horizontal: (screenWidth - snackBarWidth) / 2,
  //       vertical: 20,
  //     ),
  //     elevation: 8,
  //     action: SnackBarAction(
  //       label: 'DISMISS',
  //       textColor: Colors.white,
  //       onPressed: () {
  //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //       },
  //     ),
  //   );

  //   // Show SnackBar using post-frame callback to avoid build-time issues
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //   });
  // }

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

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder instead of Obx to avoid GetX error
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define responsive sizes
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

          // Directly use values from our controller without Obx wrapper
          final isLoading = authController.isLoading.value;
          final errorMessage = authController.errorMessage.value;

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

                      // Logo and app title
                      _buildLogoSection(logoSize, isSmallScreen),

                      SizedBox(height: isSmallScreen ? 36 : 48),

                      // Error message
                      if (errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.red[100],
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Google Sign In Button
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 400 : double.infinity,
                        ),
                        alignment: Alignment.center,
                        child:
                            _buildGoogleSignInButton(isSmallScreen, isLoading),
                      ),

                      const SizedBox(height: 24),

                      // Loading indicator
                      if (isLoading)
                        const Center(child: CircularProgressIndicator()),

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
