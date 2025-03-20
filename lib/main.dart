import 'package:cinenook/api/api.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/popular_movies/popular_movies_bloc.dart';
import 'package:cinenook/blocs/now_playing_movies/now_playing_movies_bloc.dart';
import 'package:cinenook/blocs/upcoming_movies/upcoming_movies_bloc.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_bloc.dart';
import 'package:cinenook/screens/detail_screen.dart';
import 'package:cinenook/screens/home_screen.dart';
import 'package:cinenook/screens/login_screen.dart';
import 'package:cinenook/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Api api = Api();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => MoviesBloc(api: api)),
        BlocProvider(create: (context) => PopularMoviesBloc(api: api)),
        BlocProvider(create: (context) => NowPlayingMoviesBloc(api: api)),
        BlocProvider(create: (context) => UpcomingMoviesBloc(api: api)),
        BlocProvider(create: (context) => SimilarMoviesBloc(api: api)),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CineNook',
          theme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.system,
          home: _buildHomeBasedOnAuthState(authState),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/details': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              return _checkAuth(
                context,
                DetailScreen(id: args?['id'] ?? 0),
              );
            },
          },
          onGenerateRoute: (settings) {
            // Handle dynamic detail routes with ID in the path
            if (settings.name?.startsWith('/details/') == true) {
              final id = int.tryParse(settings.name!.split('/').last);
              if (id != null) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) =>
                      _checkAuth(context, DetailScreen(id: id)),
                );
              }
            }
            return null;
          },
        );
      }),
    );
  }

  // Helper method to build the appropriate home screen based on authentication state
  Widget _buildHomeBasedOnAuthState(AuthState state) {
    if (state is AuthInitial || state is AuthLoading) {
      return const SplashScreen();
    } else if (state is Authenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }

  // Auth protection helper - checks if user is authenticated
  Widget _checkAuth(BuildContext context, Widget protectedScreen) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is Authenticated) {
      return protectedScreen;
    } else {
      // Redirect to login page with a slight delay to allow navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });

      // Return a loading widget while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
