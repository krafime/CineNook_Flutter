class MovieDetail {
  bool adult;
  String backdropPath;
  int budget;
  List<Genre> genres;
  String homepage;
  int id;
  String imdbId;
  List<String> originCountry;
  String originalLanguage;
  String originalTitle;
  String overview;
  double popularity;
  String posterPath;
  DateTime releaseDate;
  int revenue;
  int runtime;
  List<SpokenLanguage> spokenLanguages;
  String status;
  String tagline;
  String title;
  bool video;
  double voteAverage;
  int voteCount;

  MovieDetail({
    required this.adult,
    required this.backdropPath,
    required this.budget,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.imdbId,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.revenue,
    required this.runtime,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'] ?? '',
      budget: json['budget'] ?? 0,
      genres: json['genres'] != null
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x)))
          : [],
      homepage: json['homepage'] ?? '',
      id: json['id'] ?? 0,
      imdbId: json['imdb_id'] ?? '',
      originCountry: json['origin_country'] != null
          ? List<String>.from(json['origin_country'].map((x) => x))
          : [],
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? 'No Title',
      overview: json['overview'],
      popularity: json['popularity'] ?? 0.0,
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : DateTime(1970, 1, 1),
      revenue: json['revenue'] ?? 0,
      runtime: json['runtime'] ?? 0,
      spokenLanguages: json['spoken_languages'] != null
          ? List<SpokenLanguage>.from(
              json['spoken_languages'].map((x) => SpokenLanguage.fromJson(x)))
          : [],
      status: json['status'] ?? 'Unknown',
      tagline: json['tagline'] ?? '',
      title: json['title'] ?? 'No Title',
      video: json['video'] ?? false,
      voteAverage: json['vote_average'] ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}

class Genre {
  int id;
  String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Genre',
    );
  }
}

class SpokenLanguage {
  String englishName;
  String iso6391;
  String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'],
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? 'Unknown Language',
    );
  }
}
