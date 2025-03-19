import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_event.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    timeDilation = 2.5; // 1.0 means normal animation speed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${state.user.displayName ?? 'User'}!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );

            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Define sizes based on width
              final width = constraints.maxWidth;

              // Determine screen size category
              final isSmallScreen = width < 600;
              final isMediumScreen = width >= 600 && width < 900;
              final isLargeScreen = width >= 900;

              // Adjust padding based on screen size
              final horizontalPadding =
                  isSmallScreen ? 24.0 : (isMediumScreen ? 48.0 : 64.0);

              // Adjust logo size based on screen width
              final logoSize =
                  isSmallScreen ? 48.0 : (isMediumScreen ? 64.0 : 72.0);

              // Calculate content width for larger screens
              final contentMaxWidth = isLargeScreen ? 500.0 : width;

              return SafeArea(
                child: Center(
                  // Center everything
                  child: Container(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: isSmallScreen ? 20 : 40),

                            Hero(
                              tag: 'logo',
                              child: GlowText(
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
                            ),

                            Text(
                              'Your Personalized Film Explorer',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),

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

                            // Google Sign In
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isLargeScreen ? 400 : double.infinity,
                              ),
                              alignment: Alignment.center,
                              child: OutlinedButton.icon(
                                icon: Image.asset('assets/google_logo.png',
                                    height: 24),
                                label: Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18),
                                ),
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context
                                            .read<AuthBloc>()
                                            .add(GoogleSignInRequested());
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 12 : 16,
                                    horizontal: isSmallScreen ? 16 : 24,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            if (state is AuthLoading)
                              const Center(child: CircularProgressIndicator()),

                            SizedBox(height: isSmallScreen ? 20 : 40),
                          ],
                        ),
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
