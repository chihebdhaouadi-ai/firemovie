import 'dart:convert';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/social/data/social_models.dart';
import 'package:film_wise_mobile/features/social/data/social_repository.dart';
import 'package:film_wise_mobile/features/social/views/movie_suggestion_screen.dart';
import 'package:film_wise_mobile/features/social/views/notifications_screen.dart';
import 'package:film_wise_mobile/features/social/views/user_search_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _json = {'content-type': 'application/json'};

SocialRepository _repo(http.Client client) =>
    SocialRepository(client: ApiClient(httpClient: client));

Map<String, dynamic> _notif(int id, {String kind = 'friend_request'}) => {
      'id': id,
      'kind': kind,
      'actor': {'id': 9, 'username': 'kira', 'avatar': null},
      'friend_request_id': 5,
      'read': false,
      'created_at': '2026-10-19T10:00:00Z',
    };

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  group('SocialRepository', () {
    test('searchUsers sends the query and parses avatars', () async {
      late Uri seen;
      final client = MockClient((request) async {
        seen = request.url;
        return http.Response(
          jsonEncode([
            {'id': 9, 'username': 'kira', 'avatar': 'https://cdn.test/a.png'},
          ]),
          200,
          headers: _json,
        );
      });

      final users = await _repo(client).searchUsers('ki');

      expect(seen.path, '/api/social/users/search');
      expect(seen.queryParameters['q'], 'ki');
      expect(users.single.username, 'kira');
      expect(users.single.avatarUrl, 'https://cdn.test/a.png');
    });

    test('acceptFriendRequest completes on 204', () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response('', 204);
      });

      await _repo(client).acceptFriendRequest(5);

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/social/friend-requests/5/accept');
    });

    test('notifications drops kinds the app does not know', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'unread_count': 1,
            'results': [_notif(1), _notif(2, kind: 'mystery')],
          }),
          200,
          headers: _json,
        );
      });

      final page = await _repo(client).notifications();

      expect(page.unreadCount, 1);
      expect(page.items.map((item) => item.id), [1]);
      expect(page.items.single.kind, NotificationKind.friendRequest);
      expect(page.items.single.friendRequestId, 5);
    });
  });

  group('UserSearchScreen', () {
    Future<void> pumpSearch(
      WidgetTester tester,
      http.Client client, {
      ValueChanged<SocialUser>? onOpenUser,
    }) {
      return tester.pumpWidget(
        _app(
          UserSearchScreen(
            repository: _repo(client),
            onOpenUser: onOpenUser ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('one character shows the hint and sends no request',
        (tester) async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return http.Response('[]', 200, headers: _json);
      });
      await pumpSearch(tester, client);
      await tester.pump();

      expect(find.text(_en.searchPeopleMinChars), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text(_en.searchPeopleMinChars), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets('rapid typing sends one request for the final query',
        (tester) async {
      var calls = 0;
      String? lastQuery;
      final client = MockClient((request) async {
        calls++;
        lastQuery = request.url.queryParameters['q'];
        return http.Response('[]', 200, headers: _json);
      });
      await pumpSearch(tester, client);

      await tester.enterText(find.byType(TextField), 'al');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ali');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'alic');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(lastQuery, 'alic');
    });

    testWidgets('results are listed and tapping one opens that user',
        (tester) async {
      final opened = <SocialUser>[];
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': 9, 'username': 'alice', 'avatar': null},
          ]),
          200,
          headers: _json,
        );
      });
      await pumpSearch(tester, client, onOpenUser: opened.add);

      await tester.enterText(find.byType(TextField), 'al');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('alice'), findsOneWidget);

      await tester.tap(find.text('alice'));
      await tester.pumpAndSettle();

      expect(opened.single.id, 9);
    });
  });

  group('NotificationsScreen', () {
    Future<void> pumpNotifications(
      WidgetTester tester,
      http.Client client,
    ) {
      return tester.pumpWidget(
        _app(
          NotificationsScreen(
            repository: _repo(client),
            onOpenUser: (_) {},
          ),
        ),
      );
    }

    testWidgets('shows messages and marks notifications read', (tester) async {
      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.url.path == '/api/social/notifications') {
          return http.Response(
            jsonEncode({
              'unread_count': 1,
              'results': [_notif(1)],
            }),
            200,
            headers: _json,
          );
        }
        return http.Response('', 204);
      });

      await pumpNotifications(tester, client);
      await tester.pumpAndSettle();

      expect(find.text(_en.notificationFriendRequest('kira')), findsOneWidget);
      expect(calls, contains('POST /api/social/notifications/read'));
    });

    testWidgets('accept posts the response and removes the notification',
        (tester) async {
      var accepted = false;
      final client = MockClient((request) async {
        if (request.url.path == '/api/social/notifications') {
          return http.Response(
            jsonEncode({
              'unread_count': 1,
              'results': [_notif(1)],
            }),
            200,
            headers: _json,
          );
        }
        if (request.url.path == '/api/social/friend-requests/5/accept') {
          accepted = true;
          return http.Response('', 204);
        }
        return http.Response('', 204);
      });

      await pumpNotifications(tester, client);
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.friendAccept));
      await tester.pumpAndSettle();

      expect(accepted, isTrue);
      expect(find.text(_en.notificationFriendRequest('kira')), findsNothing);
      expect(find.text(_en.notificationsEmpty), findsOneWidget);
    });

    testWidgets('a request that no longer exists is removed with a notice',
        (tester) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/social/notifications') {
          return http.Response(
            jsonEncode({
              'unread_count': 1,
              'results': [_notif(1)],
            }),
            200,
            headers: _json,
          );
        }
        if (request.url.path == '/api/social/friend-requests/5/accept') {
          return http.Response(
            jsonEncode({'detail': 'Not found.', 'code': 'not_found'}),
            404,
            headers: _json,
          );
        }
        return http.Response('', 204);
      });

      await pumpNotifications(tester, client);
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.friendAccept));
      await tester.pumpAndSettle();

      expect(find.text(_en.friendRequestGone), findsOneWidget);
      expect(find.text(_en.notificationFriendRequest('kira')), findsNothing);
    });
  });

  group('movie suggestions', () {
    Map<String, dynamic> friendsJson(List<Map<String, dynamic>> friends) => {
          'following': <Object>[],
          'followers': <Object>[],
          'friends': friends,
        };

    Map<String, dynamic> user(int id, String name) =>
        {'id': id, 'username': name, 'avatar': null};

    CheckboxListTile checkbox(WidgetTester tester, String label) =>
        tester.widget<CheckboxListTile>(
          find.widgetWithText(CheckboxListTile, label),
        );

    FilledButton sendButton(WidgetTester tester) => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, _en.suggestionSend),
        );

    Future<void> pumpSuggest(
      WidgetTester tester,
      http.Client client, {
      Set<int> preselected = const {},
    }) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          MovieSuggestionScreen(
            socialRepository: _repo(client),
            findRepository: FindRepository(client: ApiClient(httpClient: client)),
            preselectedUserIds: preselected,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    test('notifications carry the suggested film and comment', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'unread_count': 1,
            'results': [
              {
                'id': 3,
                'kind': 'movie_suggestion',
                'actor': user(9, 'kira'),
                'friend_request_id': null,
                'read': false,
                'suggestion': {
                  'film_id': 603,
                  'film_title': 'The Matrix',
                  'film_year': 1999,
                  'film_poster_url': '',
                  'comment': 'Watch this one',
                },
              },
            ],
          }),
          200,
          headers: _json,
        );
      });

      final item = (await _repo(client).notifications()).items.single;

      expect(item.kind, NotificationKind.movieSuggestion);
      expect(item.suggestion!.filmId, '603');
      expect(item.suggestion!.title, 'The Matrix');
      expect(item.suggestion!.year, 1999);
      expect(item.suggestion!.posterUrl, isNull);
      expect(item.suggestion!.comment, 'Watch this one');
    });

    test('sendMovieSuggestion posts the film, comment and recipients', () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response(jsonEncode({'sent': 2}), 201, headers: _json);
      });

      final count = await _repo(client).sendMovieSuggestion(
        movie: const Movie(id: '603', title: 'The Matrix', year: 1999),
        comment: 'Watch this',
        recipientIds: [9, 10],
      );

      expect(count, 2);
      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/social/movie-suggestions');
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['film_id'], '603');
      expect(body['film_title'], 'The Matrix');
      expect(body['film_year'], 1999);
      expect(body['film_poster_url'], '');
      expect(body['comment'], 'Watch this');
      expect(body['recipient_ids'], [9, 10]);
    });

    testWidgets('friends load with the given friend preselected and send waits',
        (tester) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/social/me/connections') {
          return http.Response(
            jsonEncode(friendsJson([user(9, 'kira'), user(10, 'milo')])),
            200,
            headers: _json,
          );
        }
        return http.Response('[]', 200, headers: _json);
      });

      await pumpSuggest(tester, client, preselected: {9});

      expect(checkbox(tester, 'kira').value, isTrue);
      expect(checkbox(tester, 'milo').value, isFalse);
      expect(sendButton(tester).onPressed, isNull);
    });

    testWidgets('select all toggles every friend', (tester) async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(friendsJson([user(9, 'kira'), user(10, 'milo')])),
          200,
          headers: _json,
        );
      });

      await pumpSuggest(tester, client);

      await tester.tap(find.text(_en.suggestionSelectAll));
      await tester.pump();
      expect(checkbox(tester, 'kira').value, isTrue);
      expect(checkbox(tester, 'milo').value, isTrue);
      expect(checkbox(tester, _en.suggestionSelectAll).value, isTrue);

      await tester.tap(find.text(_en.suggestionSelectAll));
      await tester.pump();
      expect(checkbox(tester, 'kira').value, isFalse);
      expect(checkbox(tester, 'milo').value, isFalse);
    });

    testWidgets('without friends the screen says to add friends first',
        (tester) async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(friendsJson(const [])),
          200,
          headers: _json,
        );
      });

      await pumpSuggest(tester, client);

      expect(find.text(_en.suggestionNoFriends), findsOneWidget);
    });

    testWidgets(
        'search, pick a movie, add a comment and send posts the suggestion',
        (tester) async {
      final sent = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        switch (request.url.path) {
          case '/api/social/me/connections':
            return http.Response(
              jsonEncode(friendsJson([user(9, 'kira'), user(10, 'milo')])),
              200,
              headers: _json,
            );
          case '/api/films/search':
            return http.Response(
              jsonEncode({
                'page': 1,
                'total_pages': 1,
                'total_results': 1,
                'results': [
                  {
                    'film_id': 603,
                    'title': 'The Matrix',
                    'year': 1999,
                    'poster_url': null,
                  },
                ],
              }),
              200,
              headers: _json,
            );
          case '/api/social/movie-suggestions':
            sent.add(jsonDecode(request.body) as Map<String, dynamic>);
            return http.Response(jsonEncode({'sent': 2}), 201, headers: _json);
        }
        return http.Response('[]', 200, headers: _json);
      });

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => MovieSuggestionScreen(
                      socialRepository: _repo(client),
                      findRepository: FindRepository(
                        client: ApiClient(httpClient: client),
                      ),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'matrix');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('The Matrix'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en.suggestionSelectAll));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Watch this tonight');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, _en.suggestionSend));
      await tester.pumpAndSettle();

      expect(sent.single['film_id'], '603');
      expect(sent.single['comment'], 'Watch this tonight');
      expect(sent.single['recipient_ids'], [9, 10]);
      expect(find.byType(MovieSuggestionScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('a recipient who is no longer a friend keeps the screen open with a notice',
        (tester) async {
      final client = MockClient((request) async {
        switch (request.url.path) {
          case '/api/social/me/connections':
            return http.Response(
              jsonEncode(friendsJson([user(9, 'kira')])),
              200,
              headers: _json,
            );
          case '/api/films/search':
            return http.Response(
              jsonEncode({
                'page': 1,
                'total_pages': 1,
                'total_results': 1,
                'results': [
                  {'film_id': 603, 'title': 'The Matrix', 'year': 1999, 'poster_url': null},
                ],
              }),
              200,
              headers: _json,
            );
          case '/api/social/movie-suggestions':
            return http.Response(
              jsonEncode({'detail': 'Not friends.', 'code': 'not_friends'}),
              400,
              headers: _json,
            );
        }
        return http.Response('[]', 200, headers: _json);
      });

      await pumpSuggest(tester, client, preselected: {9});
      await tester.enterText(find.byType(TextField).first, 'matrix');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('The Matrix'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, _en.suggestionSend));
      await tester.pumpAndSettle();

      expect(find.text(_en.suggestionNotFriends), findsOneWidget);
      expect(find.text(_en.suggestionFailed), findsNothing);
      expect(find.byType(MovieSuggestionScreen), findsOneWidget);
    });
  });
}
