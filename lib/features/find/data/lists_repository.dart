import 'package:equatable/equatable.dart';

import 'movie.dart';

/// Backend list_type identifier for each list.
String listTypeOf(FilmListId list) => switch (list) {
      FilmListId.top5 => 'top_5',
      FilmListId.watched => 'watched',
      FilmListId.watchlist => 'watchlist',
    };

/// Model of one entry as returned by the lists API.
class ListEntry extends Equatable {
  const ListEntry({
    required this.filmId,
    required this.listType,
    this.slot,
    this.removedFromWatchlist = false,
  });

  final String filmId;
  final String listType;
  final int? slot;
  final bool removedFromWatchlist;

  @override
  List<Object?> get props => [filmId, listType, slot, removedFromWatchlist];
}

/// The three persisted list collections plus their result.
class ListSnapshot extends Equatable {
  const ListSnapshot({
    required this.top5,
    required this.watched,
    required this.watchlist,
    this.counts = const {},
  });

  final List<String> top5;
  final List<String> watched;
  final List<String> watchlist;
  final Map<String, int> counts;

  bool contains(FilmListId list, String filmId) => switch (list) {
        FilmListId.top5 => top5.contains(filmId),
        FilmListId.watched => watched.contains(filmId),
        FilmListId.watchlist => watchlist.contains(filmId),
      };

  @override
  List<Object?> get props => [top5, watched, watchlist, counts];
}

/// Outcome of an add that may move a film between lists (watchlist -> watched).
class AddOutcome extends Equatable {
  const AddOutcome({
    required this.list,
    required this.entry,
    required this.movedFromWatchlist,
  });

  final FilmListId list;
  final ListEntry entry;
  final bool movedFromWatchlist;

  @override
  List<Object?> get props => [list, entry, movedFromWatchlist];
}

/// Abstract source of truth for the user's lists.
abstract class ListsRepository {
  /// Fetch the id-only snapshot used to fill counts and membership flags.
  Future<ListSnapshot> fetchAll();

  Future<ListEntry> add(FilmListId list, String filmId,
      {int? slot, bool replace = false});

  Future<void> remove(FilmListId list, String filmId);

  /// Merge [movie] with up-to-date membership flags for the current user.
  Future<List<String>> membershipFlags(String filmId);
}
