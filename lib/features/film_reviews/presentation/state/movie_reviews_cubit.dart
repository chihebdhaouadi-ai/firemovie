import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../find/data/movie.dart' show ServerFailure;

import '../../data/reactions_repository.dart';
import '../../data/review_repository.dart';
import '../../domain/film_reaction.dart';
import '../../domain/movie_review_summary.dart';
import '../../domain/review_stance.dart';
import '../../domain/take.dart';
import '../../domain/take_skin.dart';
import '../../domain/vote_kind.dart';
import 'movie_reviews_state.dart';

/// How sharing a take ended, so the composer can say what to do next.
enum ShareTakeOutcome {
  shared,

  /// The viewer has not picked how the film made them feel yet.
  needsFeeling,

  /// The viewer already shared a review of this film.
  alreadyShared,

  failed,
}

class MovieReviewsCubit extends Cubit<MovieReviewsState> {
  MovieReviewsCubit({
    required this.filmId,
    required ReviewRepository repository,
    ReactionsRepository? reactions,
  })  : _repository = repository,
        _reactions = reactions,
        super(const MovieReviewsState());

  final String filmId;
  final ReviewRepository _repository;

  /// Where this page saves its takes; widgets on the page share it.
  ReviewRepository get repository => _repository;
  final ReactionsRepository? _reactions;

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

  /// Saves up to three feelings at once (empty clears them). Shows the new
  /// feelings straight away and rolls back if the save fails.
  Future<bool> setFeelings(List<FilmReaction> feelings) async {
    final picked =
        feelings.take(MovieReviewSummary.maxFeelings).toList(growable: false);
    final previous = state.summary;
    final canRollBack = previous is AsyncReady<MovieReviewSummary>;
    if (canRollBack) {
      emit(state.copyWith(
        summary: AsyncReady(previous.value.withFeelings(picked)),
      ));
    }
    final MovieReviewSummary summary;
    try {
      summary = await (_reactions ?? ApiReactionsRepository())
          .setFeelings(filmId, picked);
    } catch (_) {
      if (canRollBack && !isClosed) emit(state.copyWith(summary: previous));
      return false;
    }
    if (isClosed) return true;
    emit(state.copyWith(summary: AsyncReady(summary)));
    await _loadTakes();
    return true;
  }

  Future<bool> shareTake(
    String body, {
    TakeSkin skin = TakeSkin.normal,
    bool spoiler = false,
  }) async =>
      await shareTakeOutcome(body, skin: skin, spoiler: spoiler) ==
      ShareTakeOutcome.shared;

  /// Shares a take and says why it failed when the server refuses it.
  Future<ShareTakeOutcome> shareTakeOutcome(
    String body, {
    TakeSkin skin = TakeSkin.normal,
    bool spoiler = false,
  }) async {
    final Take take;
    try {
      take = await _repository.postTake(
        filmId,
        body: body,
        skin: skin,
        spoiler: spoiler,
      );
    } on ServerFailure catch (failure) {
      return switch (failure.code) {
        'reaction_required' => ShareTakeOutcome.needsFeeling,
        'already_posted' => ShareTakeOutcome.alreadyShared,
        _ => ShareTakeOutcome.failed,
      };
    } catch (_) {
      return ShareTakeOutcome.failed;
    }
    if (isClosed) return ShareTakeOutcome.shared;
    final current = state.takes;
    if (current is AsyncReady<List<Take>>) {
      emit(state.copyWith(
        takes: AsyncReady([take, ...current.value]),
      ));
    } else {
      await _loadTakes();
    }
    return ShareTakeOutcome.shared;
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
    ReviewStance? stance,
  }) async {
    final TakeComment comment;
    try {
      comment = await _repository.postComment(
        takeId,
        body: body,
        parentId: parentId,
        stance: stance,
      );
    } catch (_) {
      return null;
    }
    if (!isClosed) await _loadTakes();
    return comment;
  }

  /// Shows the author's edited take in place of the old one.
  void takeEdited(Take updated) => _replaceTake(updated);

  Take? _findTake(int takeId) {
    final current = state.takes;
    if (current is! AsyncReady<List<Take>>) return null;
    for (final take in current.value) {
      if (take.id == takeId) return take;
    }
    return null;
  }

  /// Keeps a take changed elsewhere on the page (a heart, say).
  void takeChanged(Take updated) {
    if (!isClosed) _replaceTake(updated);
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
