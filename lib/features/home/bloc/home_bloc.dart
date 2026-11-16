import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/home_models.dart';
import '../data/home_repository.dart';
import 'home_screen_event.dart';
import 'home_screen_state.dart';

EventTransformer<E> _sequential<E extends HomeScreenEvent>() =>
    (events, mapper) => events.asyncExpand(mapper);

const _feedLists = [HomeList.top5, HomeList.watched, HomeList.watchlist];

class HomeBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  /// [isSignedIn] decides whether account-only lists and the feed load. Guests
  /// get no requests for them, so the backend never sees 401s from Home. When
  /// it is omitted the bloc behaves as signed in; the app passes
  /// `Session.isLoggedIn`.
  HomeBloc({
    required HomeRepository repository,
    required PointsGateway gateway,
    bool Function()? isSignedIn,
  })  : _repository = repository,
        _gateway = gateway,
        _isSignedIn = isSignedIn ?? (() => true),
        super(const HomeLoading()) {
    on<HomeStarted>(_onStarted, transformer: _sequential());
    on<HomeRefreshRequested>(_onRefreshRequested, transformer: _sequential());
    on<HomeSectionRetryRequested>(_onRetry, transformer: _sequential());
    on<HomeFeedRetryRequested>(_onFeedRetry, transformer: _sequential());
    on<HomeFilmAdded>(_onFilmAdded, transformer: _sequential());
    on<HomeFilmRemoved>(_onFilmRemoved, transformer: _sequential());
    on<HomeFilmRestored>(_onFilmRestored, transformer: _sequential());
  }

  final HomeRepository _repository;
  final PointsGateway _gateway;
  final bool Function() _isSignedIn;
  int _noticeSeq = 0;

  int _nextNoticeId() => ++_noticeSeq;

  Future<void> _onStarted(
      HomeStarted event, Emitter<HomeScreenState> emit) async {
    if (!_isSignedIn()) {
      // Guests see public content only; the tabs show a sign-in prompt instead.
      emit(
        HomeLoaded(
          sections: {for (final list in HomeList.values) list: const SectionEmpty()},
          feed: const FeedEmpty(),
        ),
      );
      return;
    }
    emit(
      HomeLoaded(
        sections: {
          for (final list in HomeList.values) list: const SectionLoading()
        },
      ),
    );
    await _loadPoints(emit);
    await _loadAll(emit, showLoading: true);
    await _loadFeed(emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeScreenState> emit,
  ) async {
    if (!_isSignedIn()) {
      event.done?.complete();
      return;
    }
    try {
      await _loadPoints(emit);
      await _loadAll(emit, showLoading: false);
      await _loadFeed(emit, showLoading: false);
    } finally {
      event.done?.complete();
    }
  }

  Future<void> _onRetry(
    HomeSectionRetryRequested event,
    Emitter<HomeScreenState> emit,
  ) =>
      _loadSection(event.list, emit, showLoading: true);

  Future<void> _onFeedRetry(
    HomeFeedRetryRequested event,
    Emitter<HomeScreenState> emit,
  ) =>
      _loadFeed(emit, showLoading: true);

  Future<void> _onFilmAdded(
      HomeFilmAdded event, Emitter<HomeScreenState> emit) async {
    final loaded = _loaded;
    if (loaded == null) return;
    if (event.list == HomeList.top5 &&
        _countOf(loaded, HomeList.top5) >= HomeLimits.top5Slots) {
      _patch(emit, (s) => s.copyWith(notice: Top5FullNotice(_nextNoticeId())));
      return;
    }
    try {
      await _repository.add(event.list, event.film);
      await _loadSection(event.list, emit, showLoading: false);
      await _loadFeed(emit, showLoading: false);
    } on Exception {
      _patch(
          emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  Future<void> _onFilmRemoved(
      HomeFilmRemoved event, Emitter<HomeScreenState> emit) async {
    final loaded = _loaded;
    if (loaded == null) return;
    final section = loaded.sections[event.list];
    if (section is! SectionContent) return;
    final index = section.films.indexOf(event.film);
    if (index < 0) return;

    final films = [...section.films]..removeAt(index);
    final sections = {...loaded.sections, event.list: _sectionFor(films)};
    emit(
      loaded.copyWith(
        sections: sections,
        feed: _collectionFilms(sections).contains(event.film)
            ? loaded.feed
            : _feedWithout(loaded.feed, event.film),
        notice: FilmRemovedNotice(
          id: _nextNoticeId(),
          list: event.list,
          film: event.film,
          index: index,
        ),
      ),
    );

    try {
      await _repository.remove(event.list, event.film);
    } on Exception {
      if (emit.isDone) return;
      await _loadSection(event.list, emit, showLoading: false);
      await _loadFeed(emit, showLoading: false);
      _patch(
          emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  Future<void> _onFilmRestored(
      HomeFilmRestored event, Emitter<HomeScreenState> emit) async {
    final loaded = _loaded;
    if (loaded == null) return;
    final section = loaded.sections[event.list];
    final films = switch (section) {
      SectionContent(films: final current) => [...current],
      _ => <Film>[],
    };
    if (films.contains(event.film)) return;
    if (event.list == HomeList.top5 && films.length >= HomeLimits.top5Slots) {
      _patch(emit, (s) => s.copyWith(notice: Top5FullNotice(_nextNoticeId())));
      return;
    }

    final at = event.index < films.length ? event.index : films.length;
    films.insert(at, event.film);
    emit(
      loaded.copyWith(
          sections: {...loaded.sections, event.list: _sectionFor(films)}),
    );

    try {
      await _repository.add(event.list, event.film);
      await _loadFeed(emit, showLoading: false);
    } on Exception {
      if (emit.isDone) return;
      await _loadSection(event.list, emit, showLoading: false);
      _patch(
          emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  HomeLoaded? get _loaded => switch (state) {
        HomeLoaded loaded => loaded,
        HomeLoading() => null,
      };

  void _patch(
    Emitter<HomeScreenState> emit,
    HomeLoaded Function(HomeLoaded current) transform,
  ) {
    final current = _loaded;
    if (current == null || emit.isDone) return;
    emit(transform(current));
  }

  Future<void> _loadPoints(Emitter<HomeScreenState> emit) async {
    try {
      final points = await _gateway.fetchPoints();
      _patch(emit, (s) => s.copyWith(points: points));
    } on Exception {
      _patch(
          emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  Future<void> _loadAll(
    Emitter<HomeScreenState> emit, {
    required bool showLoading,
  }) async {
    await Future.wait([
      for (final list in HomeList.values)
        _loadSection(list, emit, showLoading: showLoading),
    ]);
  }

  Future<void> _loadSection(
    HomeList list,
    Emitter<HomeScreenState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) _setSection(emit, list, const SectionLoading());
    try {
      final films = await _repository.fetch(list);
      _setSection(emit, list, _sectionFor(films));
    } on Exception catch (error) {
      _setSection(emit, list, SectionError(error.toString()));
    }
  }

  Future<void> _loadFeed(
    Emitter<HomeScreenState> emit, {
    required bool showLoading,
  }) async {
    final loaded = _loaded;
    if (loaded == null) return;
    final films = _collectionFilms(loaded.sections)
        .toSet()
        .take(HomeLimits.feedFilmLimit)
        .toList(growable: false);
    if (films.isEmpty) {
      _setFeed(emit, const FeedEmpty());
      return;
    }
    if (showLoading) _setFeed(emit, const FeedLoading());
    try {
      final items = await _repository.fetchFeed(films);
      _setFeed(emit, _feedFor(items));
    } on Exception catch (error) {
      _setFeed(emit, FeedError(error.toString()));
    }
  }

  void _setSection(
      Emitter<HomeScreenState> emit, HomeList list, SectionState section) {
    _patch(emit, (s) => s.copyWith(sections: {...s.sections, list: section}));
  }

  void _setFeed(Emitter<HomeScreenState> emit, FeedState feed) {
    _patch(emit, (s) => s.copyWith(feed: feed));
  }

  Iterable<Film> _collectionFilms(Map<HomeList, SectionState> sections) sync* {
    for (final list in _feedLists) {
      if (sections[list] case SectionContent(films: final films)) {
        yield* films;
      }
    }
  }

  FeedState _feedWithout(FeedState feed, Film film) => switch (feed) {
        FeedContent(items: final items) => _feedFor(
            items.where((item) => item.film != film).toList(growable: false),
          ),
        _ => feed,
      };

  FeedState _feedFor(List<FeedItem> items) =>
      items.isEmpty ? const FeedEmpty() : FeedContent(items);

  int _countOf(HomeLoaded loaded, HomeList list) =>
      switch (loaded.sections[list]) {
        SectionContent(films: final films) => films.length,
        _ => 0,
      };

  SectionState _sectionFor(List<Film> films) =>
      films.isEmpty ? const SectionEmpty() : SectionContent(films);
}
