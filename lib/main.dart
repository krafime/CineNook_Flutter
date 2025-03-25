import 'package:cinenook/api/api.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/movies/movies_bloc.dart';
import 'package:cinenook/blocs/popular_movies/popular_movies_bloc.dart';
import 'package:cinenook/blocs/now_playing_movies/now_playing_movies_bloc.dart';
import 'package:cinenook/blocs/upcoming_movies/upcoming_movies_bloc.dart';
import 'package:cinenook/blocs/similar_movies/similar_movies_bloc.dart';
import 'package:cinenook/router/app_router.dart';
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
    final AuthBloc authBloc = AuthBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => authBloc),
        BlocProvider(create: (_) => MoviesBloc(api: api)),
        BlocProvider(create: (_) => PopularMoviesBloc(api: api)),
        BlocProvider(create: (_) => NowPlayingMoviesBloc(api: api)),
        BlocProvider(create: (_) => UpcomingMoviesBloc(api: api)),
        BlocProvider(create: (_) => SimilarMoviesBloc(api: api)),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(context.read<AuthBloc>());

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'CineNook',
            theme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.system,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
