import '../../../core/avatar_frames.dart';

enum Friendship { self, none, outgoing, incoming, friends }

/// One achievement, badge or frame with its progress towards unlocking.
class ProgressItem {
  const ProgressItem({
    required this.key,
    required this.current,
    required this.target,
    required this.unlocked,
    this.available = true,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      key: json['key'] as String,
      current: json['current'] as int? ?? 0,
      target: json['target'] as int? ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
    );
  }

  final String key;
  final int current;
  final int target;
  final bool unlocked;

  /// False when the server cannot track this item yet (no data behind it).
  final bool available;

  double get fraction {
    if (target <= 0) return 1;
    return (current / target).clamp(0, 1).toDouble();
  }
}

class ProfileProgress {
  const ProfileProgress({
    required this.level,
    required this.xp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.reviews,
    required this.reactions,
    required this.comments,
    required this.achievements,
    required this.badges,
    required this.frames,
  });

  factory ProfileProgress.fromJson(Map<String, dynamic> json) {
    List<ProgressItem> items(String key) => [
          for (final item in json[key] as List<dynamic>? ?? const [])
            ProgressItem.fromJson(item as Map<String, dynamic>),
        ];

    return ProfileProgress(
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpIntoLevel: json['xp_into_level'] as int? ?? 0,
      xpForNextLevel: json['xp_for_next_level'] as int? ?? 0,
      reviews: json['reviews'] as int? ?? 0,
      reactions: json['reactions'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      achievements: items('achievements'),
      badges: items('badges'),
      frames: items('frames'),
    );
  }

  static const empty = ProfileProgress(
    level: 1,
    xp: 0,
    xpIntoLevel: 0,
    xpForNextLevel: 0,
    reviews: 0,
    reactions: 0,
    comments: 0,
    achievements: [],
    badges: [],
    frames: [],
  );

  final int level;
  final int xp;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final int reviews;
  final int reactions;
  final int comments;
  final List<ProgressItem> achievements;
  final List<ProgressItem> badges;
  final List<ProgressItem> frames;

  double get levelFraction {
    if (xpForNextLevel <= 0) return 1;
    return (xpIntoLevel / xpForNextLevel).clamp(0, 1).toDouble();
  }

  /// Whether the given frame key can be equipped.
  bool frameUnlocked(String key) {
    for (final frame in frames) {
      if (frame.key == key) return frame.unlocked;
    }
    return key == defaultFrameKey;
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.watched,
    required this.watchlist,
    required this.reviews,
    this.bio = '',
    this.avatarUrl,
    this.followers = 0,
    this.following = 0,
    this.friendship = Friendship.none,
    this.friendRequestId,
    this.equippedFrame = defaultFrameKey,
    this.progress = ProfileProgress.empty,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final progress = json['progress'];
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      watched: stats['watched'] as int,
      watchlist: stats['watchlist'] as int,
      reviews: stats['reviews'] as int,
      bio: (json['bio'] as String?) ?? '',
      avatarUrl: json['avatar'] as String?,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      friendship: _friendshipFrom(json['friendship'] as String?),
      friendRequestId: json['friend_request_id'] as int?,
      equippedFrame: json['equipped_frame'] as String? ?? defaultFrameKey,
      progress: progress is Map<String, dynamic>
          ? ProfileProgress.fromJson(progress)
          : ProfileProgress.empty,
    );
  }

  final int id;
  final String username;
  final int watched;
  final int watchlist;
  final int reviews;
  final String bio;
  final String? avatarUrl;
  final int followers;
  final int following;
  final Friendship friendship;
  final int? friendRequestId;
  final String equippedFrame;
  final ProfileProgress progress;

  UserProfile withFriendship(Friendship state, {int? friendRequestId}) {
    return UserProfile(
      id: id,
      username: username,
      watched: watched,
      watchlist: watchlist,
      reviews: reviews,
      bio: bio,
      avatarUrl: avatarUrl,
      followers: followers,
      following: following,
      friendship: state,
      friendRequestId: friendRequestId,
      equippedFrame: equippedFrame,
      progress: progress,
    );
  }

  UserProfile withEquippedFrame(String frame) {
    return UserProfile(
      id: id,
      username: username,
      watched: watched,
      watchlist: watchlist,
      reviews: reviews,
      bio: bio,
      avatarUrl: avatarUrl,
      followers: followers,
      following: following,
      friendship: friendship,
      friendRequestId: friendRequestId,
      equippedFrame: frame,
      progress: progress,
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
