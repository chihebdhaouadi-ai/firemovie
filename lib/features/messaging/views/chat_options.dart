import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../data/messaging_models.dart';
import '../../social/data/social_repository.dart';
import '../data/messaging_repository.dart';
import 'chat_sheets.dart';

/// The everyday things a member does with a whole chat, from the inbox (hold
/// or right-click a chat) or the chat's own menu.
enum ChatOption { pin, mute, unread, clear, delete, block }

/// What running a [ChatOption] did to the chat.
sealed class ChatOptionResult {
  const ChatOptionResult();
}

/// The chat changed (settings, history or block); here is the new version.
final class ChatUpdated extends ChatOptionResult {
  const ChatUpdated(this.conversation);
  final Conversation conversation;
}

/// The chat left my inbox (deleted).
final class ChatRemoved extends ChatOptionResult {
  const ChatRemoved();
}

/// The friend in a direct chat, or null for groups.
ChatUser? directFriend(Conversation conversation, int? meId) {
  if (!conversation.isDirect) return null;
  final others = conversation.others(meId);
  return others.isEmpty ? null : others.first;
}

/// Asks before something that can't be undone; true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool danger = true,
}) async {
  final l10n = context.l10n;
  return await showChatSheet<bool>(
        context,
        (context) => SheetBody(
          title: title,
          body: body,
          children: [
            SheetButton(
              key: const Key('confirm-action'),
              label: confirmLabel,
              danger: danger,
              onTap: () => Navigator.of(context).pop(true),
            ),
            SheetButton(
              label: l10n.chatCancel,
              outlined: true,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ) ??
      false;
}

/// The options sheet for a chat in the inbox.
Future<ChatOption?> showChatOptionsSheet(
  BuildContext context, {
  required Conversation conversation,
  required int? meId,
}) {
  final l10n = context.l10n;
  final friend = directFriend(conversation, meId);
  return showChatSheet<ChatOption>(
    context,
    (context) => SheetBody(
      title: conversation.title,
      children: [
        for (final (option, label, danger) in chatOptionLabels(
          context,
          conversation: conversation,
          friend: friend,
        ))
          SheetOption(
            key: Key('chat-option-${option.name}'),
            label: label,
            danger: danger,
            onTap: () => Navigator.of(context).pop(option),
          ),
        SheetButton(
          label: l10n.chatCancel,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// The options that apply to [conversation], with their labels and whether
/// each is destructive. Direct chats can be deleted and the friend blocked;
/// groups are left from the chat itself.
List<(ChatOption, String, bool)> chatOptionLabels(
  BuildContext context, {
  required Conversation conversation,
  required ChatUser? friend,
}) {
  final l10n = context.l10n;
  return [
    (
      ChatOption.pin,
      conversation.pinned ? l10n.chatUnpinChat : l10n.chatPinChat,
      false,
    ),
    (
      ChatOption.mute,
      conversation.muted ? l10n.chatUnmute : l10n.chatMute,
      false,
    ),
    (
      ChatOption.unread,
      conversation.looksUnread ? l10n.chatMarkRead : l10n.chatMarkUnread,
      false,
    ),
    (ChatOption.clear, l10n.chatClearHistory, true),
    if (friend != null) ...[
      (
        ChatOption.block,
        conversation.block == ChatBlock.byMe
            ? l10n.chatUnblock(friend.username)
            : l10n.chatBlock(friend.username),
        conversation.block != ChatBlock.byMe,
      ),
      (ChatOption.delete, l10n.chatDeleteChat, true),
    ],
  ];
}

/// Runs [option] on [conversation], asking first when it can't be undone,
/// and says what happened in a snack bar. Null when cancelled or failed.
Future<ChatOptionResult?> runChatOption(
  BuildContext context, {
  required ChatOption option,
  required Conversation conversation,
  required int? meId,
  required MessagingRepository repository,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  void toast(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1800),
    ));
  final id = conversation.id;
  final friend = directFriend(conversation, meId);

  try {
    switch (option) {
      case ChatOption.pin:
        return ChatUpdated(
            await repository.updateSettings(id, pinned: !conversation.pinned));
      case ChatOption.mute:
        final muted = !conversation.muted;
        final updated = await repository.updateSettings(id, muted: muted);
        toast(muted ? l10n.chatMutedToast : l10n.chatUnmutedToast);
        return ChatUpdated(updated);
      case ChatOption.unread:
        return ChatUpdated(await repository.updateSettings(id,
            unread: !conversation.looksUnread));
      case ChatOption.clear:
        final ok = await confirmAction(
          context,
          title: l10n.chatClearTitle,
          body: l10n.chatClearBody,
          confirmLabel: l10n.chatClearHistory,
        );
        if (!ok) return null;
        final updated = await repository.clearHistory(id);
        toast(l10n.chatCleared);
        return ChatUpdated(updated);
      case ChatOption.delete:
        final ok = await confirmAction(
          context,
          title: l10n.chatDeleteChatTitle,
          body: l10n.chatDeleteChatBody(friend?.username ?? ''),
          confirmLabel: l10n.chatDeleteChat,
        );
        if (!ok) return null;
        await repository.deleteChat(id);
        toast(l10n.chatChatDeleted);
        return const ChatRemoved();
      case ChatOption.block:
        if (friend == null) return null;
        if (conversation.block == ChatBlock.byMe) {
          await repository.unblock(friend.id);
          toast(l10n.chatUnblockedToast(friend.username));
          return ChatUpdated(conversation.copyWith(block: ChatBlock.none));
        }
        final ok = await confirmAction(
          context,
          title: l10n.chatBlockTitle(friend.username),
          body: l10n.chatBlockBody,
          confirmLabel: l10n.chatBlock(friend.username),
        );
        if (!ok) return null;
        await repository.block(friend.id);
        toast(l10n.chatBlockedToast(friend.username));
        return ChatUpdated(conversation.copyWith(block: ChatBlock.byMe));
    }
  } on Exception {
    toast(l10n.chatActionFailed);
    return null;
  }
}

/// Picks friends to add to a group; returns their ids, or null.
Future<List<int>?> pickMembersToAdd(
  BuildContext context, {
  required String groupName,
  required List<ChatUser> candidates,
}) =>
    showChatSheet<List<int>>(
      context,
      (context) => _AddMembersSheet(
        groupName: groupName,
        candidates: candidates,
      ),
    );

class _AddMembersSheet extends StatefulWidget {
  const _AddMembersSheet({required this.groupName, required this.candidates});

  final String groupName;
  final List<ChatUser> candidates;

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> {
  final Set<int> _picked = {};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetBody(
      title: l10n.chatAddMembersTitle(widget.groupName),
      body: widget.candidates.isEmpty ? l10n.chatAddMembersNone : null,
      children: [
        if (widget.candidates.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .45,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final friend in widget.candidates)
                  MemberRow(
                    key: Key('add-member-${friend.id}'),
                    user: friend,
                    selected: _picked.contains(friend.id),
                    onTap: () => setState(() {
                      if (!_picked.remove(friend.id)) _picked.add(friend.id);
                    }),
                  ),
              ],
            ),
          ),
        if (widget.candidates.isNotEmpty)
          SheetButton(
            key: const Key('add-members-confirm'),
            label: l10n.chatAddSelected,
            onTap: _picked.isEmpty
                ? null
                : () => Navigator.of(context).pop(_picked.toList()),
          ),
        SheetButton(
          label: l10n.chatCancel,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// The people I blocked, each with an Unblock button.
Future<void> showBlockedSheet(
  BuildContext context, {
  required MessagingRepository repository,
}) =>
    showChatSheet<void>(
      context,
      (context) => _BlockedSheet(repository: repository),
    );

class _BlockedSheet extends StatefulWidget {
  const _BlockedSheet({required this.repository});

  final MessagingRepository repository;

  @override
  State<_BlockedSheet> createState() => _BlockedSheetState();
}

class _BlockedSheetState extends State<_BlockedSheet> {
  List<ChatUser>? _blocked;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final blocked = await widget.repository.blockedUsers();
      if (mounted) setState(() => _blocked = blocked);
    } on Exception {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _unblock(ChatUser user) async {
    final failed = context.l10n.chatActionFailed;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.repository.unblock(user.id);
      if (mounted) {
        setState(() => _blocked = [
              for (final u in _blocked ?? const <ChatUser>[])
                if (u.id != user.id) u,
            ]);
      }
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocked = _blocked;
    return SheetBody(
      title: l10n.chatBlockedPeople,
      body: _failed
          ? l10n.chatActionFailed
          : blocked != null && blocked.isEmpty
              ? l10n.chatNoBlocked
              : null,
      children: [
        if (blocked == null && !_failed)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        for (final user in blocked ?? const <ChatUser>[])
          MemberRow(
            key: Key('blocked-${user.id}'),
            user: user,
            onTap: null,
            trailing: TextButton(
              key: Key('unblock-${user.id}'),
              onPressed: () => _unblock(user),
              child: Text(l10n.chatUnblockShort,
                  style: TextStyle(color: LuxeColors.text)),
            ),
          ),
        SheetButton(
          label: l10n.chatCancel,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// My friends as chat users, for "Add members"; empty when there is no
/// social repository.
Future<List<ChatUser>> Function()? friendLoader(SocialRepository? social) {
  if (social == null) return null;
  return () async => [
        for (final f in (await social.connections()).friends)
          ChatUser(id: f.id, username: f.username, avatarUrl: f.avatarUrl),
      ];
}
