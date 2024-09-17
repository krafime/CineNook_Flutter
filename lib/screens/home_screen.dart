import 'package:cinenook/api/api.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/widgets/popular_movies_slider.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> nowPlayingMovies;
  late Future<List<Movie>> upcomingMovies;

  @override
  void initState() {
    super.initState();
    popularMovies = Api().getPopularMovies();
    nowPlayingMovies = Api().getNowPlayingMovies();
    upcomingMovies = Api().getUpcomingPlayingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CineNook'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Popular Movies',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12), // Divider
                SizedBox(
                  child: FutureBuilder(
                      future: popularMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          return PopularMovies(snapshot: snapshot);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                const SizedBox(height: 32), // Divider
                Text('Now Playing',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12), // Divider
                SizedBox(
                  child: FutureBuilder(
                      future: nowPlayingMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          return ListMovies(snapshot: snapshot);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                const SizedBox(height: 32), // Divider
                Text("Upcoming Movies",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12), // Divider
                SizedBox(
                  child: FutureBuilder(
                      future: upcomingMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (snapshot.hasData) {
                          return ListMovies(snapshot: snapshot);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
