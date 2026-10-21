import 'dart:convert';

import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/movie_review_summary.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/state/movie_reviews_cubit.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/state/movie_reviews_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

void main() {
  late ReviewApi api;
  late MovieReviewsCubit cubit;

  void startWith(List<Map<String, Object?>> takes) {
    api = ReviewApi(takes: takes);
    cubit = MovieReviewsCubit(
      filmId: 'tt1',
      repository: reviewRepositoryFor(api.client),
    );
  }

  setUp(() => startWith([takeJson(id: 1, wellArgued: 2)]));

  tearDown(() => cubit.close());

  List<Take> loadedTakes() => (cubit.state.takes as AsyncReady<List<Take>>).value;

  test('load fills the summary and the takes', () async {
    await cubit.load();

    expect(cubit.state.summary, isA<AsyncReady<MovieReviewSummary>>());
    expect(loadedTakes().map((take) => take.id), [1]);
  });

  test('a failed summary does not hide the takes', () async {
    api.failing.add('summary');

    await cubit.load();

    expect(cubit.state.summary, isA<AsyncFailed<MovieReviewSummary>>());
    expect(cubit.state.takes, isA<AsyncReady<List<Take>>>());
  });

  test('setReaction emits the new summary and reloads takes', () async {
    await cubit.load();

    final ok = await cubit.setReaction(FilmReaction.loved);

    expect(ok, isTrue);
    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(jsonDecode(put.body), {'reaction': 'loved'});
    final summary = cubit.state.summary as AsyncReady<MovieReviewSummary>;
    expect(summary.value.myReaction, FilmReaction.loved);
  });

  test('setReaction returns false and keeps the old summary on failure',
      () async {
    await cubit.load();
    api.failing.add('reaction');

    final ok = await cubit.setReaction(FilmReaction.loved);

    expect(ok, isFalse);
    final summary = cubit.state.summary as AsyncReady<MovieReviewSummary>;
    expect(summary.value.myReaction, isNull);
  });

  test('shareTake prepends the new take to the loaded list', () async {
    await cubit.load();

    final ok = await cubit.shareTake('Stays with you for days.');

    expect(ok, isTrue);
    final takes = loadedTakes();
    expect(takes.first.body, 'Stays with you for days.');
    expect(takes.first.isMine, isTrue);
    expect(takes, hasLength(2));
  });

  test('shareTake returns false when the server refuses', () async {
    await cubit.load();
    api.failing.add('postTake');

    expect(await cubit.shareTake('Nope'), isFalse);
    expect(loadedTakes(), hasLength(1));
  });

  test('setVote adds a vote the viewer has not cast yet', () async {
    await cubit.load();

    final ok = await cubit.setVote(1, VoteKind.wellArgued);

    expect(ok, isTrue);
    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(jsonDecode(put.body), {'active': true});
    expect(loadedTakes().single.hasVoted(VoteKind.wellArgued), isTrue);
    expect(loadedTakes().single.votesOf(VoteKind.wellArgued), 3);
  });

  test('setVote removes a vote the viewer already cast', () async {
    startWith([takeJson(id: 1, wellArgued: 2, myVotes: ['well_argued'])]);
    await cubit.load();

    final ok = await cubit.setVote(1, VoteKind.wellArgued);

    expect(ok, isTrue);
    final put = api.requests.singleWhere((r) => r.method == 'PUT');
    expect(jsonDecode(put.body), {'active': false});
    expect(loadedTakes().single.hasVoted(VoteKind.wellArgued), isFalse);
    expect(loadedTakes().single.votesOf(VoteKind.wellArgued), 1);
  });

  test('setVote returns false for an unknown take', () async {
    await cubit.load();

    expect(await cubit.setVote(999, VoteKind.wellArgued), isFalse);
    expect(api.requests.where((r) => r.method == 'PUT'), isEmpty);
  });

  test('loadComments returns null when the request fails', () async {
    api.failing.add('comments');

    expect(await cubit.loadComments(1), isNull);
  });

  test('postComment returns the comment and reloads takes', () async {
    await cubit.load();

    final comment = await cubit.postComment(1, 'Agreed.');

    expect(comment?.body, 'Agreed.');
    expect(api.comments.single['body'], 'Agreed.');
  });

  test('postComment returns null when the request fails', () async {
    await cubit.load();
    api.failing.add('postComment');

    expect(await cubit.postComment(1, 'Agreed.'), isNull);
  });
}
