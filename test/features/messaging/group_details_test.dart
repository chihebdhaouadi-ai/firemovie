import 'dart:typed_data';

import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_models.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_repository.dart';
import 'package:film_wise_mobile/features/messaging/views/chat_screen.dart';
import 'package:film_wise_mobile/features/messaging/views/group_info_screen.dart';
import 'package:film_wise_mobile/features/messaging/views/inbox_sheets.dart';
import 'package:film_wise_mobile/features/messaging/views/inbox_tab.dart';
import 'package:film_wise_mobile/features/social/data/social_models.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

const _me = ChatUser(id: 1, username: 'me');
const _ana = ChatUser(id: 2, username: 'ana');
const _ben = ChatUser(id: 3, username: 'ben');
final _t = DateTime.utc(2026, 11, 18, 12);

// A 1x1 PNG, so the sheet can preview the picked photo.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Conversation _group({String description = ''}) => Conversation(
      id: 11,
      kind: ConversationKind.group,
      title: 'Heist club',
      members: const [_ben, _me, _ana],
      updatedAt: _t,
      description: description,
      createdById: _ana.id,
    );

void main() {
  testWidgets('the new group sheet returns name, description, friends, photo',
      (tester) async {
    NewChatChoice? choice;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            choice = await pickGroup(
              context,
              kind: ConversationKind.group,
              friends: const [
                SocialUser(id: 2, username: 'ana'),
                SocialUser(id: 3, username: 'ben'),
              ],
              pickPhoto: () async => XFile.fromData(_png,
                  name: 'group.png', path: 'group.png', mimeType: 'image/png'),
            );
          },
          child: const Text('open'),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final create = find.byKey(const Key('new-chat-create'));
    expect(tester.widget<FilledButton>(create).onPressed, isNull,
        reason: 'a group needs a name');

    await tester.tap(find.byKey(const Key('new-chat-photo')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('new-chat-name')), ' Heist club ');
    await tester.enterText(
        find.byKey(const Key('new-chat-description')), ' Only heist films. ');
    await tester.tap(find.byKey(const Key('group-friend-3')));
    await tester.pump();
    expect(find.text('Choose friends · 1'), findsOneWidget);

    await tester.tap(create);
    await tester.pumpAndSettle();

    expect(choice, isNotNull);
    expect(choice!.title, 'Heist club');
    expect(choice!.description, 'Only heist films.');
    expect(choice!.memberIds, [3]);
    expect(choice!.photo?.name, 'group.png');
  });

  test('the fake repository keeps the description and photo', () async {
    final repo = FakeMessagingRepository(me: _me);
    final created = await repo.create(
      kind: ConversationKind.group,
      title: 'Heist club',
      memberIds: const [2],
      description: 'Only heist films.',
    );
    expect(created.description, 'Only heist films.');
    expect(created.createdById, _me.id);
    final withPhoto = await repo.setPhoto(
        created.id, XFile.fromData(_png, name: 'group.png'));
    expect(withPhoto.photoUrl, isNotNull);
    expect((await repo.conversations()).single.photoUrl, withPhoto.photoUrl);
  });

  test('a conversation reads description, photo and creator from json', () {
    final convo = Conversation.fromJson({
      'id': 5,
      'kind': 'group',
      'title': 'Heist club',
      'description': 'Only heist films.',
      'photo': 'http://x/media/conversation_photos/a.png',
      'created_by': 2,
      'members': const [],
      'unread': 0,
      'updated_at': '2026-11-18T12:00:00Z',
    });
    expect(convo.description, 'Only heist films.');
    expect(convo.photoUrl, 'http://x/media/conversation_photos/a.png');
    expect(convo.createdById, 2);
  });

  testWidgets('tapping a group name opens its info page', (tester) async {
    final repo = FakeMessagingRepository(
        me: _me, conversations: [_group(description: 'Only heist films.')]);
    await tester.pumpWidget(_app(
      ChatScreen(
          conversation: _group(description: 'Only heist films.'),
          repository: repo,
          meId: _me.id),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('chat-open-info')));
    await tester.pumpAndSettle();

    expect(find.byType(GroupInfoScreen), findsOneWidget);
    expect(find.byKey(const Key('group-info-title')), findsOneWidget);
    expect(find.text('Only heist films.'), findsOneWidget);
    expect(find.text('Members · 3'), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);

    // Stop the chat's polling timer before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a direct chat has no info page', (tester) async {
    final direct = Conversation(
      id: 10,
      kind: ConversationKind.direct,
      title: 'ana',
      members: const [_me, _ana],
      updatedAt: _t,
    );
    final repo = FakeMessagingRepository(me: _me, conversations: [direct]);
    await tester.pumpWidget(
        _app(ChatScreen(conversation: direct, repository: repo, meId: _me.id)));
    await tester.pump();
    expect(find.byKey(const Key('chat-open-info')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the info page lists the creator, then me, then the rest',
      (tester) async {
    final opened = <int>[];
    await tester.pumpWidget(_app(GroupInfoScreen(
      conversation: _group(),
      meId: _me.id,
      onOpenMember: (_, member) => opened.add(member.id),
    )));
    await tester.pump();

    expect(find.text('No description yet.'), findsOneWidget);
    final order = [
      for (final id in [2, 1, 3])
        tester.getTopLeft(find.byKey(Key('group-member-$id'))).dy,
    ];
    expect(order, orderedEquals([...order]..sort()));
    expect(find.text('You'), findsOneWidget);

    // A member opens their sheet; View profile opens the profile.
    await tester.tap(find.byKey(const Key('group-member-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('member-remove')), findsNothing,
        reason: 'only the owner manages members');
    await tester.tap(find.byKey(const Key('member-profile')));
    await tester.pumpAndSettle();
    expect(opened, [3]);
  });

  testWidgets('the side rail shows a group photo, else its letter',
      (tester) async {
    final withPhoto = Conversation(
      id: 21,
      kind: ConversationKind.group,
      title: 'Heist club',
      members: const [_me, _ana],
      updatedAt: _t,
      photoUrl: 'http://example.test/heist.png',
    );
    final plain = Conversation(
      id: 22,
      kind: ConversationKind.group,
      title: 'noir',
      members: const [_me, _ben],
      updatedAt: _t,
    );
    await tester.pumpWidget(_app(Scaffold(
      body: Row(children: [
        GroupRail(
          visible: true,
          groups: [withPhoto, plain],
          onOpen: (_) {},
          onAll: () {},
        ),
        const Expanded(child: SizedBox()),
      ]),
    )));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('rail-photo-21')), findsOneWidget);
    expect(find.byKey(const Key('rail-photo-22')), findsNothing);
    expect(find.text('N'), findsOneWidget);
  });
}
