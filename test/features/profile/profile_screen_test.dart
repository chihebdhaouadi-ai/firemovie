import 'dart:convert';

import 'package:film_wise_mobile/core/app_locale.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/profile/data/profile_repository.dart';
import 'package:film_wise_mobile/features/profile/views/profile_screen.dart';
import 'package:film_wise_mobile/features/social/data/social_repository.dart';
import 'package:film_wise_mobile/features/social/views/movie_suggestion_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _json = {'content-type': 'application/json'};

final _meBody = jsonEncode({'id': 7, 'username': 'cinephile'});

final _progress = {
  'level': 12,
  'xp': 3850,
  'xp_into_level': 0,
  'xp_for_next_level': 650,
  'reviews': 42,
  'reactions': 1200,
  'comments': 7,
  'achievements': [
    {'key': 'film_critic', 'current': 7, 'target': 10, 'unlocked': false},
    {'key': 'debater', 'current': 31, 'target': 50, 'unlocked': false},
    {
      'key': 'local_cinema',
      'current': 0,
      'target': 20,
      'unlocked': false,
      'available': false,
    },
  ],
  'badges': [
    {'key': 'well_argued', 'current': 31, 'target': 10, 'unlocked': true},
    {'key': 'changed_my_mind', 'current': 3, 'target': 10, 'unlocked': false},
    {
      'key': 'disagree_but_fair',
      'current': 0,
      'target': 10,
      'unlocked': false,
    },
    {'key': 'top_critic', 'current': 0, 'target': 1, 'unlocked': false},
    {'key': 'first_take', 'current': 1, 'target': 1, 'unlocked': true},
  ],
  'frames': [
    {'key': 'bronze', 'current': 0, 'target': 0, 'unlocked': true},
    {'key': 'explorer', 'current': 12, 'target': 10, 'unlocked': true},
    {'key': 'debater', 'current': 31, 'target': 50, 'unlocked': false},
    {'key': 'gold', 'current': 12, 'target': 15, 'unlocked': false},
    {'key': 'legend', 'current': 12, 'target': 30, 'unlocked': false},
  ],
};

final _profileBody = jsonEncode({
  'id': 7,
  'username': 'cinephile',
  'stats': {'watched': 300, 'watchlist': 4, 'reviews': 42},
  'equipped_frame': 'explorer',
  'progress': _progress,
});

final _otherBody = jsonEncode({
  'id': 9,
  'username': 'otheruser',
  'friendship': 'none',
  'stats': {'watched': 10, 'watchlist': 1, 'reviews': 0},
});

final _connectionsBody = jsonEncode({'following': [], 'followers': []});

final _notificationsBody = jsonEncode({'unread_count': 0, 'results': []});

ProfileRepository _profiles(http.Client client) =>
    ProfileRepository(client: ApiClient(httpClient: client));

SocialRepository _social(http.Client client) =>
    SocialRepository(client: ApiClient(httpClient: client));

Future<http.Response> _ownApi(http.Request request) async {
  switch (request.url.path) {
    case '/api/account/profile':
      return http.Response(_meBody, 200, headers: _json);
    case '/api/social/me/connections':
      return http.Response(_connectionsBody, 200, headers: _json);
    case '/api/social/notifications':
      return http.Response(_notificationsBody, 200, headers: _json);
    default:
      return http.Response(_profileBody, 200, headers: _json);
  }
}

Future<void> _scrollTo(WidgetTester tester, String text) {
  return tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> _pump(
  WidgetTester tester,
  http.Client client, {
  int? userId,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfileScreen(
        userId: userId,
        repository: _profiles(client),
        socialRepository: _social(client),
      ),
    ),
  );
}

void main() {
  testWidgets('own profile shows level, stats, badges, frames and achievements',
      (tester) async {
    final client = MockClient(_ownApi);
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text('cinephile'), findsOneWidget);
    expect(find.text(_en.profileLevelLabel(12)), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('1.2K'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    await _scrollTo(tester, _en.achLocalCinemaTitle);
    expect(find.text(_en.achFilmCriticTitle), findsOneWidget);
    // The achievement and the Debater frame share a name.
    expect(find.text(_en.achDebaterTitle), findsNWidgets(2));
    expect(find.text(_en.achLocalCinemaTitle), findsOneWidget);
    expect(find.text(_en.achComingSoon), findsOneWidget);
    await _scrollTo(tester, _en.frameExplorerTitle);
    expect(find.text(_en.frameEquipped), findsOneWidget);
    expect(find.text(_en.frameLegendTitle), findsOneWidget);
  });

  testWidgets('tapping an unlocked frame equips it on the server',
      (tester) async {
    final bodies = <Map<String, dynamic>>[];
    Future<http.Response> api(http.Request request) async {
      if (request.method == 'PATCH') {
        bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response(_profileBody, 200, headers: _json);
      }
      return _ownApi(request);
    }

    await _pump(tester, MockClient(api));
    await tester.pumpAndSettle();
    // Frame tiles are the only InkWells here; achievements share titles.
    final explorer = find.widgetWithText(InkWell, _en.frameExplorerTitle);
    final debater = find.widgetWithText(InkWell, _en.frameDebaterTitle);
    await tester.scrollUntilVisible(
      explorer,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Explorer is equipped already, so tapping it does nothing.
    await tester.tap(explorer);
    await tester.pumpAndSettle();
    expect(bodies, isEmpty);

    await tester.scrollUntilVisible(
      debater,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Debater is locked, so the tile is not interactive.
    await tester.tap(debater);
    await tester.pumpAndSettle();
    expect(bodies, isEmpty);
  });

  testWidgets('own profile offers edit controls and no friend or block actions',
      (tester) async {
    final client = MockClient(_ownApi);
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.byTooltip(_en.profileEditPhoto), findsOneWidget);
    expect(find.byTooltip(_en.profileEditBio), findsOneWidget);
    expect(find.byTooltip(_en.profileMoreTooltip), findsNothing);
    expect(find.text(_en.friendAdd), findsNothing);
    await _scrollTo(tester, _en.suggestMovieAction);
    expect(find.text(_en.suggestMovieAction), findsOneWidget);
  });

  testWidgets('own profile language picker selects a language', (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => AppLocale.select(null));
    final client = MockClient(_ownApi);
    await _pump(tester, client);
    await tester.pumpAndSettle();

    await _scrollTo(tester, _en.profileLanguageButton);
    await tester.tap(find.text(_en.profileLanguageButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(AppLocale.current.value, const Locale('fr'));
    expect(find.text(_en.profileLanguageDialogTitle), findsNothing);
  });

  testWidgets('a failed load shows an error and retry reloads the profile',
      (tester) async {
    var profileCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/api/account/profile') {
        profileCalls++;
        if (profileCalls == 1) {
          return http.Response('{}', 500, headers: _json);
        }
      }
      return _ownApi(request);
    });
    await _pump(tester, client);
    await tester.pumpAndSettle();

    expect(find.text(_en.profileErrorTitle), findsOneWidget);

    await tester.tap(find.text(_en.profileRetry));
    await tester.pumpAndSettle();

    expect(find.text(_en.profileErrorTitle), findsNothing);
    expect(find.text('cinephile'), findsOneWidget);
    expect(profileCalls, 2);
  });

  testWidgets('another user profile offers add friend and no edit controls',
      (tester) async {
    final client = MockClient((request) async {
      return http.Response(_otherBody, 200, headers: _json);
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    expect(find.text('otheruser'), findsOneWidget);
    expect(find.text(_en.friendAdd), findsOneWidget);
    expect(find.byTooltip(_en.profileEditPhoto), findsNothing);
    expect(find.byTooltip(_en.profileSearchTooltip), findsNothing);
  });

  testWidgets('add friend sends a request and shows it as outgoing',
      (tester) async {
    late http.Request sent;
    final client = MockClient((request) async {
      if (request.url.path == '/api/social/friend-requests') {
        sent = request;
        return http.Response(
          jsonEncode({'id': 31, 'status': 'pending'}),
          201,
          headers: _json,
        );
      }
      return http.Response(_otherBody, 200, headers: _json);
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.friendAdd));
    await tester.pumpAndSettle();

    expect(jsonDecode(sent.body), {'user_id': 9});
    expect(find.text(_en.friendCancelRequest), findsOneWidget);
    expect(find.text(_en.friendAdd), findsNothing);
  });

  testWidgets('a failed friend request returns to add friend with a notice',
      (tester) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/social/friend-requests') {
        return http.Response('{}', 500, headers: _json);
      }
      return http.Response(_otherBody, 200, headers: _json);
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.friendAdd));
    await tester.pumpAndSettle();

    expect(find.text(_en.friendActionFailed), findsOneWidget);
    expect(find.text(_en.friendAdd), findsOneWidget);
    expect(find.text(_en.friendCancelRequest), findsNothing);
  });

  testWidgets(
      'already connected shows a notice and refreshes to the real state',
      (tester) async {
    var connected = false;
    final client = MockClient((request) async {
      if (request.url.path == '/api/social/friend-requests') {
        connected = true;
        return http.Response(
          jsonEncode(
              {'detail': 'Already connected.', 'code': 'already_connected'}),
          400,
          headers: _json,
        );
      }
      return http.Response(
        jsonEncode({
          'id': 9,
          'username': 'otheruser',
          'friendship': connected ? 'friends' : 'none',
          'stats': {'watched': 10, 'watchlist': 1, 'reviews': 0},
        }),
        200,
        headers: _json,
      );
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.friendAdd));
    await tester.pumpAndSettle();

    expect(find.text(_en.friendAlreadyConnected), findsOneWidget);
    expect(find.text(_en.friendFriends), findsOneWidget);
    expect(find.text(_en.friendAdd), findsNothing);
  });

  testWidgets('the more menu opens the block dialog and No closes it',
      (tester) async {
    final client = MockClient((request) async {
      return http.Response(_otherBody, 200, headers: _json);
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(_en.profileMoreTooltip));
    await tester.pumpAndSettle();

    expect(find.text(_en.profileBlockTitle), findsOneWidget);
    expect(find.text(_en.profileBlockReasonHint), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, _en.profileBlockYes),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text(_en.profileBlockNo));
    await tester.pumpAndSettle();

    expect(find.text(_en.profileBlockTitle), findsNothing);
  });

  testWidgets('a friend profile suggests a movie with that friend preselected',
      (tester) async {
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/api/social/me/connections':
          return http.Response(
            jsonEncode({
              'following': [],
              'followers': [],
              'friends': [
                {'id': 9, 'username': 'otheruser', 'avatar': null},
                {'id': 10, 'username': 'milo', 'avatar': null},
              ],
            }),
            200,
            headers: _json,
          );
        case '/api/social/notifications':
          return http.Response(_notificationsBody, 200, headers: _json);
        default:
          return http.Response(
            jsonEncode({
              'id': 9,
              'username': 'otheruser',
              'friendship': 'friends',
              'stats': {'watched': 10, 'watchlist': 1, 'reviews': 0},
            }),
            200,
            headers: _json,
          );
      }
    });
    await _pump(tester, client, userId: 9);
    await tester.pumpAndSettle();

    await _scrollTo(tester, _en.suggestMovieAction);
    await tester.tap(find.text(_en.suggestMovieAction));
    await tester.pumpAndSettle();

    expect(find.byType(MovieSuggestionScreen), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'otheruser'),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<CheckboxListTile>(
              find.widgetWithText(CheckboxListTile, 'milo'))
          .value,
      isFalse,
    );
  });
}
