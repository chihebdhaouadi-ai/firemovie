import 'package:equatable/equatable.dart';

import '../data/home_models.dart';

sealed class HomeScreenState extends Equatable {
  const HomeScreenState();
}

final class HomeLoading extends HomeScreenState {
  const HomeLoading();

  @override
  List<Object?> get props => const [];
}

final class HomeLoaded extends HomeScreenState {
  const HomeLoaded({
    required this.sections,
    this.picks = const [],
    this.points = 0,
    this.generating = false,
    this.notice,
  });

  final Map<HomeList, SectionState> sections;
  final List<Film> picks;
  final int points;
  final bool generating;
  final HomeNotice? notice;

  bool get canGenerate =>
      !generating && picks.length == HomeLimits.recommendPicks;

  HomeLoaded copyWith({
    Map<HomeList, SectionState>? sections,
    List<Film>? picks,
    int? points,
    bool? generating,
    HomeNotice? notice,
  }) {
    return HomeLoaded(
      sections: sections ?? this.sections,
      picks: picks ?? this.picks,
      points: points ?? this.points,
      generating: generating ?? this.generating,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [sections, picks, points, generating, notice];
}

sealed class SectionState extends Equatable {
  const SectionState();
}

final class SectionLoading extends SectionState {
  const SectionLoading();

  @override
  List<Object?> get props => const [];
}

final class SectionEmpty extends SectionState {
  const SectionEmpty();

  @override
  List<Object?> get props => const [];
}

final class SectionError extends SectionState {
  const SectionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class SectionContent extends SectionState {
  const SectionContent(this.films);

  final List<Film> films;

  @override
  List<Object?> get props => [films];
}

sealed class HomeNotice extends Equatable {
  const HomeNotice(this.id);

  final int id;
}

final class FilmRemovedNotice extends HomeNotice {
  const FilmRemovedNotice({
    required int id,
    required this.list,
    required this.film,
    required this.index,
  }) : super(id);

  final HomeList list;
  final Film film;
  final int index;

  @override
  List<Object?> get props => [id, list, film, index];
}

final class Top5FullNotice extends HomeNotice {
  const Top5FullNotice(super.id);

  @override
  List<Object?> get props => [id];
}

final class PicksFullNotice extends HomeNotice {
  const PicksFullNotice(super.id);

  @override
  List<Object?> get props => [id];
}

final class RecommendReadyNotice extends HomeNotice {
  const RecommendReadyNotice(super.id);

  @override
  List<Object?> get props => [id];
}

final class ActionFailedNotice extends HomeNotice {
  const ActionFailedNotice(super.id);

  @override
  List<Object?> get props => [id];
}
