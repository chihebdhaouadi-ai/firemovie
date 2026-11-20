import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/widgets/comment_thread.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/movie_lists/data/movie_list.dart';
import 'package:film_wise_mobile/features/movie_lists/data/movie_list_repository.dart';
import 'package:film_wise_mobile/features/movie_lists/presentation/create_movie_list_screen.dart';
import 'package:film_wise_mobile/features/movie_lists/presentation/movie_list_screen.dart';
import 'package:film_wise_mobile/features/movie_lists/presentation/widgets/movie_lists_section.dart';
import 'package:film_wise_mobile/features/social/data/social_repository.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _ana = ListPerson(id: 2, username: 'ana');

MovieList _list(int id, String name,
        {ListPerson owner = _ana, bool mine = false}) =>
    MovieList(
      id: id,
      name: name,
      owner: owner,
      isMine: mine,
      filmCount: 2,
      likes: 3,
      comments: 1,
      films: const [
        ListFilm(filmId: 'tt0000001', title: 'Heat'),
        ListFilm(filmId: 'tt0000002', title: 'Ronin'),
      ],
    );

Widget _screen(MovieList list, MovieListRepository repo) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieListScreen(list: list, repository: repo),
    );

/// The text field of the comment box at the bottom of a list.
Finder _commentField() => find.descendant(
      of: find.byKey(const Key('list-comment-composer')),
      matching: find.byType(TextField),
    );

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

FindRepository _search() => FindRepository(
      client: ApiClient(
        httpClient: MockClient((request) async => http.Response(
              jsonEncode({
                'page': 1,
                'total_pages': 1,
                'total_results': 2,
                'results': [
                  {'film_id': 'tt0113277', 'title': 'Heat', 'year': 1995},
                  {'film_id': 'tt0122690', 'title': 'Ronin', 'year': 1998},
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            )),
      ),
    );

void main() {
  testWidgets('My lists offers a new list and shows posted ones',
      (tester) async {
    final repo = FakeMovieListRepository(
      mine: [
        _list(1, 'Heist films',
            owner: const ListPerson(id: 1, username: 'me'), mine: true)
      ],
    );
    await tester.pumpWidget(_app(
      MovieListsSection(owner: MovieListsOwner.mine, repository: repo),
    ));
    await tester.pumpAndSettle();

    expect(find.text(_en.myListsTitle), findsOneWidget);
    expect(find.byKey(const Key('new-movie-list')), findsOneWidget);
    expect(find.text('Heist films'), findsOneWidget);
  });

  testWidgets('Friends\' lists hide until a friend posts one', (tester) async {
    await tester.pumpWidget(_app(MovieListsSection(
      owner: MovieListsOwner.friends,
      repository: FakeMovieListRepository(),
    )));
    await tester.pumpAndSettle();
    expect(find.text(_en.friendsListsTitle), findsNothing);

    await tester.pumpWidget(_app(MovieListsSection(
      key: const ValueKey('with-friends'),
      owner: MovieListsOwner.friends,
      repository: FakeMovieListRepository(friends: [_list(5, 'Ana picks')]),
    )));
    await tester.pumpAndSettle();
    expect(find.text(_en.friendsListsTitle), findsOneWidget);
    expect(find.text('Ana picks'), findsOneWidget);
  });

  testWidgets('making a list: name it, pick films, post it', (tester) async {
    final repo = FakeMovieListRepository();
    MovieList? posted;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              posted = await Navigator.of(context).push<MovieList>(
            MaterialPageRoute(
              builder: (_) =>
                  CreateMovieListScreen(repository: repo, find: _search()),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final post = find.byKey(const Key('list-post'));
    expect(tester.widget<FilledButton>(post).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('list-name')), 'Heist films');
    await tester.enterText(find.byKey(const Key('list-search')), 'heist');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('list-result-tt0113277')));
    await tester.tap(find.byKey(const Key('list-result-tt0122690')));
    await tester.pump();

    expect(find.text(_en.listPicked(2)), findsOneWidget);
    // Taking one back out.
    await tester.tap(find.byKey(const Key('list-picked-remove-tt0122690')));
    await tester.pump();
    expect(find.text(_en.listPicked(1)), findsOneWidget);

    await tester.tap(post);
    await tester.pumpAndSettle();

    expect(posted?.name, 'Heist films');
    expect(posted?.films.map((f) => f.title), ['Heat']);
    expect((await repo.fetchMine()).single.name, 'Heist films');
  });

  testWidgets('a friend\'s list can get a heart and a comment', (tester) async {
    final repo = FakeMovieListRepository(friends: [_list(5, 'Ana picks')]);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieListScreen(list: _list(5, 'Ana picks'), repository: repo),
    ));
    await tester.pumpAndSettle();

    expect(find.text(_en.listBy('ana')), findsOneWidget);
    expect(find.text('Heat'), findsOneWidget);
    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list-menu-delete')), findsNothing);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-heart')));
    await tester.pumpAndSettle();
    expect((await repo.fetchList(5)).liked, isTrue);
    expect(find.text('4'), findsOneWidget);

    // The comment box sits at the bottom, like on a topic.
    await tester.enterText(_commentField(), 'Great picks!');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();
    expect(find.text('Great picks!'), findsOneWidget);
    expect((await repo.fetchList(5)).comments, 2);
    expect(find.text(_en.topicCommentsHeading(1)), findsOneWidget);
  });

  testWidgets('the owner can heart their own list too', (tester) async {
    final me = const ListPerson(id: 1, username: 'me');
    final repo = FakeMovieListRepository(
        mine: [_list(1, 'Mine', owner: me, mine: true)]);
    await tester
        .pumpWidget(_screen(_list(1, 'Mine', owner: me, mine: true), repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-heart')));
    await tester.pumpAndSettle();
    expect((await repo.fetchList(1)).liked, isTrue);
    expect(find.byIcon(BootstrapIcons.heart_fill), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byKey(const Key('list-heart')));
    await tester.pumpAndSettle();
    expect((await repo.fetchList(1)).liked, isFalse);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets(
      'replying to a comment threads it under the comment, the owner marked as writer',
      (tester) async {
    final me = const ListPerson(id: 1, username: 'me');
    final repo = FakeMovieListRepository(
        mine: [_list(1, 'Mine', owner: me, mine: true)]);
    await tester
        .pumpWidget(_screen(_list(1, 'Mine', owner: me, mine: true), repo));
    await tester.pumpAndSettle();

    await tester.enterText(_commentField(), 'Why no Heat?');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();
    expect(find.byType(CommentThread), findsOneWidget);
    expect(find.text(_en.reviewWriterBadge.toUpperCase()), findsOneWidget);

    await tester.ensureVisible(find.text(_en.reviewReply));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.reviewReply));
    await tester.pumpAndSettle();
    expect(find.text(_en.reviewReplyingTo('me')), findsOneWidget);
    await tester.enterText(_commentField(), 'It is first!');
    await tester.tap(find.byTooltip(_en.reviewSend));
    await tester.pumpAndSettle();

    final comments = await repo.fetchComments(1);
    expect(comments.map((c) => c.body), ['Why no Heat?', 'It is first!']);
    expect(comments.last.parentId, comments.first.id);
    expect(find.text(_en.reviewReplyingTo('me')), findsNothing);
    expect(find.text(_en.topicCommentsHeading(2)), findsOneWidget);
  });

  testWidgets('the owner can delete their list', (tester) async {
    final me = const ListPerson(id: 1, username: 'me');
    final repo = FakeMovieListRepository(
        mine: [_list(1, 'Mine', owner: me, mine: true)]);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push<void>(MaterialPageRoute(
            builder: (_) => MovieListScreen(
                list: _list(1, 'Mine', owner: me, mine: true),
                repository: repo),
          )),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('list-menu-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('list-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.byType(MovieListScreen), findsNothing);
    expect(await repo.fetchMine(), isEmpty);
  });

  testWidgets(
      'on a long list a Comments button shows until the comments are on screen, then the box',
      (tester) async {
    final long = MovieList(
      id: 7,
      name: 'Everything',
      owner: _ana,
      isMine: false,
      filmCount: 30,
      likes: 0,
      comments: 0,
      films: [
        for (var i = 0; i < 30; i++)
          ListFilm(filmId: 'tt${1000000 + i}', title: 'Film $i'),
      ],
    );
    final repo = FakeMovieListRepository(friends: [long]);
    await tester.pumpWidget(_screen(long, repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list-comments-open')), findsOneWidget);
    expect(find.byKey(const Key('list-comment-composer')), findsNothing);

    await tester.tap(find.byKey(const Key('list-comments-open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list-comments-open')), findsNothing);
    expect(find.byKey(const Key('list-comment-composer')), findsOneWidget);
    expect(find.text(_en.listCommentsEmpty), findsOneWidget);
    // Sliding down shows the comments; it doesn't pop the keyboard up.
    expect(
        tester.widget<TextField>(_commentField()).focusNode?.hasFocus, isFalse);

    // Back at the top, the button comes back.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list-comments-open')), findsOneWidget);
  });

  testWidgets('the comment count up top focuses the comment box',
      (tester) async {
    final repo = FakeMovieListRepository(friends: [_list(5, 'Ana picks')]);
    await tester.pumpWidget(_screen(_list(5, 'Ana picks'), repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-comment-button')));
    await tester.pumpAndSettle();

    final input = tester.widget<TextField>(_commentField());
    expect(input.focusNode?.hasFocus, isTrue);
  });

  testWidgets(
      'someone else\'s list: the menu offers Share and Save, and a saved list shows under Saved lists',
      (tester) async {
    final repo = FakeMovieListRepository(friends: [_list(5, 'Ana picks')]);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieListScreen(list: _list(5, 'Ana picks'), repository: repo),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list-menu-share')), findsOneWidget);
    expect(find.byKey(const Key('list-menu-save')), findsOneWidget);
    expect(find.byKey(const Key('list-menu-edit')), findsNothing);
    expect(find.byKey(const Key('list-menu-delete')), findsNothing);

    await tester.tap(find.byKey(const Key('list-menu-save')));
    await tester.pumpAndSettle();
    expect((await repo.fetchList(5)).saved, isTrue);
    expect(find.text(_en.listSavedToast), findsOneWidget);

    // The menu now offers to take it back off.
    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('list-menu-save')),
        matching: find.byIcon(BootstrapIcons.bookmark_fill),
      ),
      findsOneWidget,
    );
    expect(find.text(_en.listUnsave), findsOneWidget);

    await tester.pumpWidget(_app(
      MovieListsSection(owner: MovieListsOwner.saved, repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text(_en.savedListsTitle), findsOneWidget);
    expect(find.text('Ana picks'), findsOneWidget);
  });

  testWidgets('Saved lists hide until you save one', (tester) async {
    final repo = FakeMovieListRepository(friends: [_list(5, 'Ana picks')]);
    await tester.pumpWidget(_app(
      MovieListsSection(owner: MovieListsOwner.saved, repository: repo),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved-lists')), findsNothing);
  });

  testWidgets(
      'your own list: the menu offers Share, Edit and Delete, and Edit renames it',
      (tester) async {
    const me = ListPerson(id: 1, username: 'me');
    final repo = FakeMovieListRepository(
        mine: [_list(1, 'Mine', owner: me, mine: true)]);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieListScreen(
          list: _list(1, 'Mine', owner: me, mine: true), repository: repo),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list-menu-share')), findsOneWidget);
    expect(find.byKey(const Key('list-menu-edit')), findsOneWidget);
    expect(find.byKey(const Key('list-menu-delete')), findsOneWidget);
    expect(find.byKey(const Key('list-menu-save')), findsNothing);

    await tester.tap(find.byKey(const Key('list-menu-edit')));
    await tester.pumpAndSettle();

    // The edit screen starts from the list as it is.
    expect(find.text(_en.listEditTitle), findsOneWidget);
    expect(find.text(_en.listPicked(2)), findsOneWidget);
    await tester.enterText(find.byKey(const Key('list-name')), 'Night drives');
    await tester.tap(find.byKey(const Key('list-post')));
    await tester.pumpAndSettle();

    expect(find.byType(CreateMovieListScreen), findsNothing);
    expect(find.text('Night drives'), findsOneWidget);
    expect((await repo.fetchMine()).single.name, 'Night drives');
  });

  testWidgets('Share in the menu sends the list to the friends you pick',
      (tester) async {
    const me = ListPerson(id: 1, username: 'me');
    final repo = FakeMovieListRepository(
        mine: [_list(1, 'Mine', owner: me, mine: true)]);
    final social = SocialRepository(
      client: ApiClient(
        httpClient: MockClient((request) async => http.Response(
              jsonEncode({
                'following': [],
                'followers': [],
                'friends': [
                  {'id': 2, 'username': 'ana'},
                  {'id': 3, 'username': 'bo'},
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            )),
      ),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MovieListScreen(
        list: _list(1, 'Mine', owner: me, mine: true),
        repository: repo,
        social: social,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('list-menu-share')));
    await tester.pumpAndSettle();

    expect(find.text(_en.takeShareTitle), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('share-list-friend-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share-list-send')));
    await tester.pumpAndSettle();

    expect(repo.shares[1], [2]);
    expect(find.text(_en.takeShareSent(1)), findsOneWidget);
  });
}
