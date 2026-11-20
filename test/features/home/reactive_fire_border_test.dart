import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/home/views/widgets/reactive_fire_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Take _take(Map<VoteKind, int> votes) => Take(
      id: 1,
      authorId: 1,
      authorName: 'Ada',
      isMine: false,
      reaction: FilmReaction.loved,
      body: 'Great film',
      votes: votes,
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
    );

void main() {
  test('a review with no reactions has no heat', () {
    expect(fireHeatFor(_take(const {})), 0);
  });

  test('heat rises with weighted reactions and stays below full fire', () {
    final few = fireHeatFor(_take(const {VoteKind.down: 1}));
    final some = fireHeatFor(_take(const {VoteKind.draw: 3}));
    final many = fireHeatFor(_take(const {VoteKind.up: 40}));

    expect(few, greaterThan(0));
    expect(some, greaterThan(few));
    expect(many, greaterThan(some));
    expect(many, lessThan(1));
  });

  test('changed my mind weighs more than well argued', () {
    final changed = fireHeatFor(_take(const {VoteKind.up: 2}));
    final argued = fireHeatFor(_take(const {VoteKind.draw: 2}));

    expect(changed, greaterThan(argued));
  });

  test('the leading reaction picks the fire color', () {
    expect(
      fireColorFor(
          _take(const {VoteKind.draw: 5, VoteKind.up: 2})),
      const Color(0xFFFFC53D),
    );
    expect(
      fireColorFor(_take(
          const {VoteKind.up: 4, VoteKind.down: 1})),
      const Color(0xFF4ADE80),
    );
    expect(
      fireColorFor(_take(const {VoteKind.down: 3})),
      const Color(0xFFFF5C7A),
    );
  });

  test('a review nobody reacted to uses the ember color', () {
    expect(fireColorFor(_take(const {})), const Color(0xFFFF8A3D));
  });
}
