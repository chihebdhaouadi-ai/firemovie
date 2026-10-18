import 'package:equatable/equatable.dart';

import '../data/movie.dart';

/// A pending add that was just performed, enabling Undo.
final class PendingAdd {
  const PendingAdd({
    required this.target,
    required this.film,
    this.slot,
    required this.movedFromWatchlist,
  });

  final AddTarget target;
  final Movie film;
  final int? slot;
  final bool movedFromWatchlist;
}

sealed class FindFilmState extends Equatable {
  const FindFilmState();
}

final class FindFilmInitial extends FindFilmState {
  const FindFilmInitial({this.recent = const []});

  final List<String> recent;

  @override
  List<Object?> get props => [recent];
}

final class FindFilmMinChars extends FindFilmState {
  const FindFilmMinChars({this.recent = const []});

  final List<String> recent;

  @override
  List<Object?> get props => [recent];
}

final class FindFilmLoading extends FindFilmState {
  const FindFilmLoading({required this.query, this.recent = const []});

  final String query;
  final List<String> recent;

  @override
  List<Object?> get props => [query, recent];
}

final class FindFilmEmpty extends FindFilmState {
  const FindFilmEmpty({required this.query, this.recent = const []});

  final String query;
  final List<String> recent;

  @override
  List<Object?> get props => [query, recent];
}

final class FindFilmError extends FindFilmState {
  const FindFilmError({
    required this.query,
    required this.failure,
    this.recent = const [],
  });

  final String query;
  final FindFailure failure;
  final List<String> recent;

  bool get isOffline => failure is OfflineFailure;

  @override
  List<Object?> get props => [query, failure, recent];
}

final class FindFilmResults extends FindFilmState {
  const FindFilmResults({
    required this.query,
    required this.results,
    required this.hasMore,
    this.recent = const [],
    this.loadingMore = false,
    this.processingIds = const {},
    this.notice,
    this.confirmReplace,
  });

  final String query;
  final List<Movie> results;
  final bool hasMore;
  final bool loadingMore;
  final List<String> recent;
  final Set<String> processingIds;

  /// A transient notice (snackbar / message) to show once.
  final FindFilmNotice? notice;

  /// A pending replace confirmation to surface as a dialog.
  final ReplaceConfirmNotice? confirmReplace;

  FindFilmResults copyWith({
    List<Movie>? results,
    bool? hasMore,
    bool? loadingMore,
    List<String>? recent,
    Set<String>? processingIds,
    FindFilmNotice? notice,
    bool clearNotice = false,
    ReplaceConfirmNotice? confirmReplace,
    bool clearConfirmReplace = false,
  }) {
    return FindFilmResults(
      query: query,
      results: results ?? this.results,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      recent: recent ?? this.recent,
      processingIds: processingIds ?? this.processingIds,
      notice: clearNotice ? null : (notice ?? this.notice),
      confirmReplace:
          clearConfirmReplace ? null : (confirmReplace ?? this.confirmReplace),
    );
  }

  @override
  List<Object?> get props => [
        query,
        results,
        hasMore,
        loadingMore,
        recent,
        processingIds,
        notice,
        confirmReplace,
      ];
}

/// Notices delivered once via the UI (snackbars / dialogs).
///
/// Equality is based on [id] only; each emitted notice gets a fresh sequence id,
/// so the UI can detect new notices regardless of payload equality.
sealed class FindFilmNotice extends Equatable {
  const FindFilmNotice(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

final class AddedNotice extends FindFilmNotice {
  const AddedNotice(super.id, this.film, this.target, this.movedFromWatchlist);
  final Movie film;
  final AddTarget target;
  final bool movedFromWatchlist;
}

final class RemovedNotice extends FindFilmNotice {
  const RemovedNotice(super.id, this.film, this.target);
  final Movie film;
  final AddTarget target;
}

final class ReplaceConfirmNotice extends FindFilmNotice {
  const ReplaceConfirmNotice(
    super.id,
    this.film,
    this.slot,
    this.slotFilmId,
    this.slotTitle,
  );
  final Movie film;
  final int slot;
  final String slotFilmId;
  final String? slotTitle;
}

final class Top5FullNotice extends FindFilmNotice {
  const Top5FullNotice(super.id);
}

final class AlreadyWatchedNotice extends FindFilmNotice {
  const AlreadyWatchedNotice(super.id, this.film);
  final Movie film;
}

final class AddFailedNotice extends FindFilmNotice {
  const AddFailedNotice(super.id, this.message);
  final String message;
}

final class ActionFailedNotice extends FindFilmNotice {
  const ActionFailedNotice(super.id, this.message);
  final String message;
}
