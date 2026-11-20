import 'package:film_wise_mobile/core/avatar_frames.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/avatar_frame.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_parser.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/topic_detail_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/people_takes.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));

Take _take(
  int id,
  int authorId,
  String name, {
  bool top = false,
  int comments = 0,
  List<FilmReaction> feelings = const [],
  String? body,
}) =>
    Take(
      id: id,
      authorId: authorId,
      authorName: name,
      isMine: false,
      reaction: FilmReaction.loved,
      body: body ?? 'take $id',
      votes: const {},
      myVotes: const {},
      commentCount: comments,
      isMostHelpful: top,
      authorReactions: feelings,
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
    // No take count under the name any more; the takes speak for themselves.
    expect(find.text(_en.filmTakeCount(3)), findsNothing);
    expect(find.text(_en.filmTopTake), findsOneWidget);
    expect(find.textContaining('take 3'), findsNothing);

    await tester.ensureVisible(find.text(_en.filmShowMoreTakes(1)));
    await tester.tap(find.text(_en.filmShowMoreTakes(1)));
    await tester.pump();

    expect(find.textContaining('take 3'), findsOneWidget);
    expect(find.text(_en.filmShowLessTakes), findsOneWidget);
  });

  testWidgets('each take card shows its comments and opens the take page',
      (tester) async {
    final api = ReviewApi(takes: [takeJson(id: 7, body: 'take 7')]);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PeopleTakes(
              movieId: 'tt1',
              repository: reviewRepositoryFor(api.client),
              takes: [_take(7, 10, 'Sam', comments: 3)],
            ),
          ),
        ),
      ),
    );

    // Comments sit on the line under the name: an icon and the count.
    expect(find.bySemanticsLabel(_en.filmTakeComments(3)), findsOneWidget);
    // A heart is the only reaction; no up / draw / down.
    expect(find.byKey(const Key('take-heart-7')), findsOneWidget);
    for (final kind in ['up', 'draw', 'down']) {
      expect(find.byKey(Key('vote-$kind')), findsNothing);
    }

    await tester.tap(find.textContaining('take 7'));
    await tester.pumpAndSettle();

    expect(find.byType(TopicDetailScreen), findsOneWidget);
  });

  test('a take carries its author\'s current feelings', () {
    final take = ReviewParser.take({
      ...takeJson(),
      'author_reactions': ['made_think', 'loved', 'nope', 'masterpiece'],
    });

    expect(take.authorFeelings, [
      FilmReaction.madeThink,
      FilmReaction.loved,
      FilmReaction.masterpiece,
    ]);
    // Older servers only send the one feeling stored on the take.
    expect(ReviewParser.take(takeJson()).authorFeelings, [FilmReaction.loved]);
  });

  testWidgets('each person shows all three of their feelings', (tester) async {
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
                _take(1, 10, 'Sam', feelings: const [
                  FilmReaction.madeCry,
                  FilmReaction.blewMind,
                  FilmReaction.masterpiece,
                ]),
              ],
            ),
          ),
        ),
      ),
    );

    // Shown as icons; screen readers hear them all, in pick order.
    final felt = [
      _en.reviewReactionMadeCry,
      _en.reviewReactionBlewMind,
      _en.reviewReactionMasterpiece,
    ].join(', ');
    expect(
      find.bySemanticsLabel(_en.filmPersonFeelings(felt)),
      findsOneWidget,
    );
    // The one stored on the take is not shown on top of them.
    expect(find.byTooltip(_en.reviewReactionLoved), findsNothing);
    expect(find.byTooltip(_en.reviewReactionMasterpiece), findsOneWidget);
  });

  testWidgets('a long take folds to 8 lines and opens with more',
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
                _take(1, 10, 'Sam', body: 'word ' * 300),
                _take(2, 20, 'Lou', body: 'Short and sweet.'),
              ],
            ),
          ),
        ),
      ),
    );

    // Only the long take offers more.
    expect(find.text(_en.overviewShowMore), findsOneWidget);

    await tester.ensureVisible(find.text(_en.overviewShowMore));
    await tester.tap(find.text(_en.overviewShowMore));
    await tester.pump();

    expect(find.text(_en.overviewShowLess), findsOneWidget);
    // Expanding stays on the film page instead of opening the take.
    expect(find.byType(TopicDetailScreen), findsNothing);
  });

  test('frames: takes and friends carry them, unknown keys fall back', () {
    expect(
      ReviewParser.take({...takeJson(), 'author_frame': 'gold'}).authorFrame,
      'gold',
    );
    final friend = ReviewParser.friendActivityItem({
      'user': {'id': 1, 'username': 'ana', 'equipped_frame': 'legend'},
      'reaction': 'loved',
      'take': null,
      'updated_at': '2026-11-16T12:00:00Z',
    });
    expect(friend.frame, 'legend');
    expect(frameKeyOrDefault('gold'), 'gold');
    expect(frameKeyOrDefault('not-shipped-yet'), defaultFrameKey);
    expect(frameKeyOrDefault(null), defaultFrameKey);
  });

  testWidgets('each person wears their own frame', (tester) async {
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
                Take(
                  id: 1,
                  authorId: 10,
                  authorName: 'Sam',
                  isMine: false,
                  reaction: FilmReaction.loved,
                  body: 'Great',
                  votes: const {},
                  myVotes: const {},
                  commentCount: 0,
                  isMostHelpful: false,
                  authorFrame: 'gold',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.widget<AvatarFrame>(find.byType(AvatarFrame)).frame, 'gold');
  });

  test('the summary keeps every feeling count for the audience bar', () {
    final summary = ReviewParser.summary(summaryJson());

    expect(summary.allCounts.map((c) => (c.reaction, c.count)), [
      (FilmReaction.loved, 4),
      (FilmReaction.masterpiece, 2),
    ]);
  });
}
