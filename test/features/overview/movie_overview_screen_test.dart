import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/overview/views/movie_overview_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../film_reviews/review_test_support.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _dune = Film(imdbId: 'tt0000001', title: 'Dune');

final _detailBody = jsonEncode({
  'film_id': 'tt0000001',
  'title': 'Dune',
  'year': 2021,
  'runtime': 155,
  'vote_average': 7.8,
  'overview': 'A noble family rises to power on a desert planet.',
  'director': 'Denis Villeneuve',
  'genres': ['Science Fiction'],
  'in_lists': ['watched'],
  'watch_providers': {
    'link': null,
    'flatrate': [
      {'name': 'Netflix', 'logo_url': null},
    ],
    'rent': [],
    'buy': [],
  },
});

final _sparseBody = jsonEncode({
  'film_id': 'tt0000001',
  'title': 'Dune',
  'genres': <String>[],
  'in_lists': <String>[],
  'watch_providers': {'link': null, 'flatrate': [], 'rent': [], 'buy': []},
});

const _json = {'content-type': 'application/json'};

typedef _Handler = Future<http.Response> Function(http.Request request);

http.Client _client(_Handler detail, ReviewApi review) {
  return MockClient((request) {
    final path = request.url.path;
    if (path.startsWith('/api/takes/')) return review.handle(request);
    if (path.endsWith('/stills/')) {
      return Future.value(http.Response('not found', 404));
    }
    return detail(request);
  });
}

Future<void> _pump(WidgetTester tester, http.Client client) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieOverviewScreen(
        film: _dune,
        repository: FindRepository(client: ApiClient(httpClient: client)),
        reviewRepository: reviewRepositoryFor(client),
      ),
    ),
  );
}

Future<void> _scrollTo(WidgetTester tester, String text) {
  return tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  testWidgets('loaded overview shows rating, synopsis, providers and sections',
      (tester) async {
    final client = _client(
      (_) async => http.Response(_detailBody, 200, headers: _json),
      ReviewApi(),
    );
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text(_en.overviewRating('7.8')), findsOneWidget);
    expect(find.text(_en.overviewRatingsCount(128)), findsOneWidget);
    expect(
      find.text('A noble family rises to power on a desert planet.'),
      findsOneWidget,
    );
    expect(find.text(_en.overviewWhereToWatch), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, _en.overviewTrailer),
          )
          .onPressed,
      isNull,
    );
    await _scrollTo(tester, _en.overviewActivityTitle);
    expect(find.text(_en.overviewActivityTitle), findsOneWidget);
    await _scrollTo(tester, _en.reviewReactionTitle);
    expect(find.text(_en.reviewReactionTitle), findsOneWidget);
    await _scrollTo(tester, _en.findAttribution);
    expect(find.text(_en.findAttribution), findsOneWidget);
  });

  testWidgets('missing rating and providers show fallbacks', (tester) async {
    final client = _client(
      (_) async => http.Response(_sparseBody, 200, headers: _json),
      ReviewApi(),
    );
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text(_en.overviewNoRating), findsOneWidget);
    expect(find.text(_en.overviewNoStreaming), findsOneWidget);
  });

  testWidgets('a failed load shows an error and retry reloads the overview',
      (tester) async {
    var detailCalls = 0;
    final client = _client((_) async {
      detailCalls++;
      if (detailCalls == 1) return http.Response('unavailable', 500);
      return http.Response(_detailBody, 200, headers: _json);
    }, ReviewApi());
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text(_en.findDetailsErrorTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, _en.findDetailsRetry));
    await tester.pumpAndSettle();

    expect(find.text(_en.findDetailsErrorTitle), findsNothing);
    expect(find.text(_en.overviewRating('7.8')), findsOneWidget);
    expect(detailCalls, 2);
  });
}
