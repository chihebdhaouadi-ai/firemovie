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
    this.feed = const FeedLoading(),
    this.points = 0,
    this.notice,
  });

  final Map<HomeList, SectionState> sections;
  final FeedState feed;
  final int points;
  final HomeNotice? notice;

  HomeLoaded copyWith({
    Map<HomeList, SectionState>? sections,
    FeedState? feed,
    int? points,
    HomeNotice? notice,
  }) {
    return HomeLoaded(
      sections: sections ?? this.sections,
      feed: feed ?? this.feed,
      points: points ?? this.points,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [sections, feed, points, notice];
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

sealed class FeedState extends Equatable {
  const FeedState();
}

final class FeedLoading extends FeedState {
  const FeedLoading();

  @override
  List<Object?> get props => const [];
}

final class FeedEmpty extends FeedState {
  const FeedEmpty();

  @override
  List<Object?> get props => const [];
}

final class FeedError extends FeedState {
  const FeedError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class FeedContent extends FeedState {
  const FeedContent(this.items);

  final List<FeedItem> items;

  @override
  List<Object?> get props => [items];
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

final class ActionFailedNotice extends HomeNotice {
  const ActionFailedNotice(super.id);

  @override
  List<Object?> get props => [id];
}
