import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/review_repository.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import '../../domain/take.dart';
import '../../domain/vote_kind.dart';
import 'movie_reviews_state.dart';

class MovieReviewsCubit extends Cubit<MovieReviewsState> {
  MovieReviewsCubit(
      {required this.filmId, required ReviewRepository repository})
      : _repository = repository,
        super(const MovieReviewsState());

  final String filmId;
  final ReviewRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(
      summary: const AsyncLoading(),
      takes: const AsyncLoading(),
    ));
    await Future.wait([_loadSummary(), _loadTakes()]);
  }

  Future<bool> setReaction(FilmReaction? reaction) async {
    final previous = state.summary;
    final canRollBack = previous is AsyncReady<MovieReviewSummary>;
    if (canRollBack) {
      emit(state.copyWith(
        summary: AsyncReady(previous.value.withReaction(reaction)),
      ));
    }
    final MovieReviewSummary summary;
    try {
      summary = await _repository.setReaction(filmId, reaction);
    } catch (_) {
      if (canRollBack && !isClosed) emit(state.copyWith(summary: previous));
      return false;
    }
    if (isClosed) return true;
    emit(state.copyWith(summary: AsyncReady(summary)));
    await _loadTakes();
    return true;
  }

  Future<bool> shareTake(String body) async {
    final Take take;
    try {
      take = await _repository.postTake(filmId, body: body);
    } catch (_) {
      return false;
    }
    if (isClosed) return true;
    final current = state.takes;
    if (current is AsyncReady<List<Take>>) {
      emit(state.copyWith(
        takes: AsyncReady([take, ...current.value]),
      ));
    } else {
      await _loadTakes();
    }
    return true;
  }

  Future<bool> setVote(int takeId, VoteKind kind) async {
    final current = _findTake(takeId);
    if (current == null) return false;
    final Take updated;
    try {
      updated = await _repository.setVote(
        takeId,
        kind,
        active: !current.hasVoted(kind),
      );
    } catch (_) {
      return false;
    }
    if (isClosed) return true;
    _replaceTake(updated);
    await _loadTakes();
    return true;
  }

  Future<List<TakeComment>?> loadComments(int takeId) async {
    try {
      return await _repository.fetchComments(takeId);
    } catch (_) {
      return null;
    }
  }

  Future<TakeComment?> postComment(
    int takeId,
    String body, {
    int? parentId,
  }) async {
    final TakeComment comment;
    try {
      comment = await _repository.postComment(
        takeId,
        body: body,
        parentId: parentId,
      );
    } catch (_) {
      return null;
    }
    if (!isClosed) await _loadTakes();
    return comment;
  }

  Take? _findTake(int takeId) {
    final current = state.takes;
    if (current is! AsyncReady<List<Take>>) return null;
    for (final take in current.value) {
      if (take.id == takeId) return take;
    }
    return null;
  }

  void _replaceTake(Take updated) {
    final current = state.takes;
    if (current is! AsyncReady<List<Take>>) return;
    emit(state.copyWith(
      takes: AsyncReady([
        for (final take in current.value)
          take.id == updated.id ? updated : take,
      ]),
    ));
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _repository.fetchSummary(filmId);
      if (isClosed) return;
      emit(state.copyWith(summary: AsyncReady(summary)));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(summary: const AsyncFailed()));
    }
  }

  Future<void> _loadTakes() async {
    try {
      final takes = await _repository.fetchTakes(filmId);
      if (isClosed) return;
      emit(state.copyWith(takes: AsyncReady(takes)));
    } catch (_) {
      if (isClosed || state.takes is AsyncReady) return;
      emit(state.copyWith(takes: const AsyncFailed()));
    }
  }
}
