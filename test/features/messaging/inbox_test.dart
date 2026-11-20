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
final _t = DateTime.utc(2026, 11, 17, 12);

ChatMessage _msg(int id, ChatUser sender, String body) => ChatMessage(
    id: id,
    body: body,
    sender: sender,
    createdAt: _t.add(Duration(minutes: id)));

FakeMessagingRepository _repo() => FakeMessagingRepository(
      me: _me,
      conversations: [
        Conversation(
          id: 10,
          kind: ConversationKind.direct,
          title: 'ana',
          members: const [_me, _ana],
          lastMessage: _msg(1, _ana, 'Seen Heat yet?'),
          unread: 2,
          updatedAt: _t.add(const Duration(minutes: 1)),
        ),
        Conversation(
          id: 11,
          kind: ConversationKind.group,
          title: 'Film club',
          members: const [_me, _ana, _ben],
          lastMessage: _msg(2, _me, 'see you at 6'),
          updatedAt: _t,
        ),
        Conversation(
          id: 12,
          kind: ConversationKind.topic,
          title: 'Noir night',
          members: const [_me, _ben],
          unread: 1,
          updatedAt: _t,
        ),
      ],
      messages: {
        10: [_msg(1, _ana, 'Seen Heat yet?'), _msg(3, _me, 'Not yet')],
      },
    );

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Future<void> _pumpInbox(WidgetTester tester, MessagingRepository repo,
    {ValueChanged<int>? onUnread}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(InboxTab(
    exitInset: (_) => 0,
    repository: repo,
    meId: _me.id,
    onUnreadChanged: onUnread,
  )));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  testWidgets('lists chats with previews, keeps topics in their card',
      (tester) async {
    int? unread;
    await _pumpInbox(tester, _repo(), onUnread: (n) => unread = n);

    expect(find.text('Seen Heat yet?'), findsOneWidget);
    expect(find.text('You: see you at 6'), findsOneWidget);
    expect(find.text('Private topics'), findsOneWidget);
    // The topic is only in the card, not the list.
    expect(find.byKey(const ValueKey('conversation-12')), findsNothing);
    expect(unread, 3);
  });

  testWidgets('the rail shows groups and folds away when hidden',
      (tester) async {
    final groups = (await _repo().conversations())
        .where((c) => c.kind == ConversationKind.group)
        .toList();
    Conversation? opened;
    Widget rail(bool visible) => MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Row(children: [
              GroupRail(
                visible: visible,
                groups: groups,
                onOpen: (c) => opened = c,
                onAll: () {},
              ),
              const Expanded(child: SizedBox()),
            ]),
          ),
        );

    await tester.pumpWidget(rail(true));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(GroupRail)).width, greaterThan(40));
    await tester.tap(find.byKey(const Key('rail-group-11')));
    expect(opened?.id, 11);

    await tester.pumpWidget(rail(false));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(GroupRail)).width, 0);
  });

  testWidgets('the unread filter and search narrow the list', (tester) async {
    await _pumpInbox(tester, _repo());

    await tester.tap(find.byKey(const Key('inbox-unread')));
    await tester.pump();
    expect(find.byKey(const ValueKey('conversation-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-11')), findsNothing);

    await tester.tap(find.byKey(const Key('inbox-unread')));
    await tester.tap(find.byKey(const Key('inbox-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('inbox-search-field')), 'club');
    await tester.pump();
    expect(find.byKey(const ValueKey('conversation-11')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-10')), findsNothing);
  });

  testWidgets('with a controller the action row is pinned outside the list',
      (tester) async {
    final controller = InboxActionsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: InboxPinnedActions(controller: controller),
          ),
          SliverToBoxAdapter(
            child: InboxTab(
              exitInset: (_) => 0,
              repository: _repo(),
              meId: _me.id,
              actionsController: controller,
            ),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    final search = find.byKey(const Key('inbox-search'));
    expect(search, findsOneWidget);
    expect(find.descendant(of: find.byType(InboxTab), matching: search),
        findsNothing);
    expect(tester.getSize(search).height, inboxActionsHeight);

    // The pinned row still drives the inbox's filters.
    await tester.tap(find.byKey(const Key('inbox-unread')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('conversation-11')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the pinned row stays on top and shrinks as chats scroll',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = InboxActionsController();
    addTearDown(controller.dispose);
    final repo = FakeMessagingRepository(me: _me, conversations: [
      for (var i = 0; i < 25; i++)
        Conversation(
          id: 100 + i,
          kind: ConversationKind.direct,
          title: 'friend $i',
          members: const [_me, _ana],
          updatedAt: _t.subtract(Duration(minutes: i)),
        ),
    ]);
    final bar = InboxActionsBarDelegate(
      controller: controller,
      verticalPadding: 8,
      horizontalPadding: 16,
      background: Colors.black,
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomScrollView(slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: bar,
          ),
          SliverToBoxAdapter(
            child: InboxTab(
              exitInset: (_) => 0,
              repository: repo,
              meId: _me.id,
              actionsController: controller,
            ),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    final barBox = find.byKey(const Key('inbox-actions-bar'));
    final search = find.byKey(const Key('inbox-search'));
    expect(tester.getSize(barBox).height, bar.maxExtent);
    expect(tester.getSize(search).height, inboxActionsHeight);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // Still at the top, a little smaller, and the chats pass beneath it.
    expect(tester.getTopLeft(barBox).dy, 0);
    expect(tester.getSize(barBox).height, bar.maxExtent);
    expect(tester.getSize(search).height,
        closeTo(inboxActionsHeight * InboxActionsBarDelegate.minScale, 0.01));
    final firstChat = find.byKey(const ValueKey('conversation-100'));
    expect(tester.getBottomLeft(firstChat).dy,
        lessThan(tester.getBottomLeft(barBox).dy));

    // Back at the top it is full size again.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(tester.getSize(search).height, inboxActionsHeight);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a wide window shows the chat beside the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(InboxTab(
      exitInset: (_) => 0,
      repository: _repo(),
      meId: _me.id,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byKey(const Key('chat-pane-empty')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('conversation-10')));
    await tester.pump();
    await tester.pump();

    // The chat opened in the pane, not as a new page.
    expect(find.byKey(const ValueKey('chat-pane-10')), findsOneWidget);
    expect(find.text('Not yet'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the chat shows messages and sends a new one', (tester) async {
    final repo = _repo();
    final convo = (await repo.conversations()).firstWhere((c) => c.id == 10);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatScreen(conversation: convo, repository: repo, meId: _me.id),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Seen Heat yet?'), findsOneWidget);
    expect(find.text('Not yet'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('chat-composer')), '  Tonight?  ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump();

    expect(find.text('Tonight?'), findsOneWidget);
    final sent = await repo.messages(10);
    expect(sent.last.body, 'Tonight?');

    // Stop the polling timer before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
