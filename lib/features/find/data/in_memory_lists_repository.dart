import 'lists_repository.dart';
import 'movie.dart';

/// In-memory implementation used by tests and previews.
class InMemoryListsRepository implements ListsRepository {
  InMemoryListsRepository({Map<FilmListId, List<String>>? seed})
      : _lists = {
          FilmListId.top5: [...?seed?[FilmListId.top5]],
          FilmListId.watched: [...?seed?[FilmListId.watched]],
          FilmListId.watchlist: [...?seed?[FilmListId.watchlist]],
        };

  final Map<FilmListId, List<String>> _lists;

  @override
  Future<ListSnapshot> fetchAll() async {
    // Top 5 is kept slot-aligned (index 0 == slot 1); empty slots are "". We
    // keep the alignment so the bloc can resolve a specific slot's occupant.
    final top5 = List.of(_lists[FilmListId.top5]!);
    return ListSnapshot(
      top5: top5,
      watched: List.of(_lists[FilmListId.watched]!),
      watchlist: List.of(_lists[FilmListId.watchlist]!),
      counts: {
        'top_5': top5.where((id) => id.isNotEmpty).length,
        'watched': _lists[FilmListId.watched]!.length,
        'watchlist': _lists[FilmListId.watchlist]!.length,
      },
    );
  }

  @override
  Future<ListEntry> add(
    FilmListId list,
    String filmId, {
    int? slot,
    bool replace = false,
  }) async {
    // watched/watchlist exclusivity: adding to Watched removes Watchlist.
    final removedFromWatchlist = list == FilmListId.watched &&
        _lists[FilmListId.watchlist]!.remove(filmId);

    if (list == FilmListId.watchlist &&
        _lists[FilmListId.watched]!.contains(filmId)) {
      throw const ServerFailure(
          'already_watched', 'You already watched this film.');
    }

    final items = _lists[list]!;
    if (list == FilmListId.top5) {
      int target = 0;
      if (slot != null) {
        target = slot;
        // Ensure the list is sized to the requested slot.
        while (items.length < target) {
          items.add('');
        }
        final existing = items[target - 1];
        if (existing.isNotEmpty && existing != filmId && !replace) {
          throw const ServerFailure(
              'top5_slot_taken', 'Slot is already taken.');
        }
        items[target - 1] = filmId;
      } else {
        if (items.length >= 5) {
          throw const ServerFailure('top5_full', 'Your Top 5 is full.');
        }
        items.add(filmId);
      }
    } else if (!items.contains(filmId)) {
      items.add(filmId);
    }

    return ListEntry(
      filmId: filmId,
      listType: listTypeOf(list),
      slot: slot,
      removedFromWatchlist: removedFromWatchlist,
    );
  }

  @override
  Future<void> remove(FilmListId list, String filmId) async {
    _lists[list]!.remove(filmId);
  }

  @override
  Future<List<String>> membershipFlags(String filmId) async {
    final flags = <String>[];
    for (final list in FilmListId.values) {
      if (_lists[list]!.contains(filmId)) flags.add(listTypeOf(list));
    }
    return flags;
  }

  // ---- test/introspection helpers ----

  bool contains(FilmListId list, String filmId) =>
      _lists[list]!.contains(filmId);

  bool hasWatched(String filmId) => contains(FilmListId.watched, filmId);
  bool hasWatchlist(String filmId) => contains(FilmListId.watchlist, filmId);
  bool hasTop5(String filmId) => contains(FilmListId.top5, filmId);

  int countOf(FilmListId list, String filmId) =>
      _lists[list]!.where((id) => id == filmId).length;

  String? top5At(int slot) =>
      (slot >= 1 && slot <= _lists[FilmListId.top5]!.length)
          ? _lists[FilmListId.top5]![slot - 1]
          : null;

  int top5Count() => _lists[FilmListId.top5]!.length;
}
