import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_models.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_repository.dart';
import 'package:film_wise_mobile/features/messaging/views/chat_screen.dart';
import 'package:film_wise_mobile/features/messaging/views/inbox_tab.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _me = ChatUser(id: 1, username: 'me');
const _ana = ChatUser(id: 2, username: 'ana');
const _ben = ChatUser(id: 3, username: 'ben');
final _t = DateTime.utc(2026, 11, 19, 12);

ChatMessage _msg(int id, ChatUser sender, String body) => ChatMessage(
      id: id,
      body: body,
      sender: sender,
      createdAt: _t.add(Duration(minutes: id)),
    );

Conversation _direct({ChatBlock block = ChatBlock.none, DateTime? seenAt}) =>
    Conversation(
      id: 10,
      kind: ConversationKind.direct,
      title: 'ana',
      members: const [_me, _ana],
      lastMessage: _msg(2, _me, 'see you'),
      unread: 2,
      updatedAt: _t.add(const Duration(minutes: 2)),
      block: block,
      seenAt: seenAt,
    );

Conversation _group() => Conversation(
      id: 11,
      kind: ConversationKind.group,
      title: 'Film club',
      members: const [_me, _ana],
      updatedAt: _t,
      createdById: _me.id,
    );

FakeMessagingRepository _repo({Conversation? direct}) =>
    FakeMessagingRepository(
      me: _me,
      conversations: [direct ?? _direct(), _group()],
      messages: {
        10: [_msg(1, _ana, 'hey'), _msg(2, _me, 'see you')],
        11: [_msg(3, _ana, 'spam spam')],
      },
    );

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Future<void> _pumpChat(
  WidgetTester tester,
  FakeMessagingRepository repo,
  Conversation convo, {
  Future<List<ChatUser>> Function()? loadFriends,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(ChatScreen(
    conversation: convo,
    repository: repo,
    meId: _me.id,
    loadFriends: loadFriends,
  )));
  await tester.pumpAndSettle();
}

Future<void> _pumpInbox(WidgetTester tester, FakeMessagingRepository repo,
    {ValueChanged<int>? onUnread}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(Scaffold(
    body: SingleChildScrollView(
      child: InboxTab(
        exitInset: (_) => 0,
        repository: repo,
        meId: _me.id,
        onUnreadChanged: onUnread,
      ),
    ),
  )));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Stops the polling timers before a test ends.
Future<void> _done(WidgetTester tester) => tester.pumpWidget(const SizedBox());

Future<void> _menu(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(const Key('chat-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('chat-menu-$item')));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('confirm-action')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('holding a chat in the inbox pins and mutes it', (tester) async {
    int? unread;
    final repo = _repo();
    await _pumpInbox(tester, repo, onUnread: (n) => unread = n);
    expect(unread, 2);

    await tester.longPress(find.byKey(const ValueKey('conversation-10')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-option-mute')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-muted')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(unread, 0, reason: 'muted chats leave the unread badge');

    await tester.longPress(find.byKey(const ValueKey('conversation-11')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-option-pin')));
    await tester.pumpAndSettle();
    expect((await repo.conversations()).first.id, 11,
        reason: 'a pinned chat comes first');
    expect(find.byKey(const Key('conversation-pinned')), findsOneWidget);
    await _done(tester);
  });

  testWidgets('a chat can be marked unread and deleted from the inbox',
      (tester) async {
    final repo = _repo();
    await _pumpInbox(tester, repo);
    await tester.longPress(find.byKey(const ValueKey('conversation-11')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat-option-delete')), findsNothing,
        reason: 'groups are left, not deleted');
    await tester.tap(find.byKey(const Key('chat-option-unread')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conversation-marked-unread')), findsOneWidget);

    await tester.longPress(find.byKey(const ValueKey('conversation-10')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-option-delete')));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(find.byKey(const ValueKey('conversation-10')), findsNothing);
    expect((await repo.conversations()).map((c) => c.id), [11]);
    await _done(tester);
  });

  testWidgets(
      'blocking swaps the composer for a banner, unblock brings it back',
      (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo, _direct());
    await _menu(tester, 'block');
    await _confirm(tester);
    expect(find.byKey(const Key('chat-blocked-banner')), findsOneWidget);
    expect(find.byKey(const Key('chat-composer')), findsNothing);
    expect(await repo.blockedUsers(), [_ana]);

    // Let the "ana is blocked" snack bar go away first.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-unblock')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat-composer')), findsOneWidget);
    expect(await repo.blockedUsers(), isEmpty);
    await _done(tester);
  });

  testWidgets('blocked by the friend: no composer and no unblock button',
      (tester) async {
    await _pumpChat(tester, _repo(direct: _direct(block: ChatBlock.byThem)),
        _direct(block: ChatBlock.byThem));
    expect(find.text("You can't reply to this conversation."), findsOneWidget);
    expect(find.byKey(const Key('chat-unblock')), findsNothing);
    await _done(tester);
  });

  testWidgets('my message can be edited and deleted', (tester) async {
    await _pumpChat(tester, _repo(), _direct());
    await tester.longPress(find.text('see you'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-report')), findsNothing,
        reason: 'my own message is not reported');
    await tester.tap(find.byKey(const Key('hold-edit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('edit-bar')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('chat-composer')), 'see you!');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    expect(find.text('see you!'), findsOneWidget);
    expect(find.byKey(const Key('message-edited-2')), findsOneWidget);

    await tester.longPress(find.text('see you!'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hold-delete')));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(find.byKey(const Key('message-deleted-2')), findsOneWidget);
    expect(find.text('see you!'), findsNothing);
    await _done(tester);
  });

  testWidgets("someone else's message is reported, not edited", (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo, _direct());
    await tester.longPress(find.text('hey'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hold-edit')), findsNothing);
    expect(find.byKey(const Key('hold-delete')), findsNothing);
    expect(find.byKey(const Key('hold-copy')), findsOneWidget);
    await tester.tap(find.byKey(const Key('hold-report')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-spam')));
    await tester.pumpAndSettle();
    expect(repo.reports, [(10, 'spam', 1)]);
    await _done(tester);
  });

  testWidgets('clear history empties the chat for me', (tester) async {
    await _pumpChat(tester, _repo(), _direct());
    await _menu(tester, 'clear');
    await _confirm(tester);
    expect(find.text('hey'), findsNothing);
    expect(find.text('see you'), findsNothing);
    await _done(tester);
  });

  testWidgets('"Seen" shows once the friend read my last message',
      (tester) async {
    await _pumpChat(
        tester,
        _repo(direct: _direct(seenAt: _t.add(const Duration(minutes: 5)))),
        _direct(seenAt: _t.add(const Duration(minutes: 5))));
    expect(find.byKey(const Key('chat-seen')), findsOneWidget);
    await _done(tester);
  });

  testWidgets('the group owner deletes any message and adds members',
      (tester) async {
    final repo = _repo();
    await _pumpChat(tester, repo, _group(),
        loadFriends: () async => const [_ana, _ben]);
    await tester.longPress(find.text('spam spam'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hold-delete')));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(find.byKey(const Key('message-deleted-3')), findsOneWidget);

    await _menu(tester, 'add');
    // Ana is already in the group, so only Ben is offered.
    expect(find.byKey(const Key('add-member-2')), findsNothing);
    await tester.tap(find.byKey(const Key('add-member-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-members-confirm')));
    await tester.pumpAndSettle();
    final group = await repo.conversation(11);
    expect(group.members.map((m) => m.id), containsAll([1, 2, 3]));
    await _done(tester);
  });
}
