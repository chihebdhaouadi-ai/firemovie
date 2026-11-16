import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/luxe_palette.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/topic_detail_screen.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/trending_topics_section.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
          {required bool active}) =>
      throw UnimplementedError();

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

  testWidgets('liking a comment bumps the count and reports the vote',
      (tester) async {
    final reviews = _TopicReviews(comments: [_comment(likes: 2)]);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    // The topic's own vote row comes first, so the comment's like is last.
    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined).last);
    await tester.pumpAndSettle();

    expect(reviews.voteCalls, [(9, TopicVote.like, true)]);
    expect(find.text('3'), findsWidgets);
    // The comment's like is the last thumb-up; an active vote is accent-colored.
    final likeIcon = tester.widget<Icon>(
      find.byIcon(Icons.thumb_up_alt_outlined).last,
    );
    expect(likeIcon.color, LuxeColors.accent);
  });

  testWidgets('a dislike replaces an earlier like on the same comment',
      (tester) async {
    final reviews = _TopicReviews(comments: [_comment(likes: 1)]);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.thumb_down_alt_outlined).last);
    await tester.pumpAndSettle();

    expect(reviews.voteCalls, [
      (9, TopicVote.like, true),
      (9, TopicVote.dislike, true),
    ]);
    final comment = reviews.comments.single;
    expect((comment.likes, comment.dislikes, comment.myVote),
        (1, 1, TopicVote.dislike));
  });

  testWidgets('posting a comment appends it to the thread', (tester) async {
    final reviews = _TopicReviews(comments: []);
    await _pump(
      tester,
      TopicDetailScreen(item: _item(), repository: reviews),
    );

    await tester.enterText(find.byType(TextField), 'Not at all, it is fair.');
    await tester.tap(find.byIcon(Icons.send_rounded));
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
}

/// Serves one trending topic and forwards the topic page's calls.
class _TrendingReviews extends _TopicReviews {
  _TrendingReviews(this._item, _TopicReviews inner)
      : super(comments: inner.comments);

  final FeedItem _item;

  @override
  Future<List<FeedItem>> fetchTrendingTopics() async => [_item];
}
