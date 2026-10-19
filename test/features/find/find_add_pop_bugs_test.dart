import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/in_memory_lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/lists_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/find/data/recent_searches_store.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/find/views/find_route_args.dart';
import 'package:film_wise_mobile/features/find/views/widgets/result_tile.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pulp = Movie(id: 'tt0110912', title: 'Pulp Fiction', year: 1994);

class _FakeFindRepository extends FindRepository {
  _FakeFindRepository({this.results = const []});
  final List<Movie> results;
  @override
  Future<MovieSearchPage> search(String query, {int page = 1}) async =>
      MovieSearchPage(
        page: 1,
        totalPages: 1,
        totalResults: results.length,
        results: results,
      );
}

class _FakeRecentStore extends RecentSearchesStore {
  @override
  Future<List<String>> load() async => const [];
  @override
  Future<List<String>> add(String term) async => const [];
}

final _en = lookupAppLocalizations(const Locale('en'));

class _Host extends StatelessWidget {
  const _Host({required this.lists, required this.find});
  final ListsRepository lists;
  final FindRepository find;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFFF00FF),
          body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FindFilmScreen(
                      repository: find,
                      listsRepository: lists,
                      recentStore: _FakeRecentStore(),
                    ),
                    settings: const RouteSettings(
                      arguments: FindFilmRouteArgs(
                          target: AddTarget.top5, slot: 1),
                    ),
                  ),
                );
              },
              child: const Text('GO_FIND'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
      'fixed-target add auto-pops back to the HOME screen and keeps it visible',
      (tester) async {
    final lists = InMemoryListsRepository();
    await tester.pumpWidget(
      _Host(lists: lists, find: _FakeFindRepository(results: [_pulp])),
    );
    await tester.pumpAndSettle();
    expect(find.text('GO_FIND'), findsOneWidget);

    // Open find for fixed top5 slot 1.
    await tester.tap(find.text('GO_FIND'));
    await tester.pumpAndSettle();
    expect(find.byType(FindFilmScreen), findsOneWidget);

    // Search returns a result.
    await tester.enterText(find.byType(TextField), 'pulp');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(ResultTile), findsOneWidget);

    // Tap the Add (+) button on the result -> adds to top5 and schedules a pop.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Let the auto-pop (450ms) finish unwinding back to HOME.
    await tester.pump(); // snackbar visible triggers the delayed pop
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Diagnostic: what's on screen now?
    debugPrint('FindFilmScreen present: ${find.byType(FindFilmScreen).evaluate().length}');
    debugPrint('GO_FIND present: ${find.text('GO_FIND').evaluate().length}');
    debugPrint('Text widgets: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toSet()}');

    // The HOME screen (magenta sentinel) must be visible, not a black screen.
    expect(find.text('GO_FIND'), findsOneWidget);
    expect(find.byType(FindFilmScreen), findsNothing);
  });
}
