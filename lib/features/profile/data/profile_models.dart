enum Friendship { self, none, outgoing, incoming, friends }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.watched,
    required this.watchlist,
    required this.reviews,
    this.bio = '',
    this.avatarUrl,
    this.coverUrl,
    this.followers = 0,
    this.following = 0,
    this.friendship = Friendship.none,
    this.friendRequestId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      watched: stats['watched'] as int,
      watchlist: stats['watchlist'] as int,
      reviews: stats['reviews'] as int,
      bio: (json['bio'] as String?) ?? '',
      avatarUrl: json['avatar'] as String?,
      coverUrl: json['cover'] as String?,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      friendship: _friendshipFrom(json['friendship'] as String?),
      friendRequestId: json['friend_request_id'] as int?,
    );
  }

  final int id;
  final String username;
  final int watched;
  final int watchlist;
  final int reviews;
  final String bio;
  final String? avatarUrl;
  final String? coverUrl;
  final int followers;
  final int following;
  final Friendship friendship;
  final int? friendRequestId;

  UserProfile withFriendship(Friendship state, {int? friendRequestId}) {
    return UserProfile(
      id: id,
      username: username,
      watched: watched,
      watchlist: watchlist,
      reviews: reviews,
      bio: bio,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      followers: followers,
      following: following,
      friendship: state,
      friendRequestId: friendRequestId,
    );
  }
}

Friendship _friendshipFrom(String? value) => switch (value) {
      'self' => Friendship.self,
      'outgoing' => Friendship.outgoing,
      'incoming' => Friendship.incoming,
      'friends' => Friendship.friends,
      _ => Friendship.none,
    };
