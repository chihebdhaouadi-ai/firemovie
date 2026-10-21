import 'package:equatable/equatable.dart';

import '../../domain/movie_review_summary.dart';
import '../../domain/take.dart';

sealed class AsyncView<T> extends Equatable {
  const AsyncView();

  @override
  List<Object?> get props => const [];
}

final class AsyncLoading<T> extends AsyncView<T> {
  const AsyncLoading();
}

final class AsyncFailed<T> extends AsyncView<T> {
  const AsyncFailed();
}

final class AsyncReady<T> extends AsyncView<T> {
  const AsyncReady(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class MovieReviewsState extends Equatable {
  const MovieReviewsState({
    this.summary = const AsyncLoading(),
    this.takes = const AsyncLoading(),
  });

  final AsyncView<MovieReviewSummary> summary;
  final AsyncView<List<Take>> takes;

  MovieReviewsState copyWith({
    AsyncView<MovieReviewSummary>? summary,
    AsyncView<List<Take>>? takes,
  }) {
    return MovieReviewsState(
      summary: summary ?? this.summary,
      takes: takes ?? this.takes,
    );
  }

  @override
  List<Object?> get props => [summary, takes];
}
