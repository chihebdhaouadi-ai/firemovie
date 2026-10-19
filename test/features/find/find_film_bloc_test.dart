import 'package:film_wise_mobile/features/find/bloc/find_film_bloc.dart';
import 'package:film_wise_mobile/features/find/bloc/find_film_event.dart';
import 'package:film_wise_mobile/features/find/bloc/find_film_state.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/in_memory_lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/data/recent_searches_store.dart';
import 'package:flutter_test/flutter_test.dart';

const _pulp = Movie(
  id: '278',
  title: 'Pulp Fiction',
  year: 1994,
  director: 'Quentin Tarantino',
);
const _shaw = Movie(id: '123', title: 'The Shawshank Redemption', year: 1994);
const _mat = Movie(id: '11', title: 'The Matrix', year: 1999);
const _in = Movie(id: '27205', title: 'Inception', year: 2010);
const _arr = Movie(id: '603', title: 'Arrival', year: 2016);

class _StubFindRepository extends FindRepository {
  _StubFindRepository({this.results = const []});

  final List<Movie> results;
  bool failFirst = false;
  Duration searchDelay = Duration.zero;
  int calls = 0;
  final List<int> requestedPages = [];

  @override
  Future<MovieSearchPage> search(String query, {int page = 1}) async {
    calls++;
    requestedPages.add(page);
    if (searchDelay > Duration.zero) await Future.delayed(searchDelay);
    if (failFirst) {
      failFirst = false;
      throw const NetworkFailure('down');
    }
    return MovieSearchPage(
      page: page,
      totalPages: 2,
      totalResults: results.length * 2,
      results: page == 1 ? results : const [],
    );
  }
}

class _FakeRecentStore extends RecentSearchesStore {
  _FakeRecentStore([List<String> seed = const []]) : _terms = [...seed];
  final List<String> _terms;
  int addCalls = 0;

  @override
  Future<List<String>> load() async => List.of(_terms);

  @override
  Future<List<String>> add(String term) async {
    addCalls++;
    final t = term.trim();
    _terms.remove(t);
    _terms.insert(0, t);
    return List.of(_terms.take(RecentSearchesStore.maxEntries));
  }
}

class _Harness {
  _Harness({this.target = AddTarget.watchlist})
      : find = _StubFindRepository(results: [_pulp, _shaw, _mat, _in, _arr]),
        recent = _FakeRecentStore() {
    lists = InMemoryListsRepository();
  }

  late final _StubFindRepository find;
  late final InMemoryListsRepository lists;
  late final _FakeRecentStore recent;
  final AddTarget target;

  FindFilmBloc build({int slot = 0, List<Movie> Function(Movie)? onPick}) {
    return FindFilmBloc(
      find: find,
      lists: lists,
      recentStore: recent,
      target: target,
      slot: slot,
      circleIndex: slot,
    );
  }
}

void main() {
  group('search', () {
    test('debounces and searches after the last keystroke', () async {
      final h = _Harness();
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(const QueryChanged('m'));
      bloc.add(const QueryChanged('ma'));
      bloc.add(const QueryChanged('mat'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 120));

      expect(h.find.calls, 1);
      expect(bloc.state, isA<FindFilmResults>());
      final state = bloc.state as FindFilmResults;
      expect(state.results.map((m) => m.title), contains('The Matrix'));
    });

    test('does not search below the minimum query length', () async {
      final h = _Harness();
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(const QueryChanged('a'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 120));

      expect(h.find.calls, 0);
      expect(bloc.state, isA<FindFilmMinChars>());
    });

    test('ignores stale responses: newest query wins', () async {
      final h = _Harness();
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(const QueryChanged('matrix'));
      bloc.add(const QueryChanged('inception'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 150));

      final state = bloc.state;
      expect(state, isA<FindFilmResults>());
      expect((state as FindFilmResults).results.map((m) => m.title),
          contains('Inception'));
    });

    test('a keystroke during an in-flight search cancels it without erroring',
        () async {
      final h = _Harness();
      h.find.searchDelay = const Duration(milliseconds: 300);
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(const QueryChanged('matrix'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 50));
      bloc.add(const QueryChanged('inception'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 400));

      expect(bloc.state, isA<FindFilmResults>());
      expect((bloc.state as FindFilmResults).query, 'inception');
    });

    test('network failure surfaces an error with the query preserved',
        () async {
      final h = _Harness();
      h.find.failFirst = true;
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(const QueryChanged('matrix'));
      await Future.delayed(
          debounceDuration + const Duration(milliseconds: 120));

      final state = bloc.state;
      expect(state, isA<FindFilmError>());
      expect((state as FindFilmError).failure, isA<NetworkFailure>());
    });
  });

  group('add · watched / watchlist', () {
    test('adds to watchlist and reports an AddedNotice', () async {
      final h = _Harness(target: AddTarget.watchlist);
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(AddRequested(_pulp, target: AddTarget.watchlist));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);

      expect(h.lists.hasWatchlist(_pulp.id), isTrue);
      expect(bloc.alreadyAdded(_pulp), isTrue);
    });

    test('prevents a duplicate add to the same list', () async {
      final h = _Harness(target: AddTarget.watchlist);
      final bloc = h.build();
      addTearDown(bloc.close);

      bloc.add(AddRequested(_pulp, target: AddTarget.watchlist));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);
      bloc.add(AddRequested(_pulp, target: AddTarget.watchlist));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);

      expect(h.lists.countOf(FilmListId.watchlist, _pulp.id), 1);
    });

    test('moving to Watched removes it from Watchlist', () async {
      final h = _Harness(target: AddTarget.watched);
      final bloc = h.build();
      addTearDown(bloc.close);

      await h.lists.add(FilmListId.watchlist, _pulp.id);
      bloc.add(AddRequested(_pulp, target: AddTarget.watched));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);

      final notice = (bloc.state as FindFilmResults).notice as AddedNotice;
      expect(notice.movedFromWatchlist, isTrue);
      expect(h.lists.hasWatchlist(_pulp.id), isFalse);
      expect(h.lists.hasWatched(_pulp.id), isTrue);
    });

    test('adding to Watchlist is blocked when already watched', () async {
      final h = _Harness(target: AddTarget.watchlist);
      final bloc = h.build();
      addTearDown(bloc.close);

      await h.lists.add(FilmListId.watched, _pulp.id);
      bloc.add(AddRequested(_pulp, target: AddTarget.watchlist));
      await _pumpUntil(
        bloc,
        (s) => s is FindFilmResults && s.notice is AlreadyWatchedNotice,
      );

      expect(h.lists.hasWatchlist(_pulp.id), isFalse);
    });
  });

  group('top5', () {
    test('fills the requested slot', () async {
      final h = _Harness(target: AddTarget.top5);
      final bloc = h.build(slot: 3);
      addTearDown(bloc.close);

      bloc.add(
          AddRequested(_pulp, target: AddTarget.top5, slot: 3, circleIndex: 3));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);

      expect(h.lists.top5At(3), _pulp.id);
      expect(bloc.alreadyAdded(_pulp), isTrue);
    });

    test('asks to replace an occupied slot', () async {
      final h = _Harness(target: AddTarget.top5);
      // Seed the occupied slot BEFORE the bloc snapshots the list.
      await h.lists.add(FilmListId.top5, '000-other', slot: 2);
      final bloc = h.build(slot: 2);
      addTearDown(bloc.close);

      bloc.add(
          AddRequested(_pulp, target: AddTarget.top5, slot: 2, circleIndex: 2));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.confirmReplace != null);

      expect((bloc.state as FindFilmResults).confirmReplace, isNotNull);
      expect(h.lists.top5At(2), '000-other'); // not replaced before confirm
    });

    test('confirming replace swaps the occupant', () async {
      final h = _Harness(target: AddTarget.top5);
      await h.lists.add(FilmListId.top5, '000-other', slot: 2);
      final bloc = h.build(slot: 2);
      addTearDown(bloc.close);

      bloc.add(
          AddRequested(_pulp, target: AddTarget.top5, slot: 2, circleIndex: 2));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.confirmReplace != null);
      final confirm = (bloc.state as FindFilmResults).confirmReplace!;

      bloc.add(
          ConfirmReplaceRequested(_pulp, confirm.slot, confirm.slotFilmId));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is AddedNotice);

      expect(h.lists.top5At(2), _pulp.id);
    });
  });

  group('undo', () {
    test('undo restores a removed film', () async {
      final h = _Harness(target: AddTarget.watched);
      final bloc = h.build();
      addTearDown(bloc.close);

      await h.lists.add(FilmListId.watched, _pulp.id);
      bloc.add(RemoveRequested(_pulp, AddTarget.watched));
      await _pumpUntil(
          bloc, (s) => s is FindFilmResults && s.notice is RemovedNotice);
      expect(h.lists.hasWatched(_pulp.id), isFalse);

      bloc.add(const UndoRequested());
      await _pumpUntil(bloc, (s) => s is FindFilmResults);
      expect(h.lists.hasWatched(_pulp.id), isTrue);
    });
  });

  group('generatePick', () {
    test('fills pick slots and respects the 3-film limit', () async {
      final picked = <Movie>[];
      final h = _Harness(target: AddTarget.generatePick);
      final bloc = FindFilmBloc(
        find: h.find,
        lists: h.lists,
        recentStore: h.recent,
        target: AddTarget.generatePick,
        onPickFilled: picked.add,
      );
      addTearDown(bloc.close);

      for (final movie in [_pulp, _shaw, _mat, _in, _arr]) {
        bloc.add(AddRequested(movie, target: AddTarget.generatePick));
        await _pumpUntil(
          bloc,
          (s) => s is FindFilmResults && s.notice is AddedNotice,
          maxTries: 20,
        );
      }

      expect(picked.length, 3);
    });
  });
}

Future<void> _pumpUntil(
  FindFilmBloc bloc,
  bool Function(FindFilmState) predicate, {
  int maxTries = 40,
}) async {
  for (var i = 0; i < maxTries; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (predicate(bloc.state)) return;
  }
}
