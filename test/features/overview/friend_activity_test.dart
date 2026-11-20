import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/avatar_frame.dart';
import 'package:film_wise_mobile/features/overview/data/friend_story_seen_store.dart';
import 'package:film_wise_mobile/features/overview/views/widgets/friend_activity.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../film_reviews/review_test_support.dart';

const _updatedAt = '2026-11-16T12:00:00Z';

Map<String, Object?> _friend(
  int id,
  String name, {
  String reaction = 'loved',
  bool take = true,
}) =>
    {
      'user': {
        'id': id,
        'username': name,
        'avatar': null,
        'equipped_frame': 'gold',
      },
      'reaction': reaction,
      'take': take ? {'id': id, 'body': 'Great'} : null,
      'updated_at': _updatedAt,
    };

Future<void> _pump(
  WidgetTester tester,
  FriendStorySeenStore store, {
  List<Map<String, Object?>>? friends,
}) async {
  final api = ReviewApi(
    friends: friends ?? [_friend(1, 'ana'), _friend(2, 'leo')],
    takes: [takeJson(id: 1), takeJson(id: 2)],
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Friends' typing bubbles loop; reduced motion keeps them still so
      // pumpAndSettle can finish.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: FriendActivity(
          movieId: 'tt1',
          repository: reviewRepositoryFor(api.client),
          seenStore: store,
          embedded: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _en = lookupAppLocalizations(const Locale('en'));

void main() {
  testWidgets('friends show as stories, new until opened', (tester) async {
    final store = FakeFriendStorySeenStore();
    await _pump(tester, store);

    expect(find.byType(FriendStory), findsNWidgets(2));
    // Each friend wears their own frame.
    expect(
      tester
          .widgetList<AvatarFrame>(find.byType(AvatarFrame))
          .map((a) => a.frame),
      ['gold', 'gold'],
    );
    expect(find.text('ana'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        _en.overviewFriendStoryNew('ana', _en.reviewReactionLoved),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('ana'));
    await tester.pumpAndSettle();

    final key = friendStoryKey('tt1', 1, DateTime.parse(_updatedAt));
    expect(store.seen, {key});
  });

  testWidgets('an opened friend shows as seen next time', (tester) async {
    final key = friendStoryKey('tt1', 2, DateTime.parse(_updatedAt));
    await _pump(tester, FakeFriendStorySeenStore({key}));

    final stories = tester.widgetList<FriendStory>(find.byType(FriendStory));
    expect(
      {for (final story in stories) story.friend.username: story.seen},
      {'ana': false, 'leo': true},
    );
  });

  testWidgets('a friend with several feelings gets one bubble with all of them',
      (tester) async {
    await _pump(
      tester,
      FakeFriendStorySeenStore(),
      friends: [
        _friend(1, 'ana'),
        _friend(1, 'ana', reaction: 'made_cry'),
        _friend(1, 'ana', reaction: 'masterpiece'),
        _friend(2, 'leo'),
      ],
    );

    expect(find.byType(FriendStory), findsNWidgets(2));
    expect(find.text('ana'), findsOneWidget);
    final feelings = [
      _en.reviewReactionLoved,
      _en.reviewReactionMadeCry,
      _en.reviewReactionMasterpiece,
    ].join(', ');
    expect(
      find.bySemanticsLabel(_en.overviewFriendStoryNew('ana', feelings)),
      findsOneWidget,
    );
  });

  testWidgets('only friends who shared a take are new, with a typing bubble',
      (tester) async {
    await _pump(
      tester,
      FakeFriendStorySeenStore(),
      friends: [_friend(1, 'ana'), _friend(2, 'leo', take: false)],
    );
    final loved = _en.reviewReactionLoved;

    expect(
      find.bySemanticsLabel(_en.overviewFriendStoryNew('ana', loved)),
      findsOneWidget,
    );
    // Feelings only: no blue ring to open, no typing bubble.
    expect(
      find.bySemanticsLabel(_en.overviewFriendStorySeen('leo', loved)),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('friend-typing-badge')), findsOneWidget);
  });
}
