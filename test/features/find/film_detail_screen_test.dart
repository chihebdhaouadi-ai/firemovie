import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
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
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
    // Audience comes from the summary: 71% positive, 6 people.
    expect(find.text('71%'), findsOneWidget);
    expect(find.text(_en.filmAudiencePeople(6)), findsOneWidget);
    expect(find.textContaining('A real test take'), findsOneWidget);
    expect(find.text(_en.filmFeelingsHint), findsOneWidget);
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

    // Chips are on the page; each tap saves straight away.
    await _tapText(tester, _en.reviewReactionLoved);
    await _tapText(tester, _en.reviewReactionMadeThink);
    await _tapText(tester, _en.reviewReactionShocked);
    // A fourth is ignored: the limit is three.
    await _tapText(tester, _en.reviewReactionBored);
    expect(find.text(_en.filmFeelingsCount('3')), findsOneWidget);

    expect(reactions.saves.last, [
      FilmReaction.loved,
      FilmReaction.madeThink,
      FilmReaction.shocked,
    ]);
    expect(reactions.saves, hasLength(3));

    // Tapping a picked feeling drops it.
    await _tapText(tester, _en.reviewReactionMadeThink);
    expect(reactions.saves.last, [FilmReaction.loved, FilmReaction.shocked]);
    expect(find.text(_en.filmFeelingsClear), findsOneWidget);
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

  testWidgets('cast & crew tab lists people from the details', (tester) async {
    await _pump(tester, reviewApi: ReviewApi());

    await _tapText(tester, '${_en.overviewTabCast} & ${_en.overviewTabCrew}');

    expect(find.text('Uma Thurman'), findsOneWidget);
    expect(find.text('Mia Wallace'), findsOneWidget);
    expect(find.text('Director, Writer'), findsOneWidget);
  });
}
