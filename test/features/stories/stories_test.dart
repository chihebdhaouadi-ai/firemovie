import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/stories/data/friend_story.dart';
import 'package:film_wise_mobile/features/stories/data/story_repository.dart';
import 'package:film_wise_mobile/features/stories/views/story_circles.dart';
import 'package:film_wise_mobile/features/stories/views/story_viewer_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime.utc(2026, 11, 17, 12);

StoryItem _item(int id, {StoryKind kind = StoryKind.take, TakeTag tag = TakeTag.review}) =>
    StoryItem(
      kind: kind,
      id: id,
      takeId: 100 + id,
      tag: tag,
      body: 'Body $id',
      createdAt: _now.add(Duration(minutes: id)),
      filmTitle: 'Dune',
    );

final _ana = FriendStory(
  userId: 1,
  username: 'ana',
  items: [_item(1), _item(2, kind: StoryKind.comment)],
);
final _ben = FriendStory(
  userId: 2,
  username: 'ben',
  items: [_item(3, tag: TakeTag.question)],
);

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  test('parses a story group from the API', () {
    final story = FriendStory.fromJson({
      'user': {'id': 7, 'username': 'zoe', 'avatar': null, 'equipped_frame': null},
      'latest_at': '2026-11-17T12:05:00Z',
      'items': [
        {
          'kind': 'comment',
          'id': 3,
          'take_id': 9,
          'tag': 'hot_take',
          'body': 'Agreed',
          'spoiler': true,
          'film': {'film_id': 'tt1', 'title': 'Dune', 'poster_url': null},
          'created_at': '2026-11-17T12:05:00Z',
        },
      ],
    });
    expect(story.username, 'zoe');
    final item = story.items.single;
    expect(item.kind, StoryKind.comment);
    expect(item.takeId, 9);
    expect(item.tag, TakeTag.hotTake);
    expect(item.spoiler, isTrue);
    expect(story.latestAt, DateTime.utc(2026, 11, 17, 12, 5));
  });

  test('a story stays seen until the friend makes something new', () async {
    SharedPreferences.setMockInitialValues({});
    final seen = SeenStories();
    await seen.load([1]);
    expect(seen.isSeen(_ana), isFalse);
    await seen.markSeen(_ana);
    expect(seen.isSeen(_ana), isTrue);

    final again = SeenStories();
    await again.load([1]);
    expect(again.isSeen(_ana), isTrue, reason: 'remembered on the device');

    final newer = FriendStory(
      userId: 1,
      username: 'ana',
      items: [..._ana.items, _item(9)],
    );
    expect(again.isSeen(newer), isFalse);
  });

  testWidgets('the strip shows a circle per friend and opens the tapped one',
      (tester) async {
    int? opened;
    await tester.pumpWidget(_app(StoryStrip(
      stories: [_ana, _ben],
      isSeen: (_) => false,
      onOpen: (index) => opened = index,
      collapse: 0,
    )));

    expect(find.text('ana'), findsOneWidget);
    expect(find.text('ben'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-2')));
    expect(opened, 1);
  });

  testWidgets('the collapsed stack opens the first story not yet watched',
      (tester) async {
    int? opened;
    await tester.pumpWidget(_app(StoryStack(
      stories: [_ana, _ben],
      isSeen: (story) => story.userId == 1,
      onOpen: (index) => opened = index,
    )));

    await tester.tap(find.byKey(const Key('story-stack')));
    expect(opened, 1);
  });

  testWidgets('the viewer plays items in order and reports a watched story',
      (tester) async {
    final watched = <int>[];
    StoryItem? openedItem;
    await tester.pumpWidget(_app(StoryViewerScreen(
      stories: [_ana],
      initialIndex: 0,
      onOpenItem: (item) async => openedItem = item,
      onWatched: (story) => watched.add(story.userId),
    )));
    await tester.pump();

    expect(find.text('Shared a take on Dune'), findsOneWidget);
    expect(watched, isEmpty);

    // The first item times out and the comment plays next.
    await tester.pump(storyItemDuration + const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Commented on a post about Dune'), findsOneWidget);
    expect(watched, [1]);

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(openedItem?.takeId, 102);
  });

  testWidgets('a one-item story that redraws the page behind it on watch '
      'opens without a build error', (tester) async {
    final watched = <int>[];
    await tester.pumpWidget(_app(StatefulBuilder(
      builder: (context, setState) => StoryViewerScreen(
        stories: [_ben],
        initialIndex: 0,
        onOpenItem: (_) async {},
        // Like the home screen: watching marks the story seen and redraws.
        onWatched: (story) => setState(() => watched.add(story.userId)),
      ),
    )));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(watched, [2]);
  });
}
