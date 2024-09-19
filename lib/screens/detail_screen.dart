import 'package:cinenook/api/api.dart';
import 'package:cinenook/colors.dart';
import 'package:cinenook/constants.dart';
import 'package:cinenook/models/movie_details.dart';
import 'package:cinenook/models/movie_response.dart';
import 'package:cinenook/widgets/list_movies_slider.dart';
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
    _detailMovieFuture = Api().getDetailMovie(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return FutureBuilder<MovieDetail>(
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
                  _buildSliverAppBar(context, movieDetail, constraints),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: constraints.maxWidth > 600
                          ? _buildWideLayout(movieDetail, constraints)
                          : _buildMovieDetails(movieDetail),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No data found'));
            }
          },
        );
      }),
    );
  }

  Widget _buildWideLayout(MovieDetail movieDetail, BoxConstraints constraints) {
    final isWideScreen = constraints.maxWidth > 1200;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          Expanded(
            flex:
                1, // Gunakan flex 2 untuk memberikan lebih banyak ruang ke info film
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTagline(movieDetail.tagline), // Tagline jika ada
                const SizedBox(height: 16),
                _buildOverview(movieDetail), // Sinopsis
                const SizedBox(height: 16),
                if (!isWideScreen)
                  _buildRelatedMovies(
                      movieDetail.id), // Film terkait untuk layar <= 1200
              ],
            ),
          ),
          if (isWideScreen) const SizedBox(width: 16),
          if (isWideScreen)
            Expanded(
              flex:
                  1, // Related movies akan berada di kanan untuk layar lebih dari 1200
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildRelatedMovies(
                      movieDetail.id), // Film terkait untuk layar > 1200
                ],
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, MovieDetail movieDetail,
      BoxConstraints constraints) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: constraints.maxWidth <= 1200
          ? 300
          : 400, // Atur tinggi berdasarkan lebar layar
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackdropImage(movieDetail),
            Container(color: Colors.black.withOpacity(0.7)),
            _buildPosterAndInfo(context, movieDetail, constraints),
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdropImage(MovieDetail movieDetail) {
    return movieDetail.backdropPath.isNotEmpty
        ? Image.network(
            '${Constants.imagePath}${movieDetail.backdropPath}',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Stack(
                fit: StackFit.expand,
                children: [
                  child, // Tetap tampilkan child agar gambar muncul
                  Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ],
              );
            },
          )
        : Image.asset(
            'assets/placeholder.png',
            fit: BoxFit.cover,
          );
  }

  Positioned _buildBackButton(BuildContext context) {
    return Positioned(
      top: 20,
      left: 10,
      child: IconButton(
        icon: Icon(Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Positioned _buildPosterAndInfo(BuildContext context, MovieDetail movieDetail,
      BoxConstraints constraints) {
    return Positioned(
      bottom: 10,
      left: 20,
      right: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoviePoster(movieDetail),
          const SizedBox(width: 16),
          Expanded(
              child: _buildMovieInfo(
                  context, movieDetail, constraints)), // Tambahkan constraints
        ],
      ),
    );
  }

  Widget _buildMoviePoster(MovieDetail movieDetail) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: movieDetail.posterPath.isNotEmpty
          ? Image.network(
              '${Constants.imagePath}${movieDetail.posterPath}',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child, // Tetap tampilkan child agar gambar muncul
                    Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  ],
                );
              },
            )
          : Image.asset(
              'assets/placeholder.png',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
    );
  }

  Widget _buildMovieInfo(BuildContext context, MovieDetail movieDetail,
      BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetail.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildRating(movieDetail),
        const SizedBox(height: 4),
        _buildGenres(movieDetail), // Display genres
        const SizedBox(
            height: 16), // Add spacing between genres and additional details
        if (isSmallScreen)
          _buildAdditionalDetails(
              movieDetail), // Show additional details only on small screens
      ],
    );
  }

  Widget _buildRating(MovieDetail movieDetail) {
    return Row(
      children: [
        const Icon(Icons.star, color: ListColors.ratingColor),
        const SizedBox(width: 4),
        Text('${movieDetail.voteAverage}/10 (${movieDetail.voteCount})',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildGenres(MovieDetail movieDetail) {
    return Wrap(
      spacing: 4,
      runSpacing: kIsWeb ? 4 : -8,
      clipBehavior: Clip.antiAlias,
      children: movieDetail.genres
          .map((genre) => Chip(
                padding: const EdgeInsets.symmetric(horizontal: -3),
                label: Text(genre.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12)),
                backgroundColor: Colors.grey[800],
              ))
          .toList(),
    );
  }

  Widget _buildMovieDetails(MovieDetail movieDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movieDetail.tagline.isNotEmpty) _buildTagline(movieDetail.tagline),
        const SizedBox(height: 8),
        _buildOverview(movieDetail),
        const SizedBox(height: 16),
        _buildAdditionalDetails(movieDetail),
        const SizedBox(height: 16),
        _buildRelatedMovies(movieDetail.id),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagline(String tagline) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          tagline,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(MovieDetail movieDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        Text(movieDetail.overview.isNotEmpty ? movieDetail.overview : 'No data',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
      ],
    );
  }

  Widget _buildAdditionalDetails(MovieDetail movieDetail) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600, // Set your desired maximum width here
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            leftTitle: 'Duration',
            leftValue: movieDetail.runtime > 0
                ? _formatDuration(movieDetail.runtime)
                : 'No data',
            rightTitle: 'Release Date',
            rightValue: DateFormat.yMMMEd().format(movieDetail.releaseDate),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            leftTitle: 'Original Language',
            leftValue: movieDetail.spokenLanguages.isNotEmpty
                ? movieDetail.spokenLanguages.first.name
                : 'No data',
            rightTitle: 'Popularity',
            rightValue: movieDetail.popularity > 0
                ? movieDetail.popularity.toString()
                : 'No data',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoColumn(leftTitle, leftValue),
        _buildInfoColumn(rightTitle, rightValue),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMovies(int id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Movies',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Movie>>(
            future: Api().getSimilarMovies(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Failed to load related movies'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListMovies(
                  snapshot: AsyncSnapshot.withData(
                      ConnectionState.done, snapshot.data!),
                );
              } else {
                return Text('No data found',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface));
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
