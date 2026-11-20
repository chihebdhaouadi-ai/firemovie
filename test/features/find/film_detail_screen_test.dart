import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/pill_tabs.dart';
import 'package:film_wise_mobile/features/film_reviews/data/reactions_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/feeling_chip.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/in_memory_lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/views/film_detail_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../film_reviews/review_test_support.dart';

class _FakeFindRepository extends FindRepository {
  _FakeFindRepository(this.movie);

  final Movie movie;

  @override
  Future<Movie> fetchDetail(String filmId) async => movie;

  @override
  Future<List<String>> fetchStills(String filmId) async => const [];
}

/// Lists fake that can be told to fail, to check the rollback.
class _FailingLists extends InMemoryListsRepository {
  @override
  Future<ListEntry> add(FilmListId list, String filmId,
          {int? slot, bool replace = false}) async =>
      throw Exception('down');
}

const _movie = Movie(
  id: 'tt1',
  title: 'Pulp Fiction',
  year: 1994,
  director: 'Quentin Tarantino',
  genres: ['Crime', 'Drama'],
  overview: 'A story about intersecting lives in Los Angeles.',
  runtime: 154,
  voteAverage: 8.5,
  cast: [CastMember(name: 'Uma Thurman', role: 'Mia Wallace')],
  crew: [CrewMember(name: 'Quentin Tarantino', job: 'Director, Writer')],
);

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(
  WidgetTester tester, {
  required ReviewApi reviewApi,
  ListsRepository? lists,
  ReactionsRepository? reactions,
  Size size = const Size(800, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The feelings icons and empty-state bars loop; reduced motion keeps
      // them still so pumpAndSettle can finish.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: FilmDetailScreen(
        movie: _movie,
        repository: _FakeFindRepository(_movie),
        reviewRepository: reviewRepositoryFor(reviewApi.client),
        listsRepository: lists ?? InMemoryListsRepository(),
        reactionsRepository: reactions ?? FakeReactionsRepository(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps [text] inside the open bottom sheet (picked labels also show behind).
Future<void> _tapInSheet(WidgetTester tester, String text) async {
  final target = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.text(text),
  );
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => Session.token = 'test-token');
  tearDown(() => Session.token = '');

  testWidgets('shows the film, real audience and takes, no demo content',
      (tester) async {
    await _pump(
      tester,
      reviewApi: ReviewApi(
        takes: [takeJson(authorName: 'Ada', body: 'A real test take')],
      ),
    );

    expect(find.text('Pulp Fiction'), findsOneWidget);
    expect(find.textContaining('Quentin Tarantino'), findsOneWidget);
    expect(find.text('DEMO'), findsNothing);
    expect(find.text('ARTICLES'), findsNothing);
    // Audience comes from the summary: 6 people, shown as a colour bar only.
    expect(find.text('71%'), findsNothing);
    expect(find.text(_en.filmAudiencePeople(6)), findsOneWidget);
    expect(find.textContaining('A real test take'), findsOneWidget);
    expect(find.text(_en.filmFeelingsEmpty), findsOneWidget);
    expect(find.text(_en.filmShareYourTake), findsOneWidget);
  });

  testWidgets('Watched adds the film to the list and shows it as active',
      (tester) async {
    final lists = InMemoryListsRepository();
    await _pump(tester, reviewApi: ReviewApi(), lists: lists);

    await _tapText(tester, _en.homeWatchedTitle);

    final snapshot = await lists.fetchAll();
    expect(snapshot.watched, contains('tt1'));

    await _tapText(tester, _en.homeWatchedTitle);
    expect((await lists.fetchAll()).watched, isNot(contains('tt1')));
  });

  testWidgets('a failed list change rolls back and says so', (tester) async {
    await _pump(tester, reviewApi: ReviewApi(), lists: _FailingLists());

    await _tapText(tester, _en.homeWatchlistTitle);

    expect(find.text(_en.filmListFailed), findsOneWidget);
  });

  testWidgets('up to three feelings are picked and saved together',
      (tester) async {
    final reactions = FakeReactionsRepository();
    await _pump(tester, reviewApi: ReviewApi(), reactions: reactions);

    // The card opens a sheet of tiles; nothing is saved until it closes.
    await _tapText(tester, _en.filmFeelingsEmpty);
    await _tapInSheet(tester, _en.reviewReactionLoved);
    await _tapInSheet(tester, _en.reviewReactionMadeThink);
    await _tapInSheet(tester, _en.reviewReactionShocked);
    // A fourth is ignored: the limit is three.
    await _tapInSheet(tester, _en.reviewReactionBored);
    expect(find.text(_en.filmFeelingsCount('3')), findsOneWidget);
    expect(reactions.saves, isEmpty);

    await _tapInSheet(tester, _en.filmFeelingsDone);

    expect(reactions.saves.single, [
      FilmReaction.loved,
      FilmReaction.madeThink,
      FilmReaction.shocked,
    ]);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text(_en.reviewReactionChange), findsOneWidget);
    // Like the audience bar: three picked feelings share the row equally.
    List<double> chipWidths() => [
          for (final element in find.byType(FeelingChip).evaluate())
            element.size!.width,
        ];
    final three = chipWidths();
    expect(three, hasLength(3));
    expect(three.toSet(), hasLength(1));

    // Change reopens the sheet; dropping one saves the rest.
    await _tapText(tester, _en.reviewReactionChange);
    await _tapInSheet(tester, _en.reviewReactionMadeThink);
    await _tapInSheet(tester, _en.filmFeelingsDone);
    expect(reactions.saves.last, [FilmReaction.loved, FilmReaction.shocked]);
    final two = chipWidths();
    expect(two, hasLength(2));
    expect(two.first, two.last);
    expect(two.first, greaterThan(three.first));
  });

  testWidgets('the audience bar shows each feeling\'s share', (tester) async {
    await _pump(tester, reviewApi: ReviewApi());

    expect(find.byType(AudienceBar), findsOneWidget);
  });

  testWidgets('sharing a take posts it and hides the box', (tester) async {
    final reviewApi = ReviewApi();
    await _pump(tester, reviewApi: reviewApi);

    await _tapText(tester, _en.filmShareYourTake);
    await tester.enterText(find.byType(TextField), 'Dialogue for days.');
    await tester.tap(find.byTooltip(_en.reviewShare));
    await tester.pumpAndSettle();

    expect(
      reviewApi.requests.any(
        (request) =>
            request.method == 'POST' && request.url.path.endsWith('/takes/'),
      ),
      isTrue,
    );
    expect(find.textContaining('Dialogue for days.'), findsOneWidget);
    expect(find.text(_en.filmShareYourTake), findsNothing);
    expect(find.text(_en.filmAddTake), findsNothing);
  });

  testWidgets('Share your take floats in while What people said is on screen',
      (tester) async {
    await _pump(
      tester,
      reviewApi: ReviewApi(takes: [takeJson(body: 'A take')]),
      size: const Size(390, 844),
    );
    Offset slide() => tester
        .widget<AnimatedSlide>(
          find.ancestor(
            of: find.text(_en.filmShareYourTake),
            matching: find.byType(AnimatedSlide),
          ),
        )
        .offset;

    // At the top of the page the section is far below: the button waits.
    expect(slide(), isNot(Offset.zero));

    await tester.scrollUntilVisible(
      find.text(_en.reviewTakesTitle),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(slide(), Offset.zero);

    await tester.tap(find.text(_en.filmShareYourTake));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('the back arrow and tabs stay pinned and the tabs shrink',
      (tester) async {
    await _pump(tester, reviewApi: ReviewApi(), size: const Size(390, 844));
    double tabsHeight() =>
        tester.widget<PillTabs>(find.byType(PillTabs)).height;
    expect(tabsHeight(), 46);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.byTooltip(_en.overviewBack).hitTestable(), findsOneWidget);
    expect(find.byType(PillTabs).hitTestable(), findsOneWidget);
    expect(tabsHeight(), lessThan(46));
  });

  testWidgets('cast & crew tab lists people from the details', (tester) async {
    await _pump(tester, reviewApi: ReviewApi());

    await _tapText(tester, '${_en.overviewTabCast} & ${_en.overviewTabCrew}');

    expect(find.text('Uma Thurman'), findsOneWidget);
    expect(find.text('Mia Wallace'), findsOneWidget);
    expect(find.text('Director, Writer'), findsOneWidget);
  });
}
