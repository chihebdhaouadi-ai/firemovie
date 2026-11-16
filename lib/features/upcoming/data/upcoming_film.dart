/// A film that is not out yet, as listed by `GET /api/upcoming/`.
final class UpcomingFilm {
  const UpcomingFilm({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.releaseDate,
    required this.description,
  });

  factory UpcomingFilm.fromJson(Map<String, dynamic> json) {
    return UpcomingFilm(
      id: json['id'] as int,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String,
      releaseDate: DateTime.parse(json['release_date'] as String),
      description: json['description'] as String? ?? '',
    );
  }

  final int id;
  final String title;

  /// Absolute URL of the poster image.
  final String posterUrl;
  final DateTime releaseDate;
  final String description;
}
