class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final int runtime;
  final DateTime? releaseDate;
  final double popularity;
  final List<Genre> genres;
  final List<SpokenLanguage> spokenLanguages;
  final String tagline;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    this.releaseDate,
    required this.popularity,
    required this.genres,
    required this.spokenLanguages,
    required this.tagline,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    DateTime? parsedReleaseDate;

    // Safely parse the release date
    if (json['release_date'] != null &&
        json['release_date'].toString().isNotEmpty) {
      try {
        parsedReleaseDate = DateTime.parse(json['release_date'].toString());
      } catch (e) {
        throw Exception('Failed to parse release date: ${e.toString()}');
        // Keep parsedReleaseDate as null if parsing fails
      }
    }

    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      runtime: json['runtime'] ?? 0,
      releaseDate: parsedReleaseDate,
      popularity: (json['popularity'] ?? 0).toDouble(),
      genres: json['genres'] != null
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x)))
          : [],
      spokenLanguages: json['spoken_languages'] != null
          ? List<SpokenLanguage>.from(
              json['spoken_languages'].map((x) => SpokenLanguage.fromJson(x)))
          : [],
      tagline: json['tagline'] ?? '',
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SpokenLanguage {
  final String name;

  SpokenLanguage({
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      name: json['english_name'] ?? json['name'] ?? '',
    );
  }
}
