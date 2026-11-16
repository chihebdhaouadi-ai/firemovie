import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/leaderboard/data/leaderboard_repository.dart';
import 'package:film_wise_mobile/features/leaderboard/views/leaderboard_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _json = {'content-type': 'application/json'};

Map<String, dynamic> _entry(int rank, int userId, String name, int reactions) {
  return {
    'rank': rank,
    'user_id': userId,
    'username': name,
    'avatar': null,
    'equipped_frame': 'bronze',
    'reviews': 3,
    'reactions': reactions,
  };
}

final _weekBody = jsonEncode({
  'period': 'week',
  'entries': [
    _entry(1, 1, 'damino', 1520),
    _entry(2, 2, 'Ala2929', 1240),
    _entry(3, 3, 'Nour_K', 960),
    _entry(4, 4, 'Lina_T', 410),
  ],
  'me': {
    'rank': 4,
    'user_id': 7,
    'username': 'cinephile',
    'avatar': null,
    'equipped_frame': 'bronze',
    'reviews': 2,
    'reactions': 80,
  },
});

final _monthBody = jsonEncode({
  'period': 'month',
  'entries': [_entry(1, 2, 'Ala2929', 300)],
  'me': null,
});

LeaderboardRepository _repo(http.Client client) =>
    LeaderboardRepository(client: ApiClient(httpClient: client));

Future<void> _pump(WidgetTester tester, http.Client client) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Reduced motion stops the looping frame animations so pumpAndSettle can finish.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: LeaderboardScreen(
          repository: _repo(client),
          onOpenUser: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the podium, the rest of the ranking and the viewer row',
      (tester) async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/takes/leaderboard/');
      expect(request.url.queryParameters['period'], 'week');
      return http.Response(_weekBody, 200, headers: _json);
    });
    await _pump(tester, client);
    await tester.pumpAndSettle();

    // The top three appear on the podium and again as the first rows.
    expect(find.text('damino'), findsNWidgets(2));
    expect(find.text('Ala2929'), findsNWidgets(2));
    expect(find.text('01'), findsOneWidget);
    expect(find.text('Nour_K'), findsNWidgets(2));
    expect(find.text('Lina_T'), findsOneWidget);
    expect(find.text('cinephile ${_en.leaderboardYouSuffix}'), findsOneWidget);
    expect(find.textContaining('1,520'), findsNWidgets(2));
  });

  testWidgets('switching the period requests that period', (tester) async {
    final periods = <String>[];
    final client = MockClient((request) async {
      final period = request.url.queryParameters['period']!;
      periods.add(period);
      return http.Response(
        period == 'month' ? _monthBody : _weekBody,
        200,
        headers: _json,
      );
    });
    await _pump(tester, client);
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.leaderboardPeriodMonth));
    await tester.pumpAndSettle();

    expect(periods, ['week', 'month']);
    expect(find.text('Ala2929'), findsNWidgets(2));
    expect(find.text('damino'), findsNothing);
  });

  testWidgets('a failed load offers a retry that loads the board',
      (tester) async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls == 1) return http.Response('{}', 500, headers: _json);
      return http.Response(_weekBody, 200, headers: _json);
    });
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text(_en.leaderboardLoadFailed), findsOneWidget);
    await tester.tap(find.text(_en.leaderboardRetry));
    await tester.pumpAndSettle();

    expect(find.text(_en.leaderboardLoadFailed), findsNothing);
    expect(find.text('damino'), findsNWidgets(2));
  });
}
