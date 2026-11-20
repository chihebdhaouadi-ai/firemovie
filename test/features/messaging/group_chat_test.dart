import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_models.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_repository.dart';
import 'package:film_wise_mobile/features/messaging/views/chat_screen.dart';
import 'package:film_wise_mobile/features/messaging/views/group_info_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _me = ChatUser(id: 1, username: 'me');
const _ana = ChatUser(id: 2, username: 'ana');
const _ben = ChatUser(id: 3, username: 'ben');
final _t = DateTime.utc(2026, 11, 18, 22, 30);

ChatMessage _msg(int id, ChatUser sender, String body,
        {bool pinned = false, int minutes = 0}) =>
    ChatMessage(
      id: id,
      body: body,
      sender: sender,
      createdAt: _t.add(Duration(minutes: minutes)),
      pinned: pinned,
    );

Conversation _group({int? owner, bool heritage = false}) => Conversation(
      id: 7,
      kind: ConversationKind.group,
      title: 'scorsese gang',
      members: const [_me, _ana, _ben],
      updatedAt: _t,
      createdById: owner ?? _me.id,
      heritage: heritage,
    );

FakeMessagingRepository _repo({
  Conversation? group,
  List<ChatMessage>? messages,
}) =>
    FakeMessagingRepository(
      me: _me,
      conversations: [group ?? _group()],
      messages: {
        7: messages ??
            [
              _msg(1, _me, 'yoo'),
              _msg(2, _ana, 'waaaaawa', minutes: 7),
              _msg(3, _ana, 'je suis laaa', minutes: 7),
              _msg(4, _ben, 'hey @me', minutes: 8),
            ],
      },
    );

Future<void> _pumpChat(
  WidgetTester tester,
  FakeMessagingRepository repo, {
  Conversation? group,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChatScreen(
      conversation: group ?? _group(),
      repository: repo,
      meId: _me.id,
      searchMovies: (query) async => [
        const SharedMovie(id: '769', title: 'Goodfellas', year: '1990'),
      ],
    ),
  ));
  await tester.pumpAndSettle();
}

/// Stops the chat's polling timer before a test ends.
Future<void> _done(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('messages from one person are grouped under one header',
      (tester) async {
    await _pumpChat(tester, _repo());
    // ana wrote twice in a row: her name shows once.
    expect(find.text('ana'), findsOneWidget);
    expect(find.text('waaaaawa'), findsOneWidget);
    expect(find.text('je suis laaa'), findsOneWidget);
    await _done(tester);
  });

  testWidgets('holding a message reacts, and the chip toggles it back',
      (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo);
    await tester.longPress(find.text('waaaaawa'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-reactions')), findsOneWidget);
    expect(find.byKey(const Key('hold-pin')), findsOneWidget,
        reason: 'the owner may pin');
    await tester.tap(find.byKey(const Key('hold-react-😂')));
    await tester.pumpAndSettle();
    expect(find.text('😂 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reaction-2-😂')));
    await tester.pumpAndSettle();
    expect(find.text('😂 1'), findsNothing);
    await _done(tester);
  });

  testWidgets('reply quotes the message and pin adds the pinned bar',
      (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo);
    await tester.longPress(find.text('yoo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hold-reply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reply-bar')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('chat-composer')), 'same');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reply-quote-1')), findsOneWidget);

    await tester.longPress(find.text('yoo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hold-pin')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pinned-bar')), findsOneWidget);
    await _done(tester);
  });

  testWidgets('a regular member cannot pin', (tester) async {
    await _pumpChat(tester, _repo(group: _group(owner: _ana.id)),
        group: _group(owner: _ana.id));
    await tester.longPress(find.text('waaaaawa'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-pin')), findsNothing);
    expect(find.byKey(const Key('hold-mention')), findsOneWidget);
    await _done(tester);
  });

  testWidgets('typing @ suggests members; sending says who was notified',
      (tester) async {
    await _pumpChat(tester, _repo());
    await tester.enterText(find.byKey(const Key('chat-composer')), 'hi @a');
    await tester.pump();
    expect(find.byKey(const Key('mention-box')), findsOneWidget);
    expect(find.byKey(const Key('mention-2')), findsOneWidget);
    expect(find.byKey(const Key('mention-3')), findsNothing);
    await tester.tap(find.byKey(const Key('mention-2')));
    await tester.pump();
    expect(find.byKey(const Key('mention-box')), findsNothing);
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pump();
    expect(find.text('Notified ana'), findsOneWidget);
    await tester.pumpAndSettle();
    await _done(tester);
  });

  testWidgets('the smiley panel adds emoji and sends GIFs and stickers',
      (tester) async {
    await _pumpChat(tester, _repo(messages: const []));
    await tester.tap(find.byKey(const Key('chat-emoji')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('emoji-panel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('emoji-😂')).first);
    await tester.pump();
    expect(find.text('😂'), findsWidgets);

    // GIF tiles bob forever, so the panel never settles: pump in steps.
    await tester.tap(find.byKey(const Key('panel-tab-gif')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('gif-applause')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('GIF applause'), findsOneWidget);
    expect(find.byKey(const Key('emoji-panel')), findsNothing);
    await _done(tester);
  });

  testWidgets('a poll is created from + and voting toggles', (tester) async {
    await _pumpChat(tester, _repo(messages: const []));
    await tester.tap(find.byKey(const Key('chat-attach')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('attach-poll')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-send')));
    await tester.pumpAndSettle();
    expect(
        find.text('Add a question and at least two options'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('poll-question')), 'Friday?');
    await tester.enterText(find.byKey(const Key('poll-option-field-0')), 'Yes');
    await tester.enterText(find.byKey(const Key('poll-option-field-1')), 'No');
    // Only the fire reaction allowed on this post.
    for (final e in ['👍', '❤️', '😂', '😮']) {
      await tester.tap(find.byKey(Key('allow-$e')));
    }
    await tester.tap(find.byKey(const Key('post-send')));
    await tester.pumpAndSettle();
    expect(find.text('Friday?'), findsOneWidget);
    expect(find.text('0 votes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('poll-option-0')));
    await tester.pumpAndSettle();
    expect(find.text('1 vote'), findsOneWidget);
    await tester.tap(find.byKey(const Key('poll-option-0')));
    await tester.pumpAndSettle();
    expect(find.text('0 votes'), findsOneWidget);

    await tester.longPress(find.text('Friday?'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-react-🔥')), findsOneWidget);
    expect(find.byKey(const Key('hold-react-👍')), findsNothing);
    expect(find.byKey(const Key('hold-more')), findsNothing);
    await _done(tester);
  });

  testWidgets('a movie is searched and shared as a card', (tester) async {
    await _pumpChat(tester, _repo(messages: const []));
    await tester.tap(find.byKey(const Key('chat-attach')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('attach-movie')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('movie-search-field')), 'good');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('movie-result-769')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('post-caption')), 'Friday movie night?');
    await tester.tap(find.byKey(const Key('post-send')));
    await tester.pumpAndSettle();
    expect(find.text('Goodfellas'), findsOneWidget);
    expect(find.text('Friday movie night?'), findsOneWidget);
    await _done(tester);
  });

  testWidgets('a video loads on its own and says when it cannot play',
      (tester) async {
    final video = ChatMessage(
      id: 9,
      kind: MessageKind.video,
      body: 'trailer',
      sender: _ana,
      createdAt: _t,
      attachmentUrl: 'fake://clip.mp4',
    );
    await _pumpChat(tester, _repo(messages: [video]));
    // It tries to load at once (for its first frame), without a tap.
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat-video-start')), findsOneWidget);
    expect(find.text("Couldn't play this video."), findsOneWidget);
    await _done(tester);
  });

  testWidgets('a regular member leaves after typing the group name',
      (tester) async {
    final repo = _repo(group: _group(owner: _ana.id));
    await _pumpChat(tester, repo, group: _group(owner: _ana.id));
    await tester.tap(find.byKey(const Key('chat-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-menu-leave')));
    await tester.pumpAndSettle();
    final confirm = find.byKey(const Key('confirm-type-button'));
    expect(
        tester
            .widget<Opacity>(find
                .ancestor(
                    of: find.text('Leave group').last,
                    matching: find.byType(Opacity))
                .first)
            .opacity,
        lessThan(1));
    await tester.enterText(
        find.byKey(const Key('confirm-type-field')), 'scorsese gang');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(await repo.conversations(), isEmpty);
    await _done(tester);
  });

  testWidgets('the creator starts the group vote and sees the keep card',
      (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo);
    await tester.tap(find.byKey(const Key('chat-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-menu-leave')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('leave-pass')), findsOneWidget);
    await tester.tap(find.byKey(const Key('leave-vote')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('confirm-type-field')), 'Scorsese Gang');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm-type-button')));
    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('keep-vote-card')), findsOneWidget);
    expect(find.text("You can't vote on your own poll."), findsOneWidget);
    expect(
        find.text('You started a vote on keeping this group'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vote-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('keep-vote-card')), findsNothing);
    await _done(tester);
  });

  testWidgets('members vote for a new owner on the owner card', (tester) async {
    final running = _group(owner: _ben.id).withVote(GroupVoteState(
      stage: GroupVoteStage.owner,
      startedById: _ben.id,
      endsAt: DateTime.now().add(const Duration(hours: 23)),
      tally: const {'2': 1},
    ));
    final repo = _repo(group: running, messages: const []);
    await _pumpChat(tester, repo, group: running);
    expect(find.byKey(const Key('owner-vote-card')), findsOneWidget);
    expect(find.byKey(const Key('candidate-3')), findsNothing,
        reason: 'the member who asked to leave is not a candidate');
    await tester.tap(find.byKey(const Key('candidate-2')));
    await tester.pumpAndSettle();
    expect(find.text('2 votes'), findsOneWidget);
    expect(find.text('You can change your vote until the poll ends.'),
        findsOneWidget);
    await _done(tester);
  });

  testWidgets('the owner removes a member from group info', (tester) async {
    final repo = _repo();
    Conversation? changed;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GroupInfoScreen(
        conversation: _group(),
        meId: _me.id,
        repository: repo,
        onChanged: (c) => changed = c,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('group-member-search')), 'zz');
    await tester.pump();
    expect(find.text('No members match “zz”.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('group-member-search')), 'be');
    await tester.pump();
    expect(find.byKey(const Key('group-member-2')), findsNothing);

    await tester.tap(find.byKey(const Key('group-member-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('member-remove')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('confirm-type-field')), 'scorsese gang');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm-type-button')));
    await tester.pumpAndSettle();
    expect(changed?.members.map((m) => m.id), [1, 2]);
    expect(find.byKey(const Key('group-member-3')), findsNothing);
  });

  testWidgets('group info marks a Heritage creator', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GroupInfoScreen(
        conversation: _group(owner: _ana.id, heritage: true),
        meId: _me.id,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Heritage creator'), findsOneWidget);
    expect(find.text('Creator'), findsNothing);
  });
}
