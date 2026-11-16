import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_parser.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/people_takes.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));

Take _take(int id, int authorId, String name, {bool top = false}) => Take(
      id: id,
      authorId: authorId,
      authorName: name,
      isMine: false,
      reaction: FilmReaction.loved,
      body: 'take $id',
      votes: const {},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: top,
    );

void main() {
  test('groups takes per person in the order people first appear', () {
    final groups = PeopleTakes.groupByPerson([
      _take(1, 10, 'Sam'),
      _take(2, 20, 'Lou'),
      _take(3, 10, 'Sam'),
    ]);

    expect(groups.map((g) => g.map((t) => t.id).toList()), [
      [1, 3],
      [2],
    ]);
  });

  testWidgets('shows two takes per person and reveals the rest',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PeopleTakes(
              movieId: 'tt1',
              takes: [
                _take(1, 10, 'Sam', top: true),
                _take(2, 10, 'Sam'),
                _take(3, 10, 'Sam'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sam'), findsOneWidget);
    expect(find.text(_en.filmTakeCount(3)), findsOneWidget);
    expect(find.text(_en.filmTopTake), findsOneWidget);
    expect(find.textContaining('take 3'), findsNothing);

    await tester.tap(find.text(_en.filmShowMoreTakes(1)));
    await tester.pump();

    expect(find.textContaining('take 3'), findsOneWidget);
    expect(find.text(_en.filmShowLessTakes), findsOneWidget);
  });

  test('the summary keeps every feeling count for the audience bar', () {
    final summary = ReviewParser.summary(summaryJson());

    expect(summary.allCounts.map((c) => (c.reaction, c.count)), [
      (FilmReaction.loved, 4),
      (FilmReaction.masterpiece, 2),
    ]);
  });
}
