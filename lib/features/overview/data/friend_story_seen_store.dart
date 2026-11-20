import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which friends' activity the viewer has opened, like seen
/// stories. Keys include when the activity last changed, so a friend who
/// reacts again shows up as unseen again.
abstract interface class FriendStorySeenStore {
  Future<Set<String>> load();

  Future<void> markSeen(String key);
}

/// The key for one friend's activity on one film.
String friendStoryKey(String movieId, int userId, DateTime updatedAt) =>
    '$movieId:$userId:${updatedAt.millisecondsSinceEpoch}';

/// Keeps seen keys on the device. Failures (no plugin in tests, storage
/// errors) leave everything unseen rather than breaking the screen.
class PrefsFriendStorySeenStore implements FriendStorySeenStore {
  const PrefsFriendStorySeenStore();

  static const _key = 'friend_story_seen';

  /// Oldest keys are dropped past this, so the list cannot grow forever.
  static const _limit = 500;

  @override
  Future<Set<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_key) ?? const <String>[]).toSet();
    } catch (error) {
      debugPrint('Could not read seen friend activity: $error');
      return <String>{};
    }
  }

  @override
  Future<void> markSeen(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [
        ...?prefs.getStringList(_key)?.where((existing) => existing != key),
        key,
      ];
      final kept =
          keys.length > _limit ? keys.sublist(keys.length - _limit) : keys;
      await prefs.setStringList(_key, kept);
    } catch (error) {
      debugPrint('Could not save seen friend activity: $error');
    }
  }
}

/// In-memory store for tests.
class FakeFriendStorySeenStore implements FriendStorySeenStore {
  FakeFriendStorySeenStore([Set<String>? seen]) : seen = seen ?? <String>{};

  final Set<String> seen;

  @override
  Future<Set<String>> load() async => {...seen};

  @override
  Future<void> markSeen(String key) async => seen.add(key);
}
