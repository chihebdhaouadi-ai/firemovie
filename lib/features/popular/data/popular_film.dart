/// A film added to watched or watchlist often this week, from
/// `GET /api/films/popular/`.
final class PopularFilm {
  const PopularFilm({
    required this.filmId,
    required this.title,
    required this.adds,
    this.year,
    this.posterUrl,
  });

  factory PopularFilm.fromJson(Map<String, dynamic> json) {
    return PopularFilm(
      filmId: json['film_id'] as String,
      title: (json['title'] as String?) ?? '',
      year: json['year'] as int?,
      posterUrl: json['poster_url'] as String?,
      adds: json['adds'] as int,
    );
  }

  final String filmId;
  final String title;
  final int? year;
  final String? posterUrl;

  /// How many watched or watchlist adds this film got in the last week.
  final int adds;
}
