import 'dart:convert';
import 'dart:io';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:film_wise_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _json = {'content-type': 'application/json'};

String _profileJson({int top = 0, int watched = 0, int watchlist = 0}) =>
    jsonEncode({
      'id': 7,
      'username': 'cinephile',
      'top_movies': List.filled(top, {'id': 1}),
      'watched_movies': List.filled(watched, {'id': 2}),
      'watchlist_movies': List.filled(watchlist, {'id': 3}),
    });

OnboardingRepository _repository(http.Client client) =>
    OnboardingRepository(client: ApiClient(httpClient: client));

Future<void> _pump(
  WidgetTester tester, {
  required OnboardingRepository repository,
  Future<String?> Function()? pickImage,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OnboardingScreen(repository: repository, pickImage: pickImage),
      routes: {
        '/home': (context) => const Text('home screen'),
      },
    ),
  );
}

void main() {
  testWidgets('steps run in order and skip moves on without saving',
      (tester) async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(_profileJson(), 200, headers: _json);
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    final titles = [
      _en.onboardingAvatarTitle,
      _en.onboardingCoverTitle,
      _en.onboardingBioTitle,
      _en.onboardingTop5Title,
      _en.onboardingWatchedTitle,
      _en.onboardingWatchlistTitle,
    ];

    expect(find.text(titles.first), findsOneWidget);
    expect(find.text(_en.onboardingStepCounter(1, 6)), findsOneWidget);

    for (var i = 1; i < titles.length; i++) {
      await tester.tap(find.text(_en.onboardingSkip));
      await tester.pumpAndSettle();
      expect(find.text(titles[i]), findsOneWidget);
      expect(find.text(_en.onboardingStepCounter(i + 1, 6)), findsOneWidget);
    }

    expect(requests.where((r) => r.method == 'PATCH'), isEmpty);
  });

  testWidgets('bio is saved trimmed and the flow continues to the top 5 step',
      (tester) async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(_profileJson(), 200, headers: _json);
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  Noir fan  ');
    await tester.tap(find.text(_en.onboardingContinue));
    await tester.pumpAndSettle();

    final patch = requests.singleWhere((r) => r.method == 'PATCH');
    expect(patch.url.path, '/api/account/profile');
    expect(jsonDecode(patch.body), {'bio': 'Noir fan'});
    expect(find.text(_en.onboardingTop5Title), findsOneWidget);
  });

  testWidgets('an empty bio continues without sending a request',
      (tester) async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(_profileJson(), 200, headers: _json);
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.onboardingContinue));
    await tester.pumpAndSettle();

    expect(requests.where((r) => r.method == 'PATCH'), isEmpty);
    expect(find.text(_en.onboardingTop5Title), findsOneWidget);
  });

  testWidgets('movie steps show the counts already saved on the profile',
      (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        _profileJson(top: 2, watched: 3),
        200,
        headers: _json,
      );
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text(_en.onboardingSkip));
      await tester.pumpAndSettle();
    }
    expect(find.text(_en.onboardingTop5Progress(2)), findsOneWidget);

    await tester.tap(find.text(_en.onboardingSkip));
    await tester.pumpAndSettle();
    expect(find.text(_en.onboardingFilmsAdded(3)), findsOneWidget);
  });

  testWidgets('a picked photo is uploaded as multipart and marked saved',
      (tester) async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(_profileJson(), 200, headers: _json);
    });
    final dir = Directory.systemTemp.createTempSync('onboarding_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/avatar.png')
      ..writeAsBytesSync(const [0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]);

    await _pump(
      tester,
      repository: _repository(client),
      pickImage: () async => file.path,
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text(_en.onboardingChoosePhoto));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    final upload = requests.singleWhere((r) => r.method == 'PATCH');
    expect(upload.url.path, '/api/account/profile');
    expect(upload.headers['content-type'], startsWith('multipart/form-data'));
    expect(find.text(_en.onboardingPhotoSaved), findsOneWidget);
  });

  testWidgets('finishing the last step opens the home screen', (tester) async {
    final client = MockClient((request) async {
      return http.Response(_profileJson(), 200, headers: _json);
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text(_en.onboardingSkip));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text(_en.onboardingFinish));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('finish later leaves onboarding from the first step',
      (tester) async {
    final client = MockClient((request) async {
      return http.Response(_profileJson(), 200, headers: _json);
    });
    await _pump(tester, repository: _repository(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.onboardingFinishLater));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}
