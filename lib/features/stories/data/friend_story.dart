import 'package:equatable/equatable.dart';

import '../../film_reviews/domain/take_tag.dart';

/// What a story item is: a take the friend wrote, or a comment they left.
enum StoryKind { take, comment }

/// One thing a friend made recently, shown as one page of their story.
class StoryItem extends Equatable {
  const StoryItem({
    required this.kind,
    required this.id,
    required this.takeId,
    required this.tag,
    required this.body,
    required this.createdAt,
    this.spoiler = false,
    this.filmId = '',
    this.filmTitle,
    this.posterUrl,
  });

  final StoryKind kind;

  /// The take's or the comment's own id.
  final int id;

  /// The take this item opens (for a comment, the take it was left on).
  final int takeId;
  final TakeTag tag;
  final String body;
  final DateTime createdAt;
  final bool spoiler;
  final String filmId;
  final String? filmTitle;
  final String? posterUrl;

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    final film = json['film'] as Map<String, dynamic>? ?? const {};
    return StoryItem(
      kind: json['kind'] == 'comment' ? StoryKind.comment : StoryKind.take,
      id: json['id'] as int,
      takeId: json['take_id'] as int,
      tag: TakeTag.fromApi(json['tag'] as String?),
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      spoiler: json['spoiler'] as bool? ?? false,
      filmId: film['film_id'] as String? ?? '',
      filmTitle: film['title'] as String?,
      posterUrl: film['poster_url'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [kind, id, takeId, tag, body, createdAt, spoiler, filmId];
}

/// A friend and their recent creations, played oldest first.
class FriendStory extends Equatable {
  const FriendStory({
    required this.userId,
    required this.username,
    required this.items,
    this.avatarUrl,
    this.frame,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? frame;
  final List<StoryItem> items;

  /// When the friend last made something; marks the story as new again.
  DateTime get latestAt => items.last.createdAt;

  factory FriendStory.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return FriendStory(
      userId: user['id'] as int,
      username: user['username'] as String? ?? '',
      avatarUrl: user['avatar'] as String?,
      frame: user['equipped_frame'] as String?,
      items: [
        for (final item in json['items'] as List<dynamic>)
          StoryItem.fromJson(item as Map<String, dynamic>),
      ],
    );
  }

  @override
  List<Object?> get props => [userId, username, avatarUrl, items];
}
