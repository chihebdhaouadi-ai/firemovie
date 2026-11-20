import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/topic_detail_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/take_actions.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/trending_topics_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_test/flutter_test.dart';

const _viewport = Size(800, 900);

Take _topic({int commentCount = 1}) => Take(
      id: 42,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: null,
      body: 'Is the ending a cop-out?',
      votes: const {},
      myVotes: const {},
      commentCount: commentCount,
      isMostHelpful: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      tag: TakeTag.question,
      topicVotes: const {TopicVote.like: 3},
    );

const _heat = Film(imdbId: 'tt0113277', title: 'Heat');

FeedItem _item() => FeedItem(film: _heat, take: _topic());

TakeComment _comment({int id = 9, int likes = 0, int dislikes = 0}) =>
    TakeComment(
      id: id,
      authorId: 5,
      authorName: 'leo',
      body: 'Totally a cop-out.',
      isWriter: false,
      likes: likes,
      dislikes: dislikes,
    );

/// In-memory repository for the topic page. Only the calls it makes are real.
class _TopicReviews implements ReviewRepository {
  _TopicReviews({List<TakeComment>? comments})
      : comments = comments ?? [_comment()];

  final List<TakeComment> comments;
  final List<(int, TopicVote, bool)> voteCalls = [];
  final List<String> posted = [];

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async =>
      List.of(comments);

  @override
  Future<TakeComment> setCommentVote(
    int commentId,
    TopicVote kind, {
    required bool active,
  }) async {
    voteCalls.add((commentId, kind, active));
    final current = comments.firstWhere((c) => c.id == commentId);
    final updated = current.withMyVote(active ? kind : null);
    comments[comments.indexOf(current)] = updated;
    return updated;
  }

  @override
  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,
    XFile? image,
  }) async {
    posted.add(body);
    final comment = TakeComment(
      id: 100 + posted.length,
      authorId: 1,
      authorName: 'me',
      body: body,
      isWriter: false,
      parentId: parentId,
      stance: stance,
    );
    comments.add(comment);
    return comment;
  }

  @override
  Future<Take> setTopicVote(int takeId, TopicVote kind,
      {required bool active}) async {
    topicVoteCalls.add((takeId, kind, active));
    final topic = _topic();
    return Take(
      id: topic.id,
      authorId: topic.authorId,
      authorName: topic.authorName,
      isMine: false,
      reaction: null,
      body: topic.body,
      votes: const {},
      myVotes: const {},
      commentCount: topic.commentCount,
      isMostHelpful: false,
      tag: topic.tag,
      topicVotes: {TopicVote.like: active ? 4 : 3},
      myTopicVotes: {if (active) TopicVote.like},
    );
  }

  final List<(int, TopicVote, bool)> topicVoteCalls = [];
  final List<(int, bool)> saveCalls = [];

  @override
  Future<Take> setSaved(int takeId, {required bool active}) async {
    saveCalls.add((takeId, active));
    return _topic().copyWith(isSaved: active);
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
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('leads with the question, then the movie and the comments',
      (tester) async {
    final reviews = _TopicReviews();
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    expect(find.text('Is the ending a cop-out?'), findsOneWidget);
    expect(find.text('Heat'), findsOneWidget);
    expect(find.text('ABOUT THIS MOVIE'), findsOneWidget);
    expect(find.text('1 comment'), findsOneWidget);
    expect(find.text('Totally a cop-out.'), findsOneWidget);
    expect(find.text('Be the first to answer.'), findsNothing);
  });

  testWidgets('shows the empty prompt when nobody has commented',
      (tester) async {
    await _pump(
      tester,
      TopicDetailScreen(
        item: _item(),
        repository: _TopicReviews(comments: []),
      ),
    );

    expect(find.text('No comments yet'), findsOneWidget);
    expect(find.text('Be the first to answer.'), findsOneWidget);
  });

  testWidgets('topics and their comments have no like or dislike',
      (tester) async {
    final reviews = _TopicReviews(comments: [_comment(likes: 2)]);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    expect(find.byIcon(BootstrapIcons.hand_thumbs_up), findsNothing);
    expect(find.byIcon(BootstrapIcons.hand_thumbs_down), findsNothing);
    expect(find.text('Reply'), findsWidgets);
  });

  testWidgets('a topic has one reaction, a heart, saved as a like',
      (tester) async {
    final reviews = _TopicReviews();
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    final heart = find.byKey(const Key('take-heart-42'));
    expect(heart, findsOneWidget);
    expect(
      find.descendant(of: heart, matching: find.text('3')),
      findsOneWidget,
    );

    await tester.tap(heart);
    await tester.pumpAndSettle();

    expect(reviews.topicVoteCalls, [(42, TopicVote.like, true)]);
    expect(find.byIcon(BootstrapIcons.heart_fill), findsOneWidget);
    expect(
      find.descendant(of: heart, matching: find.text('4')),
      findsOneWidget,
    );
  });

  testWidgets('the comments can fill the page and shrink back', (tester) async {
    final reviews = _TopicReviews(comments: [_comment(likes: 0)]);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );
    // The take's options button sits in the app bar, so it stays in view.
    final topicMenu = find.byType(TakeTopActions).hitTestable();
    expect(topicMenu, findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-comments-expand')));
    await tester.pumpAndSettle();
    expect(find.byIcon(BootstrapIcons.arrows_angle_contract), findsOneWidget);
    expect(topicMenu, findsOneWidget);

    await tester.tap(find.byKey(const Key('topic-comments-expand')));
    await tester.pumpAndSettle();
    expect(find.byIcon(BootstrapIcons.arrows_angle_expand), findsOneWidget);
    expect(topicMenu, findsOneWidget);
  });

  testWidgets('comments can show a photo, and the box offers one',
      (tester) async {
    const photo = TakeComment(
      id: 12,
      authorId: 5,
      authorName: 'leo',
      body: '',
      isWriter: false,
      imageUrl: 'https://example.com/still.jpg',
    );
    await _pump(
      tester,
      TopicDetailScreen(
        item: _item(),
        repository: _TopicReviews(comments: [photo]),
      ),
    );

    expect(find.byKey(const Key('comment-photo-12')), findsOneWidget);
    expect(find.byKey(const Key('comment-add-photo')), findsOneWidget);
  });

  testWidgets('a take opens on the same page, with feelings instead of a tag',
      (tester) async {
    final take = Take(
      id: 43,
      authorId: 7,
      authorName: 'maya',
      isMine: false,
      reaction: FilmReaction.loved,
      authorReactions: const [FilmReaction.loved, FilmReaction.shocked],
      body: 'A heist film with a soul.',
      votes: const {},
      myVotes: const {},
      commentCount: 1,
      isMostHelpful: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      tag: TakeTag.review,
    );
    await _pump(
      tester,
      TopicDetailScreen(
        item: FeedItem(film: _heat, take: take),
        repository: _TopicReviews(),
      ),
    );

    expect(find.text('Take'), findsOneWidget);
    expect(find.text('QUESTION'), findsNothing);
    expect(find.byKey(const Key('take-feelings')), findsOneWidget);
    expect(find.text('Loved it'), findsOneWidget);
    expect(find.text('A heist film with a soul.'), findsOneWidget);
    expect(find.text('Totally a cop-out.'), findsOneWidget);
  });

  testWidgets('posting a comment appends it to the thread', (tester) async {
    final reviews = _TopicReviews(comments: []);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    await tester.enterText(find.byType(TextField), 'Not at all, it is fair.');
    await tester.tap(find.byIcon(BootstrapIcons.send_fill));
    await tester.pumpAndSettle();

    expect(reviews.posted, ['Not at all, it is fair.']);
    expect(find.text('Not at all, it is fair.'), findsOneWidget);
    expect(find.text('Be the first to answer.'), findsNothing);
  });

  testWidgets('tapping a trending topic opens its topic page', (tester) async {
    final reviews = _TopicReviews(comments: []);
    final topicReviews = _TrendingReviews(_item(), reviews);
    await _pump(
      tester,
      Scaffold(
        body: TrendingTopicsSection(reviews: topicReviews),
      ),
    );

    await tester.tap(find.text('Is the ending a cop-out?'));
    await tester.pumpAndSettle();

    expect(find.byType(TopicDetailScreen), findsOneWidget);
    expect(find.text('Topic'), findsWidgets);
  });

  testWidgets(
      'the topic page\'s ⋯ options show Share, Save and Report; the author gets Edit and Delete instead',
      (tester) async {
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: _TopicReviews()),
    );
    expect(find.byKey(const Key('take-top-share')), findsNothing);
    await tester.tap(find.byKey(const Key('take-top-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('take-top-share')), findsOneWidget);
    expect(find.byKey(const Key('take-top-save')), findsOneWidget);
    expect(find.byKey(const Key('take-top-report')), findsOneWidget);
    expect(find.byKey(const Key('take-top-edit')), findsNothing);
    expect(find.byKey(const Key('take-top-delete')), findsNothing);
  });

  testWidgets('saving someone else\'s topic fills the bookmark and says where it went',
      (tester) async {
    final reviews = _TopicReviews();
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    await tester.tap(find.byKey(const Key('take-top-menu')));
    await tester.pumpAndSettle();
    expect(find.byIcon(BootstrapIcons.bookmark), findsOneWidget);
    await tester.tap(find.byKey(const Key('take-top-save')));
    await tester.pumpAndSettle();

    expect(reviews.saveCalls, [(42, true)]);
    expect(find.text('Saved to your profile'), findsOneWidget);
    // Reopened, the options now offer to unsave.
    await tester.tap(find.byKey(const Key('take-top-menu')));
    await tester.pumpAndSettle();
    expect(find.byIcon(BootstrapIcons.bookmark_fill), findsOneWidget);
  });

  testWidgets('the author of a topic sees Edit and Delete in the ⋯ options',
      (tester) async {
    final mine = FeedItem(
      film: _heat,
      take: Take(
        id: 43,
        authorId: 1,
        authorName: 'me',
        isMine: true,
        reaction: null,
        body: 'My own question',
        votes: const {},
        myVotes: const {},
        commentCount: 0,
        isMostHelpful: false,
        tag: TakeTag.question,
      ),
    );
    await _pump(
      tester,
      TopicDetailScreen(item: mine, repository: _TopicReviews()),
    );
    await tester.tap(find.byKey(const Key('take-top-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('take-top-share')), findsOneWidget);
    expect(find.byKey(const Key('take-top-edit')), findsOneWidget);
    expect(find.byKey(const Key('take-top-delete')), findsOneWidget);
    expect(find.byKey(const Key('take-top-report')), findsNothing);
    // You can't save your own topic.
    expect(find.byKey(const Key('take-top-save')), findsNothing);
  });
}

/// Serves one trending topic and forwards the topic page's calls.
class _TrendingReviews extends _TopicReviews {
  _TrendingReviews(this._item, _TopicReviews inner)
      : super(comments: inner.comments);

  final FeedItem _item;

  @override
  Future<List<FeedItem>> fetchTrendingTopics() async => [_item];
}
