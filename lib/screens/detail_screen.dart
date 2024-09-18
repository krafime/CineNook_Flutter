import 'package:cinenook/api/api.dart';
import 'package:cinenook/colors.dart';
import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<MovieDetail> _detailMovieFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mendapatkan detail film
    _detailMovieFuture = Api().getDetailMovie(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieDetail>(
        future: _detailMovieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load movie details'));
          } else if (snapshot.hasData) {
            final movieDetail = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 300, // Increase AppBar height for more space
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Backdrop Image
                        movieDetail.backdropPath.isNotEmpty
                            ? Image.network(
                                '${Constants.imagePath}${movieDetail.backdropPath}',
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/placeholder.png', // Replace with your asset path
                                fit: BoxFit.cover,
                              ),
                        // Black overlay with opacity
                        Container(
                          color: Colors.black.withOpacity(0.7),
                        ),
                        // Poster, title, rating, and genre on top of backdrop
                        Positioned(
                          bottom: 10,
                          left: 20,
                          right: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie Poster
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: movieDetail.posterPath.isNotEmpty
                                    ? Image.network(
                                        '${Constants.imagePath}${movieDetail.posterPath}',
                                        width: 120,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/placeholder.png', // Replace with your asset path
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Informasi Film
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movieDetail.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: ListColors.ratingColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${movieDetail.voteAverage}/10 (${movieDetail.voteCount})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Genre film
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: kIsWeb ? 4 : -8,
                                      clipBehavior: Clip.antiAlias,
                                      children: [
                                        for (final genre in movieDetail.genres)
                                          Chip(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: -3),
                                            label: Text(
                                              genre.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            backgroundColor: Colors.grey[800],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tombol kembali
                        Positioned(
                          top: 20,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rincian lainnya di bawah AppBar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (movieDetail.tagline.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              movieDetail.tagline,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Overview',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          movieDetail.overview.isNotEmpty
                              ? movieDetail.overview
                              : 'No data',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly, // Gunakan spaceEvenly
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Duration',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        movieDetail.runtime > 0
                                            ? _formatDuration(
                                                movieDetail.runtime)
                                            : 'No data',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Release Date',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMEd()
                                            .format(movieDetail.releaseDate),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 16), // Tambahkan jarak vertikal
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly, // Gunakan spaceEvenly
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Original Language',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        movieDetail.spokenLanguages.first
                                                .englishName.isNotEmpty
                                            ? movieDetail.spokenLanguages.first
                                                .englishName
                                            : 'No data',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Popularity',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        movieDetail.popularity > 0
                                            ? movieDetail.popularity.toString()
                                            : 'No data',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Related Movies',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tambahkan bagian lain seperti film terkait di sini
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

// Tambahkan fungsi ini di dalam class yang sama
String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours > 0) {
    return '${hours}h ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}';
  } else {
    return '${remainingMinutes}m';
  }
}
