import 'package:equatable/equatable.dart';

import '../data/home_models.dart';

sealed class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object?> get props => const [];
}

final class HomeStarted extends HomeScreenEvent {
  const HomeStarted();
}

final class HomeRefreshRequested extends HomeScreenEvent {
  const HomeRefreshRequested();
}

final class HomeSectionRetryRequested extends HomeScreenEvent {
  const HomeSectionRetryRequested(this.list);

  final HomeList list;

  @override
  List<Object?> get props => [list];
}

final class HomeFilmAdded extends HomeScreenEvent {
  const HomeFilmAdded(this.list, this.film);

  final HomeList list;
  final Film film;

  @override
  List<Object?> get props => [list, film];
}

final class HomeFilmRemoved extends HomeScreenEvent {
  const HomeFilmRemoved(this.list, this.film);

  final HomeList list;
  final Film film;

  @override
  List<Object?> get props => [list, film];
}

final class HomeFilmRestored extends HomeScreenEvent {
  const HomeFilmRestored(this.list, this.film, this.index);

  final HomeList list;
  final Film film;
  final int index;

  @override
  List<Object?> get props => [list, film, index];
}

final class HomePickToggled extends HomeScreenEvent {
  const HomePickToggled(this.film);

  final Film film;

  @override
  List<Object?> get props => [film];
}

final class HomeGenerateRequested extends HomeScreenEvent {
  const HomeGenerateRequested();
}
