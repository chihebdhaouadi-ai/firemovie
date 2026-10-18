import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/bloc/find_film_bloc.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/in_memory_lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/data/recent_searches_store.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/find/views/find_route_args.dart';
import 'package:film_wise_mobile/features/find/views/widgets/add_button.dart';
import 'package:film_wise_mobile/features/find/views/widgets/empty_error_views.dart';
import 'package:film_wise_mobile/features/find/views/widgets/result_tile.dart';
import 'package:film_wise_mobile/features/find/views/widgets/skeletons.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pulp = Movie(
  id: '278',
  title: 'Pulp Fiction',
  year: 1994,
  director: 'Quentin Tarantino',
);
const _matrix = Movie(
    id: '11', title: 'The Matrix', year: 1999, director: 'Lana Wachowski');

class _FakeFindRepository extends FindRepository {
  _FakeFindRepository({this.results = const [], this.fail = false});

  final List<Movie> results;
  bool fail;

  @override
  Future<MovieSearchPage> search(String query, {int page = 1}) async {
    if (fail) throw const NetworkFailure('down');
    return MovieSearchPage(
      page: 1,
      totalPages: 1,
      totalResults: results.length,
      results: results,
    );
  }
}

class _FakeRecentStore extends RecentSearchesStore {
  _FakeRecentStore([List<String> seed = const []]) : _terms = [...seed];
  final List<String> _terms;

  @override
  Future<List<String>> load() async => List.of(_terms);
  @override
  Future<List<String>> add(String term) async {
    final t = term.trim();
    _terms.remove(t);
    _terms.insert(0, t);
    return List.of(_terms);
  }
}

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> pumpFind(
  WidgetTester tester, {
  FindRepository? repository,
  ListsRepository? lists,
  RecentSearchesStore? recent,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FindFilmScreen(
        repository: repository,
        listsRepository: lists,
        recentStore: recent,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('initially shows the recent-searches state (empty)',
      (tester) async {
    await pumpFind(tester, recent: _FakeRecentStore());
    await tester.pump();
    expect(find.text(_en.findRecentEmpty), findsOneWidget);
  });

  testWidgets('typing fewer than 2 chars shows the minimum-characters prompt',
      (tester) async {
    await pumpFind(tester, recent: _FakeRecentStore());
    await tester.enterText(find.byType(TextField), 'p');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(MinCharsPrompt), findsOneWidget);
  });

  testWidgets('shows recent searches when present', (tester) async {
    await pumpFind(tester, recent: _FakeRecentStore(['inception', 'matrix']));
    await tester.pump();
    expect(find.text(_en.findRecentTitle), findsOneWidget);
    expect(find.text('inception'), findsOneWidget);
    expect(find.text('matrix'), findsOneWidget);
  });

  testWidgets('shows result rows after a search', (tester) async {
    await pumpFind(
      tester,
      repository: _FakeFindRepository(results: [_pulp, _matrix]),
      lists: InMemoryListsRepository(),
      recent: _FakeRecentStore(),
    );
    await tester.enterText(
      find.byType(TextField),
      'pulp',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(ResultTile), findsWidgets);
    expect(find.text('Pulp Fiction'), findsOneWidget);
    expect(find.text('The Matrix'), findsOneWidget);
  });

  testWidgets('loaded results render skeleton rows', (tester) async {
    await pumpFind(tester, recent: _FakeRecentStore());
    await tester.pump();
    expect(find.byType(ResultListSkeleton), findsNothing);
  });

  testWidgets('a film already in the target shows the Added (check) button',
      (tester) async {
    final lists = InMemoryListsRepository(
      seed: const {
        FilmListId.watchlist: ['278'],
      },
    );
    await pumpFind(
      tester,
      repository: _FakeFindRepository(
        results: [
          Movie(
            id: '278',
            title: 'Pulp Fiction',
            year: 1994,
            inLists: ['watchlist'],
          ),
        ],
      ),
      lists: lists,
      recent: _FakeRecentStore(),
    );
    await tester.enterText(find.byType(TextField), 'pulp');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // The check icon (already added) is shown instead of a "+".
    expect(find.byIcon(Icons.check_rounded), findsWidgets);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('a failed search shows the error view with retry',
      (tester) async {
    await pumpFind(
      tester,
      repository: _FakeFindRepository(fail: true),
      lists: InMemoryListsRepository(),
      recent: _FakeRecentStore(),
    );
    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text(_en.findErrorTitle), findsOneWidget);
    expect(find.text(_en.findErrorRetry), findsOneWidget);
  });
}
