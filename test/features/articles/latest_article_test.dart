import 'package:film_wise_mobile/features/articles/data/article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an article card from the API', () {
    final article = LatestArticle.fromJson({
      'id': 7,
      'title': 'Cannes Diary',
      'slug': 'cannes-diary',
      'cover_url': 'https://example.com/cover.jpg',
      'url': 'https://example.com/articles/cannes-diary/',
      'published_at': '2026-11-05T10:00:00Z',
    });

    expect(article.id, 7);
    expect(article.title, 'Cannes Diary');
    expect(article.coverUrl, 'https://example.com/cover.jpg');
    expect(article.url, 'https://example.com/articles/cannes-diary/');
    expect(article.publishedAt.toUtc(), DateTime.utc(2026, 11, 5, 10));
  });
}
