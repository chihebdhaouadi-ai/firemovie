import 'dart:typed_data';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../social/data/social_models.dart';
import '../data/messaging_models.dart';

/// What the + button can start.
enum InboxCreate { message, group, topic, blocked }

ShapeBorder get _sheetShape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    );

/// The + menu: a new message, a group or a private topic.
Future<InboxCreate?> showCreateMenu(BuildContext context) {
  final l10n = context.l10n;
  Widget option(IconData icon, String label, InboxCreate value) => ListTile(
        key: Key('inbox-create-${value.name}'),
        leading: Icon(icon, color: LuxeColors.text),
        title:
            Text(label, style: TextStyle(color: LuxeColors.text, fontSize: 16)),
        onTap: () => Navigator.of(context).pop(value),
      );
  return showModalBottomSheet<InboxCreate>(
    context: context,
    backgroundColor: LuxeColors.bg,
    shape: _sheetShape,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          option(
              BootstrapIcons.chat, l10n.inboxNewMessage, InboxCreate.message),
          option(BootstrapIcons.person_plus, l10n.inboxCreateGroup,
              InboxCreate.group),
          option(BootstrapIcons.lock, l10n.inboxCreateTopic, InboxCreate.topic),
          Divider(height: 1, color: LuxeColors.hair),
          option(BootstrapIcons.slash_circle, l10n.chatBlockedPeople,
              InboxCreate.blocked),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// The friend to message, or null when cancelled.
Future<SocialUser?> pickFriend(BuildContext context, List<SocialUser> friends) {
  final l10n = context.l10n;
  return showModalBottomSheet<SocialUser>(
    context: context,
    backgroundColor: LuxeColors.bg,
    isScrollControlled: true,
    shape: _sheetShape,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(l10n.inboxPickFriend),
            if (friends.isEmpty) _NoFriends(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final friend in friends)
                    ListTile(
                      key: Key('pick-friend-${friend.id}'),
                      leading: _FriendAvatar(friend),
                      title: Text(friend.username,
                          style: TextStyle(color: LuxeColors.text)),
                      onTap: () => Navigator.of(context).pop(friend),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// A name, optional description and photo, and the friends to add, for a new
/// group or private topic.
typedef NewChatChoice = ({
  String title,
  List<int> memberIds,
  String description,
  XFile? photo,
});

/// Opens the gallery for a group photo; replaced in tests.
typedef PickGroupPhoto = Future<XFile?> Function();

Future<XFile?> _defaultPickGroupPhoto() => ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

Future<NewChatChoice?> pickGroup(
  BuildContext context, {
  required ConversationKind kind,
  required List<SocialUser> friends,
  PickGroupPhoto pickPhoto = _defaultPickGroupPhoto,
}) {
  return showModalBottomSheet<NewChatChoice>(
    context: context,
    backgroundColor: LuxeColors.bg,
    isScrollControlled: true,
    shape: _sheetShape,
    builder: (context) =>
        _GroupSheet(kind: kind, friends: friends, pickPhoto: pickPhoto),
  );
}

class _GroupSheet extends StatefulWidget {
  const _GroupSheet({
    required this.kind,
    required this.friends,
    required this.pickPhoto,
  });

  final ConversationKind kind;
  final List<SocialUser> friends;
  final PickGroupPhoto pickPhoto;

  @override
  State<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<_GroupSheet> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final Set<int> _chosen = {};
  XFile? _photo;
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty;

  Future<void> _choosePhoto() async {
    final photo = await widget.pickPhoto();
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photo = photo;
      _photoBytes = bytes;
    });
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: LuxeColors.muted),
        filled: true,
        fillColor: LuxeColors.surface,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topic = widget.kind == ConversationKind.topic;
    final bytes = _photoBytes;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetTitle(
                  topic ? l10n.inboxCreateTopic : l10n.inboxCreateGroup),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.inboxGroupPhoto,
                      excludeSemantics: true,
                      child: InkWell(
                        key: const Key('new-chat-photo'),
                        customBorder: const CircleBorder(),
                        onTap: _choosePhoto,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LuxeColors.surface,
                            border: Border.all(color: LuxeColors.hair),
                            image: bytes == null
                                ? null
                                : DecorationImage(
                                    image: MemoryImage(bytes),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: bytes == null
                              ? Icon(BootstrapIcons.camera,
                                  color: LuxeColors.muted, size: 22)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('new-chat-name'),
                        controller: _name,
                        autofocus: true,
                        maxLength: 60,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: LuxeColors.text),
                        decoration: _field(
                            topic ? l10n.inboxTopicName : l10n.inboxGroupName),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  key: const Key('new-chat-description'),
                  controller: _description,
                  maxLength: 300,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: LuxeColors.text),
                  decoration: _field(l10n.inboxGroupDescription),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Text(
                  _chosen.isEmpty
                      ? l10n.inboxPickFriends
                      : '${l10n.inboxPickFriends} · ${_chosen.length}',
                  style: TextStyle(
                    color: LuxeColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.friends.isEmpty) _NoFriends(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final friend in widget.friends)
                      CheckboxListTile(
                        key: Key('group-friend-${friend.id}'),
                        value: _chosen.contains(friend.id),
                        onChanged: (on) => setState(() => on == true
                            ? _chosen.add(friend.id)
                            : _chosen.remove(friend.id)),
                        secondary: _FriendAvatar(friend),
                        title: Text(friend.username,
                            style: TextStyle(color: LuxeColors.text)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.inboxCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('new-chat-create'),
                        style: FilledButton.styleFrom(
                          backgroundColor: LuxeColors.text,
                          foregroundColor: LuxeColors.bg,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _ready
                            ? () => Navigator.of(context).pop((
                                  title: _name.text.trim(),
                                  memberIds: _chosen.toList(),
                                  description: _description.text.trim(),
                                  photo: _photo,
                                ))
                            : null,
                        child: Text(l10n.inboxCreateAction),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every private topic, plus a row to start a new one.
Future<void> showTopicsSheet(
  BuildContext context, {
  required List<Conversation> topics,
  required ValueChanged<Conversation> onOpen,
  required VoidCallback onNew,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: LuxeColors.bg,
    isScrollControlled: true,
    shape: _sheetShape,
    builder: (sheet) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * .7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(l10n.inboxPrivateTopics),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final topic in topics)
                    ListTile(
                      leading:
                          Icon(BootstrapIcons.lock, color: LuxeColors.text),
                      title: Text(topic.title,
                          style: TextStyle(
                              color: LuxeColors.text,
                              fontWeight: FontWeight.w600)),
                      subtitle: topic.lastMessage == null
                          ? null
                          : Text(
                              topic.lastMessage!.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: LuxeColors.muted),
                            ),
                      trailing:
                          topic.unread > 0 ? _CountPill(topic.unread) : null,
                      onTap: () {
                        Navigator.of(sheet).pop();
                        onOpen(topic);
                      },
                    ),
                  ListTile(
                    key: const Key('topics-new'),
                    leading:
                        Icon(BootstrapIcons.plus_lg, color: LuxeColors.text),
                    title: Text(l10n.inboxNewTopic,
                        style: TextStyle(color: LuxeColors.text)),
                    onTap: () {
                      Navigator.of(sheet).pop();
                      onNew();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Text(
          text,
          style: TextStyle(
            color: LuxeColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _NoFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          context.l10n.inboxNoFriends,
          style: TextStyle(color: LuxeColors.muted),
        ),
      );
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar(this.friend);

  final SocialUser friend;

  @override
  Widget build(BuildContext context) => AvatarFrame(
        size: 38,
        avatarUrl: friend.avatarUrl,
        initial:
            friend.username.isEmpty ? '?' : friend.username[0].toUpperCase(),
        framed: false,
        animate: false,
        ringWidth: 0,
      );
}

/// A small dark pill with a count, used for unread messages.
class _CountPill extends StatelessWidget {
  const _CountPill(this.count);

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: LuxeColors.text,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: LuxeColors.bg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
