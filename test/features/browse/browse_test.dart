import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/browse/data/fake_browse_repository.dart';
import 'package:film_wise_mobile/features/browse/domain/browse_option.dart';
import 'package:film_wise_mobile/features/browse/domain/streaming_service.dart';
import 'package:film_wise_mobile/features/browse/views/browse_menu.dart';
import 'package:film_wise_mobile/features/browse/views/browse_years_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => Session.token = 'test-token');
  tearDown(() => Session.token = '');

  testWidgets('menu shows every browse option', (tester) async {
    await _pump(tester, BrowseMenu(repository: FakeBrowseRepository()));
    for (final label in [
      _en.browseTopTakes,
      _en.browsePopularFilms,
      _en.browseByYear,
      _en.browseByStreaming,
      _en.browseByGenre,
      _en.browseByCountry,
      _en.browseByLanguage,
      _en.browseSectionTopics,
      _en.browsePolls,
      _en.browseConversations,
      _en.browseScenes,
      _en.browseQuestions,
      _en.browseHotTakes,
      _en.browseNewHere,
      _en.browseSocialMedia,
      _en.browseFollowUs,
      _en.browseGifts,
      _en.browseContact,
      _en.browseTerms,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('a topic row opens takes filtered by its tag', (tester) async {
    final repo = FakeBrowseRepository();
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browsePolls);
    expect(repo.takeRequests, [TakeTag.poll]);
    expect(find.text(_en.browseTakesEmpty), findsOneWidget);
  });

  testWidgets('top 100 takes asks for every tag', (tester) async {
    final repo = FakeBrowseRepository();
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browseTopTakes);
    expect(repo.takeRequests, [null]);
  });

  testWidgets('browse by year: pick a year, then see its films',
      (tester) async {
    final repo = FakeBrowseRepository(
      films: const [Movie(id: 'tt0111161', title: 'Shawshank', year: 1994)],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BrowseYearsScreen(repository: repo, now: DateTime(2026, 6)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('2028'), findsNothing);

    await tester.scrollUntilVisible(find.text('1994'), 300);
    await tester.ensureVisible(find.text('1994'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1994'));
    await tester.pumpAndSettle();

    expect(repo.filmRequests.single.year, 1994);
    expect(find.text('Shawshank'), findsOneWidget);
  });

  testWidgets('browse by streaming service: pick a service, then its films',
      (tester) async {
    final repo = FakeBrowseRepository(
      services: const [StreamingService(id: 8, name: 'Netflix')],
      films: const [Movie(id: 'tt1', title: 'Some Film')],
    );
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browseByStreaming);
    expect(find.text(_en.browseServicesTitle), findsOneWidget);

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    expect(repo.filmRequests.single.serviceId, 8);
    expect(find.text('Some Film'), findsOneWidget);
  });

  testWidgets('browse by genre: pick a genre, then its films', (tester) async {
    final repo = FakeBrowseRepository(
      genres: const [BrowseGenre(id: 11, name: 'Horror')],
      films: const [Movie(id: 'tt1', title: 'Scary Film')],
    );
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browseByGenre);
    expect(find.text(_en.browseGenresTitle), findsOneWidget);

    await tester.tap(find.text('Horror'));
    await tester.pumpAndSettle();

    expect(repo.filmRequests.single.genreId, 11);
    expect(find.text('Scary Film'), findsOneWidget);
  });

  testWidgets('browse by country lists films streaming there', (tester) async {
    final repo = FakeBrowseRepository(
      countries: const [BrowseCountry(code: 'FR', name: 'France')],
    );
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browseByCountry);
    expect(find.text(_en.browseCountriesHint), findsOneWidget);

    await tester.tap(find.text('France'));
    await tester.pumpAndSettle();

    expect(repo.filmRequests.single.country, 'FR');
    expect(find.text(_en.browseStreamingIn('France')), findsOneWidget);
  });

  testWidgets('browse by language filters by the ISO code', (tester) async {
    final repo = FakeBrowseRepository();
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browseByLanguage);

    await tester.scrollUntilVisible(find.text(_en.browseLanguageKo), 200);
    await tester.tap(find.text(_en.browseLanguageKo));
    await tester.pumpAndSettle();

    expect(repo.filmRequests.single.language, 'ko');
  });

  testWidgets('a film list that fails to load offers a retry',
      (tester) async {
    final repo = FakeBrowseRepository(error: Exception('down'));
    await _pump(tester, BrowseMenu(repository: repo));
    await _tapText(tester, _en.browsePopularFilms);
    expect(find.text(_en.findErrorTitle), findsOneWidget);

    repo.error = null;
    await tester.tap(find.text(_en.findErrorRetry));
    await tester.pumpAndSettle();
    expect(repo.filmRequests, hasLength(2));
  });

  testWidgets('info rows open a coming soon page', (tester) async {
    await _pump(tester, BrowseMenu(repository: FakeBrowseRepository()));
    await _tapText(tester, _en.browseContact);
    expect(find.text(_en.browseComingSoonTitle), findsOneWidget);
  });
}
