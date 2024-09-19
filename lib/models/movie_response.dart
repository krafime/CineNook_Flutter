class MovieResponse {
  int page;
  List<Movie> movies;
  int totalPages;
  int totalResults;

  MovieResponse({
    required this.page,
    required this.movies,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      page: json['page'] ?? 0,
      movies: (json['results'] != null)
          ? List<Movie>.from(json['results'].map((x) => Movie.fromJson(x)))
          : [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

class Movie {
  int id;
  String? originalTitle;
  String? posterPath;
  String? title;

  Movie({
    required this.id,
    this.posterPath,
    this.originalTitle,
    this.title,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      posterPath: json['poster_path'],
      originalTitle: json['original_title'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poster_path': posterPath,
        'original_title': originalTitle,
        'title': title,
      };
}
