import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/luxe_chip.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/trending_topics_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _viewport = Size(390, 844);

Take _topic() => const Take(
      id: 42,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: null,
      body: 'Is the ending a cop-out?',
      votes: {},
      myVotes: {},
      commentCount: 9,
      isMostHelpful: false,
      tag: TakeTag.question,
      topicVotes: {TopicVote.like: 3, TopicVote.dislike: 1},
    );

class _VoteReviews implements ReviewRepository {
  _VoteReviews({this.fail = false});

  final bool fail;
  final List<(int, TopicVote, bool)> calls = [];

  @override
  Future<List<FeedItem>> fetchTrendingTopics() async => [
        FeedItem(film: const Film(imdbId: 'tt0113277', title: 'Heat'), take: _topic()),
      ];

  @override
  Future<Take> setTopicVote(int takeId, TopicVote kind,
      {required bool active}) async {
    calls.add((takeId, kind, active));
    if (fail) throw Exception('network');
    return Take(
      id: takeId,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: null,
      body: 'Is the ending a cop-out?',
      votes: const {},
      myVotes: const {},
      commentCount: 9,
      isMostHelpful: false,
      tag: TakeTag.question,
      topicVotes: {
        TopicVote.like: active && kind == TopicVote.like ? 4 : 3,
        TopicVote.dislike: active && kind == TopicVote.dislike ? 2 : 1,
      },
      myTopicVotes: active ? {kind} : {},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.binding.setSurfaceSize(_viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('tapping like on a trending card sends the vote', (tester) async {
    final reviews = _VoteReviews();
    await _pump(tester, Scaffold(body: TrendingTopicsSection(reviews: reviews)));

    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined).first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(reviews.calls, [(42, TopicVote.like, true)]);
  });

  testWidgets('tapping dislike on a trending card sends the vote', (tester) async {
    final reviews = _VoteReviews();
    await _pump(tester, Scaffold(body: TrendingTopicsSection(reviews: reviews)));

    await tester.tap(find.byIcon(Icons.thumb_down_alt_outlined).first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(reviews.calls, [(42, TopicVote.dislike, true)]);
  });

  testWidgets('a failed vote tells the viewer and keeps the old count',
      (tester) async {
    final reviews = _VoteReviews(fail: true);
    await _pump(tester, Scaffold(body: TrendingTopicsSection(reviews: reviews)));

    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined).first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(reviews.calls, [(42, TopicVote.like, true)]);
    expect(find.text("Couldn't update that vote. Try again."), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('a vote on the card is still there when the topic page opens',
      (tester) async {
    final reviews = _VoteReviews();
    await _pump(tester, Scaffold(body: TrendingTopicsSection(reviews: reviews)));

    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Is the ending a cop-out?'));
    await tester.pump(const Duration(milliseconds: 500));

    // The topic page shows the saved like: 4 likes, 1 dislike, liked by me.
    expect(find.text('4'), findsWidgets);
    // The card stays in the tree under the pushed page, so take the topmost.
    final liked = tester.widget<LuxeCounter>(
      find.ancestor(
        of: find.byIcon(Icons.thumb_up_alt_outlined),
        matching: find.byType(LuxeCounter),
      ).last,
    );
    expect(liked.selected, isTrue);
  });
}
