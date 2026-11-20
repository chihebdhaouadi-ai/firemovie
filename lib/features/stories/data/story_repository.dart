import 'package:shared_preferences/shared_preferences.dart';

import '../../find/data/api_client.dart';
import 'friend_story.dart';

/// Where friends' stories come from.
abstract interface class StoryRepository {
  /// Each friend's takes and comments from the last week, newest friend first.
  Future<List<FriendStory>> fetchFriendStories();
}

class ApiStoryRepository implements StoryRepository {
  ApiStoryRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<FriendStory>> fetchFriendStories() async {
    final rows = await _client.getList('/api/takes/friends/stories/');
    return [
      for (final row in rows)
        if ((row['items'] as List<dynamic>? ?? const []).isNotEmpty)
          FriendStory.fromJson(row),
    ];
  }
}

/// Remembers, on this device, up to when each friend's story was watched, so
/// a ring only lights up again when the friend makes something new.
class SeenStories {
  SeenStories({SharedPreferences? preferences}) : _preferences = preferences;

  static const _prefix = 'story_seen_';

  SharedPreferences? _preferences;
  final Map<int, DateTime> _seen = {};

  /// Reads what was watched before. Safe to skip: everything then looks new.
  Future<void> load(Iterable<int> userIds) async {
    try {
      final prefs = _preferences ??= await SharedPreferences.getInstance();
      for (final id in userIds) {
        final value = prefs.getString('$_prefix$id');
        final at = value == null ? null : DateTime.tryParse(value);
        if (at != null) _seen[id] = at;
      }
    } on Exception {
      // No saved state: every ring shows as new.
    }
  }

  /// Whether everything in [story] has already been watched.
  bool isSeen(FriendStory story) {
    final at = _seen[story.userId];
    return at != null && !story.latestAt.isAfter(at);
  }

  /// Marks [story] as watched up to its newest item.
  Future<void> markSeen(FriendStory story) async {
    _seen[story.userId] = story.latestAt;
    try {
      final prefs = _preferences ??= await SharedPreferences.getInstance();
      await prefs.setString(
        '$_prefix${story.userId}',
        story.latestAt.toIso8601String(),
      );
    } on Exception {
      // Kept for this session only.
    }
  }
}

/// Stories kept in memory, for tests and previews.
class FakeStoryRepository implements StoryRepository {
  FakeStoryRepository([this.stories = const []]);

  final List<FriendStory> stories;
  int calls = 0;

  @override
  Future<List<FriendStory>> fetchFriendStories() async {
    calls++;
    return stories;
  }
}
