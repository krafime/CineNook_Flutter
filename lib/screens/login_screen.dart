import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_event.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  /// Shows a custom snackbar with success/error styling
  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive SnackBar width
    double snackBarWidth = screenWidth < 600
        ? screenWidth * 0.9
        : screenWidth < 900
            ? screenWidth * 0.7
            : 600;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        horizontal: (screenWidth - snackBarWidth) / 2,
        vertical: 20,
      ),
      elevation: 8,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          : () {
              context.read<AuthBloc>().add(GoogleSignInRequested());
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
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _showSnackBar(
                context, 'Welcome, ${state.user.displayName ?? 'User'}!', true);

            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            });
          } else if (state is AuthError) {
            _showSnackBar(context, state.message, false);
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
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

              return SafeArea(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                          if (state is AuthError)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.red[100],
                              child: Text(
                                state.message,
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
                            child: _buildGoogleSignInButton(
                                isSmallScreen, state is AuthLoading),
                          ),

                          const SizedBox(height: 24),

                          // Loading indicator
                          if (state is AuthLoading)
                            const Center(child: CircularProgressIndicator()),

                          SizedBox(height: verticalSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
