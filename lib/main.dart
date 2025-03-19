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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CineNook',
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashScreen();
            } else if (state is Authenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/details': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return DetailScreen(id: args['id']);
          },
        },
        onGenerateRoute: (settings) {
          // Handle dynamic detail routes with ID in the path
          if (settings.name?.startsWith('/details/') == true) {
            final id = int.tryParse(settings.name!.split('/').last);
            if (id != null) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => DetailScreen(id: id),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
