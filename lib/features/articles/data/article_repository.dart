import '../../find/data/api_client.dart';
import 'article.dart';

abstract class ArticleRepository {
  Future<List<LatestArticle>> fetchLatest();
}

class ApiArticleRepository implements ArticleRepository {
  ApiArticleRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<LatestArticle>> fetchLatest() async {
    final items = await _client.getList('/api/articles/');
    return items.map(LatestArticle.fromJson).toList(growable: false);
  }
}
