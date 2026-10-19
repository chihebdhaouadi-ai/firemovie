import '../../find/data/api_client.dart';
import '../../find/data/movie.dart';
import 'social_models.dart';

class SocialRepository {
  SocialRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<SocialUser>> searchUsers(String query) async {
    final rows = await _client.getList(
      '/api/social/users/search',
      query: {'q': query},
    );
    return [for (final row in rows) SocialUser.fromJson(row)];
  }

  Future<Connections> connections() async {
    final json = await _client.getJson('/api/social/me/connections');
    return Connections.fromJson(json);
  }

  Future<int> sendFriendRequest(int userId) async {
    final json = await _client.postJson(
      '/api/social/friend-requests',
      body: {'user_id': userId},
    );
    return json['id'] as int;
  }

  Future<void> acceptFriendRequest(int requestId) {
    return _client.postNoContent('/api/social/friend-requests/$requestId/accept');
  }

  Future<void> declineFriendRequest(int requestId) {
    return _client.postNoContent('/api/social/friend-requests/$requestId/decline');
  }

  Future<void> cancelFriendRequest(int requestId) {
    return _client.postNoContent('/api/social/friend-requests/$requestId/cancel');
  }

  Future<NotificationsPage> notifications() async {
    final json = await _client.getJson('/api/social/notifications');
    return NotificationsPage.fromJson(json);
  }

  Future<void> markNotificationsRead() {
    return _client.postNoContent('/api/social/notifications/read');
  }

  Future<int> sendMovieSuggestion({
    required Movie movie,
    required String comment,
    required List<int> recipientIds,
  }) async {
    final json = await _client.postJson(
      '/api/social/movie-suggestions',
      body: {
        'film_id': movie.id,
        'film_title': movie.title,
        'film_year': movie.year,
        'film_poster_url': movie.posterUrl ?? '',
        'comment': comment,
        'recipient_ids': recipientIds,
      },
    );
    return json['sent'] as int;
  }
}
