import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's most recent searches (max [maxEntries], newest first).
class RecentSearchesStore {
  RecentSearchesStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const maxEntries = 10;
  static const _key = 'recent_searches';

  final SharedPreferences? _prefs;
  List<String> _cache = const [];

  /// Loads persisted entries. Safe to call more than once.
  Future<List<String>> load() async {
    final prefs = await _preferences();
    if (prefs == null) return _cache;
    _cache = prefs.getStringList(_key) ?? const [];
    return _cache;
  }

  Future<List<String>> add(String term) async {
    final trimmed = term.trim();
    final current = [..._cache];
    current.remove(trimmed);
    current.insert(0, trimmed);
    _cache = current.take(maxEntries).toList();
    await _save();
    return _cache;
  }

  Future<List<String>> remove(String term) async {
    _cache = _cache.where((t) => t != term).toList();
    await _save();
    return _cache;
  }

  Future<List<String>> clear() async {
    _cache = const [];
    await _save();
    return _cache;
  }

  Future<SharedPreferences?> _preferences() async {
    if (_prefs != null) return _prefs;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    final prefs = await _preferences();
    if (prefs == null) return;
    await prefs.setStringList(_key, _cache);
  }
}
