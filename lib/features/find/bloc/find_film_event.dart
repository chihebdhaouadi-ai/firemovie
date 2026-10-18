import 'package:equatable/equatable.dart';

import '../data/movie.dart';

sealed class FindFilmEvent extends Equatable {
  const FindFilmEvent();

  @override
  List<Object?> get props => const [];
}

/// Debounced search query change.
final class QueryChanged extends FindFilmEvent {
  const QueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchSubmitted extends FindFilmEvent {
  const SearchSubmitted(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class LoadMore extends FindFilmEvent {
  const LoadMore();

  @override
  List<Object?> get props => const [];
}

final class RetryRequested extends FindFilmEvent {
  const RetryRequested();
}

/// Request to add [film] to [target][index]. When [replace] is true the user
/// has already confirmed replacing the occupied slot.
final class AddRequested extends FindFilmEvent {
  const AddRequested(
    this.film, {
    required this.target,
    this.circleIndex = 0,
    this.slot = 0,
    this.replace = false,
  });

  final Movie film;
  final AddTarget target;

  /// 1-based slot for top5, pick index 0..2 for generatePick.
  final int circleIndex;
  final int slot;
  final bool replace;

  @override
  List<Object?> get props => [film, target, circleIndex, slot, replace];
}

/// Called from a confirm dialog to actually replace a top5 slot.
final class ConfirmReplaceRequested extends FindFilmEvent {
  const ConfirmReplaceRequested(this.film, this.slot, this.slotFilmId);
  final Movie film;
  final int slot;
  final String slotFilmId;

  @override
  List<Object?> get props => [film, slot, slotFilmId];
}

final class RemoveRequested extends FindFilmEvent {
  const RemoveRequested(this.film, this.target);
  final Movie film;
  final AddTarget target;

  @override
  List<Object?> get props => [film, target];
}

/// Undo the last add (soft remove = re-delete) or last remove (re-add).
final class UndoRequested extends FindFilmEvent {
  const UndoRequested();
}

final class ClearRecent extends FindFilmEvent {
  const ClearRecent();
}

final class RemoveRecent extends FindFilmEvent {
  const RemoveRecent(this.term);
  final String term;

  @override
  List<Object?> get props => [term];
}

/// Dismiss a transient notice (acknowledged blocks / dialogs). Acknowledging
/// marks the conflicting film as handled so it can be re-tapped.
final class AcknowledgeNotice extends FindFilmEvent {
  const AcknowledgeNotice(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

/// Internal: recent searches were loaded from storage.
final class RecentSearchesLoaded extends FindFilmEvent {
  const RecentSearchesLoaded(this.terms);
  final List<String> terms;

  @override
  List<Object?> get props => [terms];
}

/// Internal: the user's lists were (re)fetched.
final class ListsSnapshotUpdated extends FindFilmEvent {
  const ListsSnapshotUpdated();
}
