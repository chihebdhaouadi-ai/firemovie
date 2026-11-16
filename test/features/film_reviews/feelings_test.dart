import 'package:film_wise_mobile/features/film_reviews/data/reactions_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_parser.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/state/movie_reviews_cubit.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/state/movie_reviews_state.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/movie_review_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

void main() {
  test('summary parses all feelings in pick order and the people total', () {
    final summary = ReviewParser.summary({
      ...summaryJson(myReaction: 'made_think'),
      'my_reactions': ['made_think', 'loved', 'not_a_feeling'],
    });
    expect(summary.feelings, [FilmReaction.madeThink, FilmReaction.loved]);
    expect(summary.total, 6);
  });

  test('older payloads without my_reactions fall back to my_reaction', () {
    final summary = ReviewParser.summary(summaryJson(myReaction: 'bored'));
    expect(summary.feelings, [FilmReaction.bored]);
  });

  test('cubit saves feelings and rolls back when the save fails', () async {
    final api = ReviewApi();
    final reactions = FakeReactionsRepository(fail: true);
    final cubit = MovieReviewsCubit(
      filmId: 'tt1',
      repository: reviewRepositoryFor(api.client),
      reactions: reactions,
    );
    addTearDown(cubit.close);
    await cubit.load();

    final saved = await cubit.setFeelings(
      [FilmReaction.loved, FilmReaction.shocked],
    );

    expect(saved, isFalse);
    final summary = cubit.state.summary as AsyncReady<MovieReviewSummary>;
    expect(summary.value.feelings, isEmpty);

    reactions.fail = false;
    expect(await cubit.setFeelings([FilmReaction.loved]), isTrue);
    expect(
      (cubit.state.summary as AsyncReady<MovieReviewSummary>).value.feelings,
      [FilmReaction.loved],
    );
  });
}
