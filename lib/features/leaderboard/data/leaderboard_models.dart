import '../../../core/avatar_frames.dart';

enum LeaderboardPeriod { week, month, all }

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.reviews,
    required this.reactions,
    this.avatarUrl,
    this.equippedFrame = defaultFrameKey,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int?,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatar'] as String?,
      equippedFrame: json['equipped_frame'] as String? ?? defaultFrameKey,
      reviews: json['reviews'] as int? ?? 0,
      reactions: json['reactions'] as int? ?? 0,
    );
  }

  /// Null when the user has no reactions in the period yet.
  final int? rank;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String equippedFrame;
  final int reviews;
  final int reactions;
}

class LeaderboardBoard {
  const LeaderboardBoard({
    required this.period,
    required this.entries,
    this.me,
  });

  final LeaderboardPeriod period;

  /// Ranked reviewers, best first (the server returns the top 20).
  final List<LeaderboardEntry> entries;

  /// The viewer's own standing, even when they are outside [entries].
  final LeaderboardEntry? me;
}
