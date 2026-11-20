import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/explore_page.dart';
import 'package:film_wise_mobile/features/home/views/tabs/explore_tab.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

FeedItem _item({
  required int id,
  required String title,
  required TakeTag tag,
  int commentCount = 1,
  Map<TopicVote, int> topicVotes = const {},
}) {
  return FeedItem(
    film: Film(imdbId: 'tt$id', title: title),
    take: Take(
      id: id,
      authorId: id + 100,
      authorName: 'writer$id',
      isMine: false,
      reaction: tag == TakeTag.review ? FilmReaction.loved : null,
      body: '$title topic body',
      votes: const {
        VoteKind.up: 3,
        VoteKind.draw: 2,
        VoteKind.down: 1,
      },
      myVotes: const {},
      commentCount: commentCount,
      isMostHelpful: false,
      tag: tag,
      topicVotes: topicVotes,
    ),
  );
}

class _ExploreRepository implements ReviewRepository {
  _ExploreRepository({
    required this.items,
    required this.comments,
  });

  final List<FeedItem> items;
  final Map<int, List<TakeComment>> comments;

  int? lastTakeId;
  int? lastParentId;
  ReviewStance? lastStance;

  @override
  Future<List<FeedItem>> fetchExploreFeed() async => items;

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async =>
      List.of(comments[takeId] ?? const []);

  @override
  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,
    XFile? image,
  }) async {
    lastTakeId = takeId;
    lastParentId = parentId;
    lastStance = stance;
    final list = comments.putIfAbsent(takeId, () => []);
    final comment = TakeComment(
      id: 1000 + list.length,
      authorId: 1,
      authorName: 'me',
      body: body,
      isWriter: false,
      parentId: parentId,
      stance: stance,
    );
    list.add(comment);
    return comment;
  }

  @override
  Future<TakeComment> setCommentVote(
    int commentId,
    TopicVote kind, {
    required bool active,
  }) async {
    for (final list in comments.values) {
      for (final comment in list) {
        if (comment.id == commentId) {
          return comment.withMyVote(active ? kind : null);
        }
      }
    }
    throw StateError('Missing comment $commentId');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Widget _app(_ExploreRepository repository) {
  return MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SafeArea(child: ExploreTab(reviews: repository)),
    ),
  );
}

void main() {
  testWidgets('Explore page uses the compact centered reference layout',
      (tester) async {
    tester.view.physicalSize = const Size(720, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [_item(id: 99, title: 'Centered film', tag: TakeTag.review)],
      comments: const {},
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SafeArea(child: ExplorePage(reviews: repository)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_en.homeTabExplore), findsOneWidget);
    expect(find.byTooltip(_en.exploreCreateButton), findsOneWidget);
    expect(tester.getSize(find.byType(PageView)).width, lessThanOrEqualTo(448));
    expect(
        tester.getSize(find.byType(PageView)).height, lessThanOrEqualTo(640));
    expect(
      tester.getSize(find.byKey(const ValueKey('explore-card-99'))).width,
      300,
    );
  });

  testWidgets('Explore uses the compact dark centered card layout on phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [_item(id: 9, title: 'A featured film', tag: TakeTag.review)],
      comments: const {},
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SafeArea(child: ExplorePage(reviews: repository)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_en.homeTabExplore), findsOneWidget);
    expect(find.byTooltip(_en.exploreCreateButton), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF131417),
      ),
      findsOneWidget,
    );

    final card = find.byKey(const ValueKey('explore-card-9'));
    expect(tester.getSize(card).width, closeTo(360 * .72, 1));
    final cardMaterial = tester.widget<Material>(
      find.descendant(of: card, matching: find.byType(Material)).first,
    );
    expect(cardMaterial.color, const Color(0xFF1B1D23));
    final shape = cardMaterial.shape! as RoundedRectangleBorder;
    expect(shape.side.color, const Color(0xFF2A2D36));
  });

  testWidgets('a side card tap centers it without opening its thread',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [
        _item(id: 1, title: 'First film', tag: TakeTag.review),
        _item(id: 2, title: 'Second film', tag: TakeTag.discussion),
      ],
      comments: {
        1: [
          const TakeComment(
            id: 11,
            authorId: 9,
            authorName: 'ana',
            body: 'First reply',
            isWriter: false,
          ),
        ],
        2: [
          const TakeComment(
            id: 22,
            authorId: 8,
            authorName: 'sam',
            body: 'Second reply',
            isWriter: false,
          ),
        ],
      },
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    final secondCard = find.byKey(const ValueKey('explore-card-2'));
    final sideCenter = tester.getCenter(secondCard);
    expect(sideCenter.dx, greaterThan(360));
    await tester.tapAt(Offset(358, sideCenter.dy));
    await tester.pumpAndSettle();

    expect(tester.getCenter(secondCard).dx, closeTo(180, 20));
    expect(find.text('Second reply'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
      'active card opens its thread and posts top-level and nested replies',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [
        _item(
            id: 3, title: 'A question', tag: TakeTag.question, commentCount: 1),
      ],
      comments: {
        3: [
          const TakeComment(
            id: 31,
            authorId: 8,
            authorName: 'ana',
            body: 'A useful answer',
            isWriter: false,
          ),
        ],
      },
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.exploreRepliesButton(1)));
    await tester.pumpAndSettle();
    expect(find.text('A useful answer'), findsWidgets);
    final threadSheet = tester.widget<Material>(
      find.byKey(const ValueKey('explore-thread-sheet')),
    );
    expect(threadSheet.color, const Color(0xFF1B1D23));
    expect(
      tester.getSize(find.byKey(const ValueKey('explore-thread-sheet'))).width,
      360,
    );

    await tester.enterText(find.byType(TextField), 'Top-level reply');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();
    expect(repository.lastTakeId, 3);
    expect(repository.lastParentId, isNull);
    expect(find.text('Top-level reply'), findsWidgets);

    await tester.tap(find.text(_en.reviewReply).first);
    await tester.pumpAndSettle();
    expect(find.text(_en.reviewReplyingTo('ana')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nested reply');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();
    expect(repository.lastTakeId, 3);
    expect(repository.lastParentId, 31);
    expect(repository.lastStance, isNull);
    expect(find.text('Nested reply'), findsOneWidget);

    Navigator.of(tester.element(find.byType(BottomSheet))).pop();
    await tester.pumpAndSettle();
    expect(find.text(_en.exploreRepliesButton(3)), findsOneWidget);
  });

  testWidgets('hot take uses topic votes and best replies on both sides',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [
        _item(
          id: 4,
          title: 'The Hot Film',
          tag: TakeTag.hotTake,
          topicVotes: const {
            TopicVote.like: 12,
            TopicVote.dislike: 4,
          },
        ),
      ],
      comments: {
        4: [
          const TakeComment(
            id: 41,
            authorId: 7,
            authorName: 'pro',
            body: 'Most liked reply',
            isWriter: false,
            likes: 8,
            dislikes: 1,
          ),
          const TakeComment(
            id: 42,
            authorId: 8,
            authorName: 'con',
            body: 'Most disliked reply',
            isWriter: false,
            likes: 1,
            dislikes: 9,
          ),
          const TakeComment(
            id: 43,
            authorId: 9,
            authorName: 'third',
            body: 'A lower voted reply',
            isWriter: false,
            likes: 4,
            dislikes: 3,
          ),
        ],
      },
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text(_en.exploreAgreePercent(75)), findsOneWidget);
    expect(find.text(_en.exploreDisagreePercent(25)), findsOneWidget);
    expect(find.text('Most liked reply', findRichText: true), findsWidgets);
    expect(find.text('Most disliked reply', findRichText: true), findsWidgets);
    expect(find.text('A lower voted reply', findRichText: true), findsNothing);
  });

  testWidgets('review replies show old stances but offer no stance picker',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _ExploreRepository(
      items: [
        _item(id: 5, title: 'A review', tag: TakeTag.review),
      ],
      comments: {
        5: [
          const TakeComment(
            id: 51,
            authorId: 7,
            authorName: 'writer',
            body: 'Root review reply',
            isWriter: false,
            stance: ReviewStance.changedMyMind,
          ),
        ],
      },
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.exploreRepliesButton(1)));
    await tester.pumpAndSettle();
    // Old comments keep their stance label; new ones can't pick one.
    expect(find.text(_en.reviewVoteChangedMyMind), findsOneWidget);
    expect(
      find.byKey(const ValueKey('review-stance-disagree_but_fair')),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField), 'Fair disagreement');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();

    expect(repository.lastTakeId, 5);
    expect(repository.lastParentId, isNull);
    expect(repository.lastStance, isNull);
  });
}
