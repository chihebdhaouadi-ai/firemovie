class SocialUser {
  const SocialUser({required this.id, required this.username, this.avatarUrl});

  factory SocialUser.fromJson(Map<String, dynamic> json) => SocialUser(
        id: json['id'] as int,
        username: json['username'] as String,
        avatarUrl: json['avatar'] as String?,
      );

  final int id;
  final String username;
  final String? avatarUrl;
}

class Connections {
  const Connections({
    required this.following,
    required this.followers,
    this.friends = const [],
  });

  factory Connections.fromJson(Map<String, dynamic> json) => Connections(
        following: _users(json['following']),
        followers: _users(json['followers']),
        friends: _users(json['friends']),
      );

  final List<SocialUser> following;
  final List<SocialUser> followers;
  final List<SocialUser> friends;
}

enum NotificationKind { friendRequest, friendAccepted, movieSuggestion }

class MovieSuggestion {
  const MovieSuggestion({
    required this.filmId,
    required this.title,
    this.year,
    this.posterUrl,
    this.comment = '',
  });

  factory MovieSuggestion.fromJson(Map<String, dynamic> json) => MovieSuggestion(
        filmId: '${json['film_id']}',
        title: json['film_title'] as String? ?? '',
        year: json['film_year'] as int?,
        posterUrl: _nonEmpty(json['film_poster_url'] as String?),
        comment: json['comment'] as String? ?? '',
      );

  final String filmId;
  final String title;
  final int? year;
  final String? posterUrl;
  final String comment;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.actor,
    required this.read,
    this.friendRequestId,
    this.suggestion,
  });

  final int id;
  final NotificationKind kind;
  final SocialUser actor;
  final bool read;
  final int? friendRequestId;
  final MovieSuggestion? suggestion;
}

class NotificationsPage {
  const NotificationsPage({required this.unreadCount, required this.items});

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['results'] as List<dynamic>? ?? const []);
    final items = <NotificationItem>[];
    for (final entry in raw) {
      final item = _notification(entry as Map<String, dynamic>);
      if (item != null) items.add(item);
    }
    return NotificationsPage(
      unreadCount: json['unread_count'] as int? ?? 0,
      items: items,
    );
  }

  final int unreadCount;
  final List<NotificationItem> items;
}

List<SocialUser> _users(Object? raw) => [
      for (final entry in (raw as List<dynamic>? ?? const []))
        SocialUser.fromJson(entry as Map<String, dynamic>),
    ];

String? _nonEmpty(String? value) => (value == null || value.isEmpty) ? null : value;

NotificationItem? _notification(Map<String, dynamic> json) {
  final kind = switch (json['kind']) {
    'friend_request' => NotificationKind.friendRequest,
    'friend_accepted' => NotificationKind.friendAccepted,
    'movie_suggestion' => NotificationKind.movieSuggestion,
    _ => null,
  };
  if (kind == null) return null;
  final rawSuggestion = json['suggestion'];
  final suggestion = rawSuggestion is Map<String, dynamic>
      ? MovieSuggestion.fromJson(rawSuggestion)
      : null;
  if (kind == NotificationKind.movieSuggestion && suggestion == null) {
    return null;
  }
  return NotificationItem(
    id: json['id'] as int,
    kind: kind,
    actor: SocialUser.fromJson(json['actor'] as Map<String, dynamic>),
    read: json['read'] as bool? ?? false,
    friendRequestId: json['friend_request_id'] as int?,
    suggestion: suggestion,
  );
}
