import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/poll_option.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/tabs/explore_tab.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _pollBody = 'Best Nolan film?';

Take _take({
  required int id,
  required TakeTag tag,
  required String body,
  bool spoiler = false,
  String scene = '',
  String timecode = '',
  List<PollOption> pollOptions = const [],
  int? myPollOptionId,
}) =>
    Take(
      id: id,
      authorId: id + 100,
      authorName: 'writer$id',
      isMine: false,
      reaction: tag == TakeTag.review ? FilmReaction.loved : null,
      body: body,
      votes: const {VoteKind.changedMyMind: 0},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
      tag: tag,
      spoiler: spoiler,
      scene: scene,
      timecode: timecode,
      pollOptions: pollOptions,
      myPollOptionId: myPollOptionId,
    );

FeedItem _item(Take take, {String? title}) => FeedItem(
      film: Film(imdbId: 'tt${take.id}', title: title),
      take: take,
    );

final _pollTake = _take(
  id: 2,
  tag: TakeTag.poll,
  body: _pollBody,
  pollOptions: const [
    PollOption(id: 1, label: 'Memento', votes: 4),
    PollOption(id: 2, label: 'Inception', votes: 6),
  ],
);

class _FeedRepository implements ReviewRepository {
  _FeedRepository(this.items);

  final List<FeedItem> items;
  final List<int> pollVotes = [];
  bool failPollVote = false;

  @override
  Future<List<FeedItem>> fetchExploreFeed() async => items;

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async => const [];

  @override
  Future<Take> setPollVote(int takeId, int optionId) async {
    if (failPollVote) throw Exception('refused');
    pollVotes.add(optionId);
    final base = items.firstWhere((item) => item.take.id == takeId).take;
    return base.withPollVote(optionId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, _FeedRepository repository) async {
  tester.view.physicalSize = const Size(720, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SafeArea(child: ExploreTab(reviews: repository)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('filter chips keep only the chosen kind of post', (tester) async {
    final repository = _FeedRepository([
      _item(_take(id: 1, tag: TakeTag.review, body: 'Review body here')),
      _item(_pollTake),
    ]);
    await _pump(tester, repository);

    expect(find.text('Review body here'), findsOneWidget);
    expect(find.text(_pollBody), findsOneWidget);

    await tester.tap(find.text(_en.exploreFilterPolls));
    await tester.pumpAndSettle();

    expect(find.text('Review body here'), findsNothing);
    expect(find.text(_pollBody), findsOneWidget);
  });

  testWidgets('a filter with no matches shows the caught-up state',
      (tester) async {
    final repository = _FeedRepository([
      _item(_take(id: 1, tag: TakeTag.review, body: 'Review body here')),
    ]);
    await _pump(tester, repository);

    await tester.tap(find.text(_en.exploreFilterScenes));
    await tester.pumpAndSettle();

    expect(find.text(_en.exploreCaughtUp), findsOneWidget);
  });

  testWidgets('voting shows the new split at once and sends the vote',
      (tester) async {
    final repository = _FeedRepository([_item(_pollTake)]);
    await _pump(tester, repository);

    expect(find.text('%'), findsNothing);
    expect(find.text(_en.pollVoteHint), findsOneWidget);

    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();

    expect(repository.pollVotes, [2]);
    // 7 of 11 votes after the viewer's own vote.
    expect(find.text('64%'), findsOneWidget);
    expect(find.text(_en.exploreThanksVoting), findsOneWidget);
  });

  testWidgets('a refused poll vote rolls the split back and says so',
      (tester) async {
    final repository = _FeedRepository([_item(_pollTake)])..failPollVote = true;
    await _pump(tester, repository);

    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();

    expect(find.text('%'), findsNothing);
    expect(find.text('64%'), findsNothing);
    expect(find.text(_en.pollVoteHint), findsOneWidget);
    expect(find.text(_en.reviewVoteFailed), findsOneWidget);
  });

  testWidgets('a spoiler take hides its body until the reader taps reveal',
      (tester) async {
    final repository = _FeedRepository([
      _item(_take(
        id: 3,
        tag: TakeTag.hotTake,
        body: 'He was the ghost all along',
        spoiler: true,
      )),
    ]);
    await _pump(tester, repository);

    expect(find.text(_en.topicSpoilerLabel), findsOneWidget);
    expect(find.text(_en.exploreSpoilerReveal), findsOneWidget);

    await tester.tap(find.text(_en.topicSpoilerLabel));
    await tester.pumpAndSettle();

    expect(find.text(_en.topicSpoilerLabel), findsNothing);
  });

  testWidgets('a scene shows its film, scene name and timecode',
      (tester) async {
    final repository = _FeedRepository([
      _item(
        _take(
          id: 4,
          tag: TakeTag.scene,
          body: 'Nothing moves but the talk.',
          scene: 'The interrogation room',
          timecode: '1h 12m',
        ),
        title: 'The Dark Knight',
      ),
    ]);
    await _pump(tester, repository);

    expect(find.text('The Dark Knight'), findsOneWidget);
    expect(find.text(_en.topicTagScene.toUpperCase()), findsOneWidget);
    expect(find.text('The interrogation room'), findsOneWidget);
    expect(find.text('1h 12m'), findsOneWidget);
    expect(find.text('Nothing moves but the talk.'), findsOneWidget);
  });
}
