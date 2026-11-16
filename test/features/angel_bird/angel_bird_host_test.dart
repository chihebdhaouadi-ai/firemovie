import 'dart:convert';

import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/angel_bird/angel_bird_host.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/find/views/film_detail_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lottie/lottie.dart';

final _en = lookupAppLocalizations(const Locale('en'));
final _navigatorKey = GlobalKey<NavigatorState>();
const _emptySpot = Offset(400, 800);

ApiHomeRepository _repository({
  List<Map<String, Object?>> films = const [],
  int status = 200,
}) {
  return ApiHomeRepository(
    baseUrl: 'https://test.local/api/film/',
    client: MockClient((request) async {
      if (status != 200) return http.Response('{}', status);
      return http.Response(jsonEncode({'data': films}), 200);
    }),
  );
}

Map<String, Object?> _filmJson(String id, String title) =>
    {'imdp_id': id, 'title': title, 'poster_url': null};

Widget _columnBody() => Column(
      children: [
        SizedBox(
          height: 200,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Tap me'),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );

Widget _listBody() => ListView(
      children: [
        SizedBox(
          height: 200,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Tap me'),
          ),
        ),
      ],
    );

Future<void> _pumpApp(
  WidgetTester tester,
  HomeRepository repository, {
  Widget Function()? body,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: _navigatorKey,
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AngelBirdHost(
        navigatorKey: _navigatorKey,
        homeRepository: repository,
        child: child!,
      ),
      home: Scaffold(body: (body ?? _columnBody)()),
    ),
  );
}

Future<void> _hold(WidgetTester tester, Offset at, Duration duration) async {
  final gesture = await tester.startGesture(at);
  await tester.pump(duration);
  await gesture.up();
  await _settleFrames(tester);
}

Future<void> _settleFrames(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _summon(WidgetTester tester) =>
    _hold(tester, _emptySpot, const Duration(seconds: 3, milliseconds: 100));

void main() {
  setUp(() => Session.token = 'token');
  tearDown(Session.clear);

  testWidgets('holding empty space for three seconds calls the bird in',
      (tester) async {
    await _pumpApp(tester, _repository());

    await _summon(tester);

    expect(find.byType(Lottie), findsOneWidget);
    expect(find.text(_en.angelBirdQuestion), findsOneWidget);
  });

  testWidgets('a short press on empty space does not call the bird',
      (tester) async {
    await _pumpApp(tester, _repository());

    await _hold(tester, _emptySpot, const Duration(seconds: 1));

    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('holding a button does not call the bird', (tester) async {
    await _pumpApp(tester, _repository());

    await _hold(
      tester,
      tester.getCenter(find.text('Tap me')),
      const Duration(seconds: 3, milliseconds: 100),
    );

    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('holding empty space inside a scrollable list calls the bird',
      (tester) async {
    await _pumpApp(tester, _repository(), body: _listBody);

    await _summon(tester);

    expect(find.text(_en.angelBirdQuestion), findsOneWidget);
  });

  testWidgets('holding a button inside a scrollable list does not call the bird',
      (tester) async {
    await _pumpApp(tester, _repository(), body: _listBody);

    await _hold(
      tester,
      tester.getCenter(find.text('Tap me')),
      const Duration(seconds: 3, milliseconds: 100),
    );

    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('a logged out user never sees the bird', (tester) async {
    Session.clear();
    await _pumpApp(tester, _repository());

    await _summon(tester);

    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('Not now sends the bird away', (tester) async {
    await _pumpApp(tester, _repository());
    await _summon(tester);

    await tester.tap(find.widgetWithText(TextButton, _en.angelBirdNotNow));
    await _settleFrames(tester);

    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('Yes lists the top 5 and a film opens its page', (tester) async {
    await _pumpApp(
      tester,
      _repository(films: [
        _filmJson('tt0113277', 'Heat'),
        _filmJson('tt0068646', 'The Godfather'),
      ]),
    );
    await _summon(tester);

    await tester.tap(find.widgetWithText(FilledButton, _en.angelBirdYes));
    await _settleFrames(tester);

    expect(find.text(_en.angelBirdPickFilm), findsOneWidget);
    expect(find.text('Heat'), findsOneWidget);
    expect(find.text('The Godfather'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Heat'));
    await _settleFrames(tester);

    expect(find.byType(FilmDetailScreen), findsOneWidget);
    expect(find.text(_en.angelBirdQuestion), findsNothing);
  });

  testWidgets('an empty top 5 says so instead of offering a film',
      (tester) async {
    await _pumpApp(tester, _repository());
    await _summon(tester);

    await tester.tap(find.widgetWithText(FilledButton, _en.angelBirdYes));
    await _settleFrames(tester);

    expect(find.text(_en.angelBirdEmptyTop5), findsOneWidget);
    expect(find.text(_en.angelBirdPickFilm), findsNothing);
  });

  testWidgets('a failed top 5 request offers a retry', (tester) async {
    await _pumpApp(tester, _repository(status: 500));
    await _summon(tester);

    await tester.tap(find.widgetWithText(FilledButton, _en.angelBirdYes));
    await _settleFrames(tester);

    expect(find.text(_en.angelBirdLoadFailed), findsOneWidget);
    expect(find.widgetWithText(FilledButton, _en.angelBirdRetry), findsOneWidget);
  });
}
