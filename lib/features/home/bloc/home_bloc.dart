import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/home_models.dart';
import '../data/home_repository.dart';
import 'home_screen_event.dart';
import 'home_screen_state.dart';

EventTransformer<E> _sequential<E extends HomeScreenEvent>() =>
    (events, mapper) => events.asyncExpand(mapper);

class HomeBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeBloc({
    required HomeRepository repository,
    required RecommendationGateway gateway,
  }) : _repository = repository,
       _gateway = gateway,
       super(const HomeLoading()) {
    on<HomeStarted>(_onStarted, transformer: _sequential());
    on<HomeRefreshRequested>(_onRefreshRequested, transformer: _sequential());
    on<HomeSectionRetryRequested>(_onRetry, transformer: _sequential());
    on<HomeFilmAdded>(_onFilmAdded, transformer: _sequential());
    on<HomeFilmRemoved>(_onFilmRemoved, transformer: _sequential());
    on<HomeFilmRestored>(_onFilmRestored, transformer: _sequential());
    on<HomePickToggled>(_onPickToggled, transformer: _sequential());
    on<HomeGenerateRequested>(_onGenerate, transformer: _sequential());
  }

  final HomeRepository _repository;
  final RecommendationGateway _gateway;
  int _noticeSeq = 0;

  int _nextNoticeId() => ++_noticeSeq;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeScreenState> emit) async {
    emit(
      HomeLoaded(
        sections: {for (final list in HomeList.values) list: const SectionLoading()},
      ),
    );
    await _loadPoints(emit);
    await _loadAll(emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      await _loadPoints(emit);
      await _loadAll(emit, showLoading: false);
    } finally {
      event.done?.complete();
    }
  }

  Future<void> _onRetry(
    HomeSectionRetryRequested event,
    Emitter<HomeScreenState> emit,
  ) => _loadSection(event.list, emit, showLoading: true);

  Future<void> _onFilmAdded(HomeFilmAdded event, Emitter<HomeScreenState> emit) async {
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
    } on Exception {
      _patch(emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  Future<void> _onFilmRemoved(HomeFilmRemoved event, Emitter<HomeScreenState> emit) async {
    final loaded = _loaded;
    if (loaded == null) return;
    final section = loaded.sections[event.list];
    if (section is! SectionContent) return;
    final index = section.films.indexOf(event.film);
    if (index < 0) return;

    final films = [...section.films]..removeAt(index);
    emit(
      loaded.copyWith(
        sections: {...loaded.sections, event.list: _sectionFor(films)},
        picks: loaded.picks.where((pick) => pick != event.film).toList(),
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
      _patch(emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  Future<void> _onFilmRestored(HomeFilmRestored event, Emitter<HomeScreenState> emit) async {
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
      loaded.copyWith(sections: {...loaded.sections, event.list: _sectionFor(films)}),
    );

    try {
      await _repository.add(event.list, event.film);
    } on Exception {
      if (emit.isDone) return;
      await _loadSection(event.list, emit, showLoading: false);
      _patch(emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
    }
  }

  void _onPickToggled(HomePickToggled event, Emitter<HomeScreenState> emit) {
    final loaded = _loaded;
    if (loaded == null || loaded.generating) return;

    if (loaded.picks.contains(event.film)) {
      emit(
        loaded.copyWith(
          picks: loaded.picks.where((pick) => pick != event.film).toList(),
        ),
      );
      return;
    }
    if (loaded.picks.length >= HomeLimits.recommendPicks) {
      emit(loaded.copyWith(notice: PicksFullNotice(_nextNoticeId())));
      return;
    }
    emit(loaded.copyWith(picks: [...loaded.picks, event.film]));
  }

  Future<void> _onGenerate(
    HomeGenerateRequested event,
    Emitter<HomeScreenState> emit,
  ) async {
    final loaded = _loaded;
    if (loaded == null || !loaded.canGenerate) return;

    emit(loaded.copyWith(generating: true));
    try {
      final points = await _gateway.generate(loaded.picks);
      _patch(
        emit,
        (s) => s.copyWith(
          generating: false,
          points: points,
          picks: const [],
          notice: RecommendReadyNotice(_nextNoticeId()),
        ),
      );
    } on Exception {
      _patch(
        emit,
        (s) => s.copyWith(
          generating: false,
          notice: ActionFailedNotice(_nextNoticeId()),
        ),
      );
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
      _patch(emit, (s) => s.copyWith(notice: ActionFailedNotice(_nextNoticeId())));
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

  void _setSection(Emitter<HomeScreenState> emit, HomeList list, SectionState section) {
    _patch(emit, (s) => s.copyWith(sections: {...s.sections, list: section}));
  }

  int _countOf(HomeLoaded loaded, HomeList list) => switch (loaded.sections[list]) {
    SectionContent(films: final films) => films.length,
    _ => 0,
  };

  SectionState _sectionFor(List<Film> films) =>
      films.isEmpty ? const SectionEmpty() : SectionContent(films);
}
