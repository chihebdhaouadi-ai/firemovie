import 'dart:async';

import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/articles/data/article.dart';
import 'package:film_wise_mobile/features/articles/data/article_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/review_stance.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/topic_vote.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/vote_kind.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/review_detail_screen.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/home/bloc/home_bloc.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_event.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/home/views/home_screen.dart';
import 'package:film_wise_mobile/features/home/views/widgets/add_tile.dart';
import 'package:film_wise_mobile/features/home/views/widgets/collections_box.dart';
import 'package:film_wise_mobile/features/home/views/widgets/film_tile.dart';
import 'package:film_wise_mobile/features/home/views/widgets/skeletons.dart';
import 'package:film_wise_mobile/features/home/views/widgets/top5_row.dart';
import 'package:film_wise_mobile/features/find/views/film_detail_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _dune = Film(imdbId: 'tt0000001', title: 'Dune');
const _arrival = Film(imdbId: 'tt0000002', title: 'Arrival');
const _interstellar = Film(imdbId: 'tt0000003', title: 'Interstellar');
const _blade = Film(imdbId: 'tt0000004', title: 'Blade Runner');
const _matrix = Film(imdbId: 'tt0000005', title: 'The Matrix');
const _inception = Film(imdbId: 'tt0000006', title: 'Inception');
const _popular = Film(imdbId: 'tt0000007', title: 'Popular Pick');

const _tallViewport = Size(360, 3000);
const _phoneViewport = Size(360, 800);

final _en = lookupAppLocalizations(const Locale('en'));

Map<HomeList, List<Film>> _contentSeed() => {
      HomeList.top5: [_dune, _arrival],
      HomeList.watched: [_interstellar, _blade, _matrix],
      HomeList.watchlist: [_inception],
      HomeList.popular: [_popular],
    };

class _HeldRepository extends FakeHomeRepository {
  final _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<List<Film>> fetch(HomeList list) async {
    await _gate.future;
    return super.fetch(list);
  }
}

class _FlakyRepository extends FakeHomeRepository {
  _FlakyRepository({
    super.seed,
    required this.failingLists,
    this.failures = 1,
  });

  final Set<HomeList> failingLists;
  int failures;

  @override
  Future<List<Film>> fetch(HomeList list) async {
    if (failingLists.contains(list) && failures > 0) {
      failures--;
      throw const HomeDataException('offline');
    }
    return super.fetch(list);
  }
}

class _FindStub extends StatelessWidget {
  const _FindStub({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await onConfirm();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('CONFIRM_FIND'),
        ),
      ),
    );
  }
}

const _mayaItem = FeedItem(
  film: _blade,
  take: Take(
    id: 42,
    authorId: 7,
    authorName: 'maya',
    isMine: false,
    reaction: FilmReaction.blewMind,
    body: 'Still the best sci-fi score.',
    votes: {},
    myVotes: {},
    commentCount: 1,
    isMostHelpful: false,
  ),
);

class _InteractiveReviews implements ReviewRepository {
  _InteractiveReviews({List<TakeComment>? comments})
      : _comments = comments ??
            [
              const TakeComment(
                id: 1,
                authorId: 9,
                authorName: 'ana',
                body: 'Nice pick',
                isWriter: false,
              ),
            ];

  final _votes = <VoteKind, int>{};
  final _mine = <VoteKind>{};
  final List<TakeComment> _comments;

  Take _snapshot() => Take(
        id: 42,
        authorId: 7,
        authorName: 'maya',
        isMine: false,
        reaction: FilmReaction.blewMind,
        body: 'Still the best sci-fi score.',
        votes: Map.of(_votes),
        myVotes: Set.of(_mine),
        commentCount: _comments.length,
        isMostHelpful: false,
      );

  @override
  Future<Take> setVote(
    int takeId,
    VoteKind kind, {
    required bool active,
  }) async {
    if (active) {
      _mine.add(kind);
      _votes[kind] = (_votes[kind] ?? 0) + 1;
    } else {
      _mine.remove(kind);
      _votes[kind] = (_votes[kind] ?? 1) - 1;
    }
    return _snapshot();
  }

  @override
  Future<Take> setTopicVote(int takeId, TopicVote kind,
          {required bool active}) =>
      throw UnimplementedError();

  @override
  Future<List<TakeComment>> fetchComments(int takeId) async =>
      List.of(_comments);

  int? lastParentId;

  @override
  Future<TakeComment> postComment(
    int takeId, {
    required String body,
    int? parentId,
    ReviewStance? stance,
  }) async {
    lastParentId = parentId;
    final comment = TakeComment(
      id: _comments.length + 1,
      authorId: 1,
      authorName: 'me',
      body: body,
      isWriter: false,
      parentId: parentId,
      stance: stance,
    );
    _comments.add(comment);
    return comment;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Keeps the news ticker empty so its endless animation doesn't run in tests
/// that don't care about it.
class _NoArticles implements ArticleRepository {
  const _NoArticles();

  @override
  Future<List<LatestArticle>> fetchLatest() async => const [];
}

class _TwoArticles implements ArticleRepository {
  const _TwoArticles();

  @override
  Future<List<LatestArticle>> fetchLatest() async => [
        LatestArticle(
          id: 1,
          title: 'Dune Part Three gets a release date',
          coverUrl: 'https://example.test/dune.jpg',
          url: 'https://example.test/articles/dune',
          publishedAt: DateTime.utc(2026, 11, 1),
        ),
        LatestArticle(
          id: 2,
          title: 'Festival season opens with a surprise premiere',
          coverUrl: 'https://example.test/fest.jpg',
          url: 'https://example.test/articles/fest',
          publishedAt: DateTime.utc(2026, 11, 2),
        ),
      ];
}

Future<HomeBloc> pumpHome(
  WidgetTester tester, {
  required HomeRepository repository,
  double textScale = 1,
  Size viewport = _tallViewport,
  ReviewRepository? reviews,
  ArticleRepository? articles,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final bloc = HomeBloc(
    repository: repository,
    gateway: FakePointsGateway(),
  )..add(const HomeStarted());
  addTearDown(bloc.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/find': (context) => _FindStub(
              onConfirm: () => repository.add(HomeList.top5, _arrival),
            ),
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: BlocProvider.value(
        value: bloc,
        child: HomeScreen(
          reviews: reviews,
          articles: articles ?? const _NoArticles(),
        ),
      ),
    ),
  );
  return bloc;
}

Finder _inTop5(Finder matching) =>
    find.descendant(of: find.byType(Top5Row), matching: matching);

Finder _filmLabel(Film film, String section) => find
    .bySemanticsLabel(_en.homeFilmTileSemantics(film.displayTitle, section));

void main() {
  testWidgets('news ticker stays under the tabs when switching tabs',
      (tester) async {
    await pumpHome(
      tester,
      repository: FakeHomeRepository(),
      articles: const _TwoArticles(),
    );
    // The ticker animates forever, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('FILMSAGE'), findsOneWidget);
    expect(find.text('Dune Part Three gets a release date'), findsWidgets);

    await tester.tap(find.text(_en.homeTabFriends));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('FILMSAGE'), findsOneWidget);

    await tester.tap(find.text(_en.homeTabFilms));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('FILMSAGE'), findsOneWidget);
  });

  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    await poppins.load();
  });

  group('states', () {
    testWidgets('loading shows poster-shaped skeletons', (tester) async {
      final repository = _HeldRepository();
      await pumpHome(tester, repository: repository);
      await tester.pump();

      expect(find.byType(PosterSkeletonRow), findsNWidgets(3));
      expect(find.byType(PosterSkeleton), findsWidgets);

      repository.release();
      await tester.pumpAndSettle();
      expect(find.byType(PosterSkeleton), findsNothing);
    });

    testWidgets('empty lists show the empty state with an action',
        (tester) async {
      await pumpHome(tester, repository: FakeHomeRepository());
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionEmptyTitle), findsNWidgets(3));
      expect(find.text(_en.homeSectionEmptyAction), findsNWidgets(2));
      expect(_inTop5(find.byType(AddTile)), findsNWidgets(5));
    });

    testWidgets('failed lists show an error with retry', (tester) async {
      await pumpHome(
        tester,
        repository: _FlakyRepository(
          failingLists: HomeList.values.toSet(),
          failures: 99,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionErrorTitle), findsNWidgets(4));
      expect(find.text(_en.homeSectionErrorRetry), findsNWidgets(4));
    });

    testWidgets('retry reloads only the failed list', (tester) async {
      await pumpHome(
        tester,
        repository: _FlakyRepository(
          seed: {
            HomeList.top5: [_dune],
          },
          failingLists: {HomeList.top5},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeSectionErrorTitle), findsOneWidget);

      await tester.tap(_inTop5(find.text(_en.homeSectionErrorRetry)));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
      expect(find.text(_en.homeSectionErrorTitle), findsNothing);
      expect(find.text(_en.homeSectionEmptyTitle), findsNWidgets(3));
    });

    testWidgets('content shows films and their counts', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
      expect(_filmLabel(_blade, _en.homeWatchedTitle), findsOneWidget);
      expect(_filmLabel(_inception, _en.homeWatchlistTitle), findsOneWidget);
      expect(_filmLabel(_popular, _en.homePopularTitle), findsOneWidget);
      expect(find.text(_en.homeFilmCount(3)), findsOneWidget);
      expect(find.text(_en.homeFilmCount(1)), findsNWidgets(2));
    });
  });

  group('top 5', () {
    // Opening Find or an overview is gated: these tests act as a signed-in person.
    setUp(() => Session.token = 'test-token');
    tearDown(Session.clear);

    testWidgets(
        'tap on a Top 5 slot opens the Find screen for that destination',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: {
            HomeList.top5: [_dune],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(_inTop5(find.byType(AddTile)).first);
      await tester.pumpAndSettle();

      // The Find screen is pushed with the Top 5 destination shown in its title.
      expect(find.byType(FindFilmScreen), findsOneWidget);
      expect(find.text(_en.findTitleTop5), findsWidgets);
    });

    testWidgets('removes a film optimistically and restores it with Undo',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: {
            HomeList.top5: [_dune, _arrival],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(_en.homeRemoveFilm('Dune')));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsNothing);
      expect(find.text(_en.homeRemovedSnackbar('Dune')), findsOneWidget);

      await tester.tap(find.text(_en.homeUndo));
      await tester.pumpAndSettle();

      expect(_filmLabel(_dune, _en.homeTop5Title), findsOneWidget);
    });
  });

  group('collections', () {
    testWidgets('Watched, Watchlist and Popular sit in one box under Top 5',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      final box = find.byType(CollectionsBox);
      expect(
        find.descendant(of: box, matching: find.text(_en.homeCollectionsTitle)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: box, matching: find.byType(FilmTile)),
        findsNWidgets(5),
      );
      expect(
        find.descendant(of: box, matching: _inTop5(find.byType(FilmTile))),
        findsNothing,
      );
    });

    testWidgets('the resize grip changes the box height within its bounds',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      final box = find.byType(CollectionsBox);
      final scroll = find
          .descendant(of: box, matching: find.byType(SingleChildScrollView))
          .first;
      final grip = find.bySemanticsLabel(_en.homeCollectionsResizeLabel);
      expect(tester.getSize(scroll).height, 360);

      await tester.drag(grip, const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(tester.getSize(scroll).height, greaterThan(360));

      await tester.drag(grip, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.getSize(scroll).height, 200);
    });
  });

  group('feed', () {
    testWidgets('shows the empty message when no collection film has reviews',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeFeedTitle), findsOneWidget);
      expect(find.text(_en.homeFeedEmpty), findsOneWidget);
    });

    testWidgets('shows a review card for a film in the collections',
        (tester) async {
      final item = FeedItem(
        film: _blade,
        take: Take(
          id: 42,
          authorId: 7,
          authorName: 'maya',
          isMine: false,
          reaction: FilmReaction.blewMind,
          body: 'Still the best sci-fi score.',
          votes: const {},
          myVotes: const {},
          commentCount: 0,
          isMostHelpful: false,
        ),
      );
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: _contentSeed(),
          feed: [item],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_en.homeFeedEmpty), findsNothing);
      expect(find.textContaining('maya'), findsOneWidget);
      expect(find.text('Still the best sci-fi score.'), findsOneWidget);
    });

    testWidgets('votes on a review card without opening its details',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: _contentSeed(),
          feed: [_mayaItem],
        ),
        reviews: _InteractiveReviews(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('${_en.reviewVoteWellArgued} 0'));
      await tester.pumpAndSettle();

      expect(find.text('${_en.reviewVoteWellArgued} 1'), findsOneWidget);
      expect(find.byType(ReviewDetailScreen), findsNothing);
    });

    testWidgets('comments on a review card and updates its count',
        (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: _contentSeed(),
          feed: [_mayaItem],
        ),
        reviews: _InteractiveReviews(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.reviewCommentsButton(1)));
      await tester.pumpAndSettle();
      expect(find.text('Nice pick'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Agreed');
      await tester.tap(find.text(_en.reviewSend));
      await tester.pumpAndSettle();

      expect(find.text('Agreed'), findsOneWidget);
      expect(find.text(_en.reviewCommentsButton(2)), findsOneWidget);
      expect(find.byType(ReviewDetailScreen), findsNothing);
    });

    testWidgets('replying posts under the parent and shows it nested',
        (tester) async {
      final reviews = _InteractiveReviews();
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: _contentSeed(),
          feed: [_mayaItem],
        ),
        reviews: reviews,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.reviewCommentsButton(1)));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.reviewReply));
      await tester.pumpAndSettle();
      expect(find.text(_en.reviewReplyingTo('ana')), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Thanks ana');
      await tester.tap(find.text(_en.reviewSend));
      await tester.pumpAndSettle();

      expect(reviews.lastParentId, 1);
      expect(find.text(_en.reviewReplyingTo('ana')), findsNothing);
      expect(find.text('Thanks ana'), findsOneWidget);
    });

    testWidgets('collapses and expands a comment’s replies', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: _contentSeed(),
          feed: [_mayaItem],
        ),
        reviews: _InteractiveReviews(
          comments: const [
            TakeComment(
              id: 1,
              authorId: 9,
              authorName: 'ana',
              body: 'Nice pick',
              isWriter: false,
            ),
            TakeComment(
              id: 2,
              authorId: 8,
              authorName: 'ben',
              body: 'Agreed with ana',
              isWriter: false,
              parentId: 1,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.reviewCommentsButton(1)));
      await tester.pumpAndSettle();
      expect(find.text('Agreed with ana'), findsOneWidget);

      await tester.tap(find.text(_en.reviewHideReplies));
      await tester.pumpAndSettle();
      expect(find.text('Agreed with ana'), findsNothing);
      expect(find.text(_en.reviewShowReplies(1)), findsOneWidget);

      await tester.tap(find.text(_en.reviewShowReplies(1)));
      await tester.pumpAndSettle();
      expect(find.text('Agreed with ana'), findsOneWidget);
    });
  });

  group('overview', () {
    // Opening Find or an overview is gated: these tests act as a signed-in person.
    setUp(() => Session.token = 'test-token');
    tearDown(Session.clear);

    testWidgets('tapping a Top 5 film opens its overview', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(
          seed: {
            HomeList.top5: [_dune],
          },
        ),
      );
      await tester.pumpAndSettle();

      // The remove button's 48dp target covers the top of a narrow Top 5 tile,
      // so tap the lower part of the poster.
      final tile = tester.getRect(_filmLabel(_dune, _en.homeTop5Title));
      await tester.tapAt(tile.bottomCenter.translate(0, -10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FilmDetailScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 13));
    });

    testWidgets('tapping a Watched film opens its overview', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
      );
      await tester.pumpAndSettle();

      await tester.tap(_filmLabel(_blade, _en.homeWatchedTitle));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FilmDetailScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 13));
    });
  });

  group('layout', () {
    testWidgets('text scale 2.0 renders without overflow', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
        textScale: 2,
        viewport: _phoneViewport,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('home matches golden at 360x800', (tester) async {
      await pumpHome(
        tester,
        repository: FakeHomeRepository(seed: _contentSeed()),
        viewport: _phoneViewport,
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_360x800.png'),
      );
    });
  });
}
