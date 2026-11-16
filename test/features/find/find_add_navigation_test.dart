import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/in_memory_lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/data/recent_searches_store.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/find/views/find_route_args.dart';
import 'package:film_wise_mobile/features/find/views/widgets/add_button.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pulp = Movie(id: '278', title: 'Pulp Fiction', year: 1994);

class _FakeFindRepository extends FindRepository {
  @override
  Future<MovieSearchPage> search(String query, {int page = 1}) async {
    return const MovieSearchPage(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [_pulp],
    );
  }
}

class _FakeRecentStore extends RecentSearchesStore {
  @override
  Future<List<String>> load() async => [];
  @override
  Future<List<String>> add(String term) async => [term];
}

void main() {
  testWidgets('adding from a fixed-target Find pops only Find', (tester) async {
    final lists = InMemoryListsRepository();
    final route = MaterialPageRoute<FindFilmResult>(
      settings: const RouteSettings(
        arguments: FindFilmRouteArgs(target: AddTarget.watchlist),
      ),
      builder: (_) => FindFilmScreen(
        repository: _FakeFindRepository(),
        listsRepository: lists,
        recentStore: _FakeRecentStore(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(route),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pulp');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AddButton).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(lists.hasWatchlist(_pulp.id), isTrue);
    expect(find.byType(FindFilmScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
