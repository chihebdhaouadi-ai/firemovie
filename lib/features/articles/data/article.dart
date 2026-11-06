/// A published article card, as listed by `GET /api/articles/`.
final class LatestArticle {
  const LatestArticle({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.url,
    required this.publishedAt,
  });

  factory LatestArticle.fromJson(Map<String, dynamic> json) {
    return LatestArticle(
      id: json['id'] as int,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String,
      url: json['url'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  final int id;
  final String title;

  /// Absolute URL of the cover photo.
  final String coverUrl;

  /// Absolute URL of the article page on the Django site.
  final String url;
  final DateTime publishedAt;
}
