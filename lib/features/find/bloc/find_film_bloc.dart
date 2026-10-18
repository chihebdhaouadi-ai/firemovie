import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/find_repository.dart';
import '../data/lists_repository.dart';
import '../data/movie.dart';
import '../data/recent_searches_store.dart';
import 'find_film_event.dart';
import 'find_film_state.dart';

const minQueryLength = 2;
const debounceDuration = Duration(milliseconds: 350);
const generatePickLimit = 3;

class FindFilmBloc extends Bloc<FindFilmEvent, FindFilmState> {
  FindFilmBloc({
    required FindRepository find,
    required ListsRepository lists,
    required RecentSearchesStore recentStore,
    this.target = AddTarget.watchlist,
    this.circleIndex = 0,
    this.slot = 0,
    this.onPickFilled,
  })  : _find = find,
        _lists = lists,
        _recentStore = recentStore,
        super(const FindFilmInitial()) {
    on<QueryChanged>(_onQueryChanged, transformer: _debounce(debounceDuration));
    on<SearchSubmitted>(_onSearchSubmitted);
    on<LoadMore>(_onLoadMore);
    on<RetryRequested>(_onRetry);
    on<AddRequested>(_onAddRequested);
    on<ConfirmReplaceRequested>(_onConfirmReplace);
    on<RemoveRequested>(_onRemoveRequested);
    on<UndoRequested>(_onUndo);
    on<ClearRecent>(_onClearRecent);
    on<RemoveRecent>(_onRemoveRecent);
    on<AcknowledgeNotice>(_onAcknowledge);
    on<RecentSearchesLoaded>(_onRecentLoaded);
    on<ListsSnapshotUpdated>(_onSnapshotUpdated);
    _init();
  }

  final FindRepository _find;
  final ListsRepository _lists;
  final RecentSearchesStore _recentStore;

  /// The destination this screen was opened for.
  final AddTarget target;

  /// 1-based top5 slot when target is top5.
  final int circleIndex;

  /// pick index 0..2 when target is generatePick (also aliased via circleIndex).
  final int slot;

  /// Called with the selected film when target is [AddTarget.generatePick].
  final ValueChanged<Movie>? onPickFilled;

  int _seq = 0;
  int _noticeSeq = 0;
  String _lastQuery = '';
  int _lastPage = 1;

  Future<ListSnapshot> _snapshotF = Future.value(const ListSnapshot(
    top5: [],
    watched: [],
    watchlist: [],
  ));

  final Set<String> _addedThisSession = {};
  PendingAdd? _lastAdd;
  PendingAdd? _lastRemove;

  void _init() {
    _snapshotF = _lists.fetchAll();
    _snapshotF.then(
      (_) => add(const ListsSnapshotUpdated()),
      onError: (Object _) {},
    );
    _recentStore.load().then(
          (terms) => add(RecentSearchesLoaded(terms)),
          onError: (Object _) {},
        );
  }

  Future<ListSnapshot> _currentSnapshot() async {
    try {
      return await _snapshotF;
    } catch (_) {
      return const ListSnapshot(top5: [], watched: [], watchlist: []);
    }
  }

  int get _nextNoticeId => ++_noticeSeq;

  /// The 1-based Top 5 slot this screen was opened for, if any.
  int get targetCircleIndex => circleIndex;

  /// The pick slot this screen was opened for, if any.
  int get targetSlot => slot;

  /// Whether [film] is already present in the current [target] list.
  bool alreadyAdded(Movie film) {
    final list = _listForTarget(target);
    final sessionAdded = list == null
        ? _addedThisSession.contains('generate:${film.id}')
        : _isAdded(list, film.id);
    // Also honour membership flags returned by the search result.
    final flagAdded = switch (target) {
      AddTarget.top5 => film.isTop5,
      AddTarget.watched => film.isWatched,
      AddTarget.watchlist => film.isWatchlist,
      AddTarget.generatePick => false,
    };
    return sessionAdded || flagAdded;
  }

  Movie? _findInResults(String id) {
    final current = state;
    if (current is FindFilmResults) {
      for (final movie in current.results) {
        if (movie.id == id) return movie;
      }
    }
    return null;
  }

  // ---- recent searches ----

  void _onRecentLoaded(
      RecentSearchesLoaded event, Emitter<FindFilmState> emit) {
    emit(switch (state) {
      FindFilmInitial() => FindFilmInitial(recent: event.terms),
      FindFilmMinChars() => FindFilmMinChars(recent: event.terms),
      FindFilmLoading(:final query) =>
        FindFilmLoading(query: query, recent: event.terms),
      FindFilmEmpty(:final query) =>
        FindFilmEmpty(query: query, recent: event.terms),
      FindFilmError(:final query, :final failure) =>
        FindFilmError(query: query, failure: failure, recent: event.terms),
      FindFilmResults(
        :final query,
        :final results,
        :final hasMore,
        :final loadingMore
      ) =>
        _results(
          query: query,
          results: results,
          hasMore: hasMore,
          loadingMore: loadingMore,
          recent: event.terms,
        ),
    });
  }

  void _onSnapshotUpdated(
      ListsSnapshotUpdated event, Emitter<FindFilmState> emit) {
    final current = state;
    if (current is FindFilmResults) {
      emit(current.copyWith());
    }
  }

  List<String> _recentOf(FindFilmState state) => switch (state) {
        FindFilmInitial(:final recent) => recent,
        FindFilmMinChars(:final recent) => recent,
        FindFilmLoading(:final recent) => recent,
        FindFilmEmpty(:final recent) => recent,
        FindFilmError(:final recent) => recent,
        FindFilmResults(:final recent) => recent,
      };

  // ---- search ----

  Future<void> _onQueryChanged(
      QueryChanged event, Emitter<FindFilmState> emit) async {
    final query = event.query.trim();
    if (query == _lastQuery) return;
    if (query.length < minQueryLength) {
      _lastQuery = query;
      _seq++;
      emit(FindFilmMinChars(recent: _recentOf(state)));
      return;
    }
    await _search(emit, query);
  }

  Future<void> _onSearchSubmitted(
      SearchSubmitted event, Emitter<FindFilmState> emit) async {
    final query = event.query.trim();
    if (query.length >= minQueryLength) _touchRecent(query);
    if (query.length < minQueryLength) {
      _lastQuery = query;
      _seq++;
      emit(FindFilmMinChars(recent: _recentOf(state)));
      return;
    }
    await _search(emit, query);
  }

  Future<void> _search(Emitter<FindFilmState> emit, String query) async {
    final seq = ++_seq;
    emit(FindFilmLoading(query: query, recent: _recentOf(state)));
    try {
      final page = await _find.search(query, page: 1);
      if (seq != _seq || isClosed) return;
      _lastQuery = query;
      _lastPage = 1;
      if (page.results.isEmpty) {
        emit(FindFilmEmpty(query: query, recent: _recentOf(state)));
        return;
      }
      emit(
          _results(query: query, results: page.results, hasMore: page.hasMore));
    } on FindFailure catch (failure) {
      if (seq != _seq || isClosed) return;
      _lastQuery = query;
      emit(FindFilmError(
          query: query, failure: failure, recent: _recentOf(state)));
    } catch (_) {
      if (seq != _seq || isClosed) return;
      _lastQuery = query;
      emit(
        FindFilmError(
          query: query,
          failure: const NetworkFailure('Unexpected error.'),
          recent: _recentOf(state),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
      FindFilmEvent event, Emitter<FindFilmState> emit) async {
    final current = state;
    if (current is! FindFilmResults ||
        !current.hasMore ||
        current.loadingMore) {
      return;
    }
    emit(current.copyWith(loadingMore: true));
    final seq = _seq;
    try {
      final next = await _find.search(_lastQuery, page: _lastPage + 1);
      if (seq != _seq || isClosed) return;
      _lastPage = next.page;
      final merged = [...current.results, ...next.results];
      emit(_results(query: _lastQuery, results: merged, hasMore: next.hasMore));
    } on FindFailure catch (failure) {
      if (seq != _seq || isClosed) return;
      emit(
        current.copyWith(
          loadingMore: false,
          notice: ActionFailedNotice(_nextNoticeId, failure.message),
        ),
      );
    }
  }

  Future<void> _onRetry(
      FindFilmEvent event, Emitter<FindFilmState> emit) async {
    final current = state;
    if (current is! FindFilmError) return;
    await _search(emit, current.query);
  }

  // ---- add ----

  Future<void> _onAddRequested(
      AddRequested event, Emitter<FindFilmState> emit) async {
    final film = event.film;
    if (event.target == AddTarget.generatePick) {
      _handleGeneratePick(event, emit, film);
      return;
    }
    final current = state;
    if (current is FindFilmResults && current.processingIds.contains(film.id)) {
      return;
    }
    if (current is FindFilmResults) {
      emit(
          current.copyWith(processingIds: {...current.processingIds, film.id}));
    }
    switch (event.target) {
      case AddTarget.top5:
        await _addToTop5(event, emit, film);
      case AddTarget.watched:
        await _addToWatched(event, emit, film);
      case AddTarget.watchlist:
        await _addToWatchlist(event, emit, film);
      case AddTarget.generatePick:
        break;
    }
    final s = state;
    if (s is FindFilmResults) {
      emit(s.copyWith(processingIds: {...s.processingIds}..remove(film.id)));
    }
  }

  Future<void> _addToTop5(
      AddRequested event, Emitter<FindFilmState> emit, Movie film) async {
    final snapshot = await _currentSnapshot();
    final useSlot = event.slot > 0
        ? event.slot
        : (event.circleIndex > 0 ? event.circleIndex : 0);
    final occupant =
        useSlot > 0 ? snapshot.top5.tryFromIndex(useSlot - 1) : null;
    final hasOccupant = occupant != null && occupant.isNotEmpty;
    final alreadyAdded = _isAdded(FilmListId.top5, film.id);

    if (alreadyAdded) {
      emit(_noticeFor(
        _addedNotice(film.id, AddTarget.top5),
        moveToConfirmed: true,
      ));
      return;
    }

    if (hasOccupant && occupant != film.id && !event.replace) {
      emit(_confirmReplace(film, useSlot, occupant, _titleFor(occupant)));
      return;
    }

    try {
      await _lists.add(
        FilmListId.top5,
        film.id,
        slot: useSlot == 0 ? null : useSlot,
        replace: event.replace || (hasOccupant && occupant != film.id),
      );
      _addedThisSession.add('top5:${film.id}');
      _lastAdd = PendingAdd(
        target: AddTarget.top5,
        film: film,
        slot: useSlot == 0 ? null : useSlot,
        movedFromWatchlist: false,
      );
      emit(_noticeFor(AddedNotice(_nextNoticeId, film, AddTarget.top5, false)));
    } on ServerFailure catch (f) {
      if (f.code == 'top5_full' || f.code == 'top5_slot_taken') {
        emit(_noticeFor(Top5FullNotice(_nextNoticeId)));
        return;
      }
      emit(_noticeFor(ActionFailedNotice(_nextNoticeId, f.message)));
    } catch (_) {
      emit(_noticeFor(
        ActionFailedNotice(_nextNoticeId, 'Could not add the film.'),
      ));
    }
  }

  Future<void> _addToWatched(
      AddRequested event, Emitter<FindFilmState> emit, Movie film) async {
    if (_isAdded(FilmListId.watched, film.id)) {
      emit(_noticeFor(
        _addedNotice(film.id, AddTarget.watched),
        moveToConfirmed: true,
      ));
      return;
    }
    try {
      final entry = await _lists.add(FilmListId.watched, film.id);
      _addedThisSession.add('watched:${film.id}');
      if (entry.removedFromWatchlist) {
        _addedThisSession.remove('watchlist:${film.id}');
      }
      _lastAdd = PendingAdd(
        target: AddTarget.watched,
        film: film,
        movedFromWatchlist: entry.removedFromWatchlist,
      );
      emit(_noticeFor(
        AddedNotice(
            _nextNoticeId, film, AddTarget.watched, entry.removedFromWatchlist),
      ));
    } on FindFailure {
      emit(_noticeFor(
          ActionFailedNotice(_nextNoticeId, 'Could not add the film.')));
    }
  }

  Future<void> _addToWatchlist(
      AddRequested event, Emitter<FindFilmState> emit, Movie film) async {
    if (_isAdded(FilmListId.watchlist, film.id)) {
      emit(_noticeFor(
        _addedNotice(film.id, AddTarget.watchlist),
        moveToConfirmed: true,
      ));
      return;
    }
    try {
      await _lists.add(FilmListId.watchlist, film.id);
      _addedThisSession.add('watchlist:${film.id}');
      _lastAdd = PendingAdd(
        target: AddTarget.watchlist,
        film: film,
        movedFromWatchlist: false,
      );
      emit(_noticeFor(
        AddedNotice(_nextNoticeId, film, AddTarget.watchlist, false),
      ));
    } on ServerFailure catch (f) {
      if (f.code == 'already_watched') {
        emit(_noticeFor(AlreadyWatchedNotice(_nextNoticeId, film)));
        return;
      }
      emit(_noticeFor(ActionFailedNotice(_nextNoticeId, f.message)));
    } catch (_) {
      emit(_noticeFor(
        ActionFailedNotice(_nextNoticeId, 'Could not add the film.'),
      ));
    }
  }

  void _handleGeneratePick(
      AddRequested event, Emitter<FindFilmState> emit, Movie film) {
    final key = 'generate:${film.id}';
    if (_addedThisSession.contains(key)) return;
    if (_addedThisSession.where((e) => e.startsWith('generate:')).length >=
        generatePickLimit) {
      emit(_noticeFor(
        ActionFailedNotice(_nextNoticeId, 'You can pick up to 3 films.'),
      ));
      return;
    }
    _addedThisSession.add(key);
    _lastAdd = PendingAdd(
      target: AddTarget.generatePick,
      film: film,
      movedFromWatchlist: false,
    );
    emit(_noticeFor(
        AddedNotice(_nextNoticeId, film, AddTarget.generatePick, false)));
    onPickFilled?.call(film);
  }

  Future<void> _onConfirmReplace(
      ConfirmReplaceRequested event, Emitter<FindFilmState> emit) async {
    final film = event.film;
    try {
      await _lists.remove(FilmListId.top5, event.slotFilmId);
      await _lists.add(FilmListId.top5, film.id,
          slot: event.slot, replace: true);
    } catch (_) {
      emit(_noticeFor(
        ActionFailedNotice(_nextNoticeId, 'Could not replace the film.'),
      ));
      return;
    }
    _addedThisSession.add('top5:${film.id}');
    _lastAdd = PendingAdd(
      target: AddTarget.top5,
      film: film,
      slot: event.slot,
      movedFromWatchlist: false,
    );
    emit(_noticeFor(AddedNotice(_nextNoticeId, film, AddTarget.top5, false)));
  }

  Future<void> _onRemoveRequested(
      RemoveRequested event, Emitter<FindFilmState> emit) async {
    final list = _listForTarget(event.target);
    _addedThisSession.remove('${targetLabel(event.target)}:${event.film.id}');
    _lastRemove = PendingAdd(
      target: event.target,
      film: event.film,
      movedFromWatchlist: false,
    );
    emit(_noticeFor(RemovedNotice(_nextNoticeId, event.film, event.target)));
    if (list != null) {
      try {
        await _lists.remove(list, event.film.id);
      } on FindFailure catch (f) {
        emit(_noticeFor(ActionFailedNotice(_nextNoticeId, f.message)));
      }
    }
  }

  Future<void> _onUndo(FindFilmEvent event, Emitter<FindFilmState> emit) async {
    final add = _lastAdd;
    if (add != null) {
      final key = '${targetLabel(add.target)}:${add.film.id}';
      _addedThisSession.remove(key);
      if (add.target != AddTarget.generatePick) {
        final list = _listForTarget(add.target);
        if (list != null) {
          try {
            await _lists.remove(list, add.film.id);
          } catch (_) {}
        }
      }
      if (add.movedFromWatchlist) {
        try {
          await _lists.add(FilmListId.watchlist, add.film.id);
          _addedThisSession.add('watchlist:${add.film.id}');
        } catch (_) {}
      }
      if (add.target == AddTarget.generatePick) {
        onPickFilled?.call(add.film); // signal un-pick; screen handles removal
      }
      _lastAdd = null;
    } else if (_lastRemove != null) {
      final remove = _lastRemove!;
      final list = _listForTarget(remove.target);
      if (list != null) {
        try {
          await _lists.add(list, remove.film.id);
          _addedThisSession
              .add('${targetLabel(remove.target)}:${remove.film.id}');
        } catch (_) {}
      }
      _lastRemove = null;
    }
  }

  Future<void> _onClearRecent(
      FindFilmEvent event, Emitter<FindFilmState> emit) async {
    final terms = await _recentStore.clear();
    add(RecentSearchesLoaded(terms));
  }

  Future<void> _onRemoveRecent(
      RemoveRecent event, Emitter<FindFilmState> emit) async {
    final terms = await _recentStore.remove(event.term);
    add(RecentSearchesLoaded(terms));
  }

  void _onAcknowledge(AcknowledgeNotice event, Emitter<FindFilmState> emit) {
    final current = state;
    if (current is FindFilmResults) {
      emit(current.copyWith(clearNotice: true, clearConfirmReplace: true));
    }
  }

  // ---- state helpers ----

  bool _isAdded(FilmListId list, String id) =>
      _addedThisSession.contains('${listTypeOf(list)}:$id') ||
      _addedThisSession.contains('${_targetName(list)}:$id');

  String _targetName(FilmListId list) => switch (list) {
        FilmListId.top5 => 'top5',
        FilmListId.watched => 'watched',
        FilmListId.watchlist => 'watchlist',
      };

  String? _titleFor(String id) => _findInResults(id)?.title;

  FindFilmResults _results({
    required String query,
    required List<Movie> results,
    required bool hasMore,
    bool loadingMore = false,
    List<String>? recent,
    FindFilmNotice? notice,
    ReplaceConfirmNotice? confirmReplace,
    Set<String>? processingIds,
  }) {
    final current = state;
    final currentResults = current is FindFilmResults ? current : null;
    return FindFilmResults(
      query: query,
      results: results,
      hasMore: hasMore,
      loadingMore: loadingMore,
      recent: recent ?? _recentOf(state),
      notice: notice ?? currentResults?.notice,
      confirmReplace: confirmReplace ?? currentResults?.confirmReplace,
      processingIds:
          processingIds ?? (currentResults?.processingIds ?? const {}),
    );
  }

  FindFilmNotice _addedNotice(String id, AddTarget target) {
    final movie = _findInResults(id) ?? Movie(id: id, title: id);
    return AddedNotice(_nextNoticeId, movie, target, false);
  }

  FindFilmResults _noticeFor(FindFilmNotice notice,
      {bool moveToConfirmed = false}) {
    final current = state;
    if (current is! FindFilmResults) {
      return FindFilmResults(
        query: _lastQuery,
        results: const [],
        hasMore: false,
        notice: notice,
      );
    }
    return current.copyWith(notice: notice, clearConfirmReplace: true);
  }

  FindFilmResults _confirmReplace(
      Movie film, int useSlot, String occupant, String? occupantTitle) {
    final current = state;
    if (current is! FindFilmResults) {
      return FindFilmResults(
        query: _lastQuery,
        results: const [],
        hasMore: false,
        confirmReplace: ReplaceConfirmNotice(
          _nextNoticeId,
          film,
          useSlot,
          occupant,
          occupantTitle,
        ),
      );
    }
    return current.copyWith(
      confirmReplace: ReplaceConfirmNotice(
        _nextNoticeId,
        film,
        useSlot,
        occupant,
        occupantTitle,
      ),
      clearNotice: true,
    );
  }

  FilmListId? _listForTarget(AddTarget target) => switch (target) {
        AddTarget.top5 => FilmListId.top5,
        AddTarget.watched => FilmListId.watched,
        AddTarget.watchlist => FilmListId.watchlist,
        AddTarget.generatePick => null,
      };

  void _touchRecent(String query) {
    _recentStore.add(query).then(
          (terms) => add(RecentSearchesLoaded(terms)),
          onError: (Object _) {},
        );
  }

  static EventTransformer<E> _debounce<E extends FindFilmEvent>(
      Duration duration) {
    Timer? timer;
    E? pending;
    return (events, mapper) {
      final out = StreamController<E>();
      void emitNext() {
        final toSend = pending;
        pending = null;
        if (toSend != null) {
          out.addStream(mapper(toSend));
        }
      }

      events.listen((event) {
        pending = event;
        timer?.cancel();
        timer = Timer(duration, emitNext);
      }, onDone: () {
        timer?.cancel();
        emitNext();
        out.close();
      });
      return out.stream;
    };
  }
}

extension on List<String> {
  String? tryFromIndex(int index) =>
      (index >= 0 && index < length) ? this[index] : null;
}
