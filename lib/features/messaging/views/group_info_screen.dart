import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../profile/views/profile_screen.dart';
import '../data/messaging_models.dart';
import '../data/messaging_repository.dart';
import 'chat_sheets.dart';
import 'conversation_avatar.dart';

/// Opens [member]'s profile page.
void openMemberProfile(BuildContext context, ChatUser member) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => ProfileScreen(userId: member.id)),
  );
}

/// The member sheet: view the profile and, for the group's owner, hand the
/// group over or remove the member (both confirmed by typing the group's
/// name). Returns the group as it is after a change, or null.
Future<Conversation?> manageMember(
  BuildContext context, {
  required Conversation conversation,
  required ChatUser member,
  required int? meId,
  MessagingRepository? repository,
  void Function(BuildContext context, ChatUser member)? onOpenProfile,
}) async {
  final l10n = context.l10n;
  final open = onOpenProfile ?? openMemberProfile;
  if (member.id == meId) return null;
  final canManage = repository != null && conversation.isOwner(meId);
  final action = await showMemberSheet(
    context,
    member: member,
    isHeritage: conversation.heritage && conversation.createdById == member.id,
    canManage: canManage,
  );
  if (!context.mounted || action == null) return null;
  final name = member.username;
  final group = conversation.title;
  switch (action) {
    case MemberAction.profile:
      open(context, member);
      return null;
    case MemberAction.heritage:
      final ok = await confirmTyped(
        context,
        title: l10n.memberMakeHeritageTitle(name),
        body: l10n.memberMakeHeritageConfirmBody(name),
        groupName: group,
        confirmLabel: l10n.memberMakeHeritage,
      );
      if (!ok || !context.mounted) return null;
      return _attempt(
          context, () => repository!.makeHeritage(conversation.id, member.id));
    case MemberAction.remove:
      final ok = await confirmTyped(
        context,
        title: l10n.memberRemoveTitle(name),
        body: l10n.memberRemoveConfirmBody(name, group),
        groupName: group,
        confirmLabel: l10n.memberRemoveConfirm(name),
      );
      if (!ok || !context.mounted) return null;
      return _attempt(
          context, () => repository!.removeMember(conversation.id, member.id));
  }
}

Future<Conversation?> _attempt(
  BuildContext context,
  Future<Conversation> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.chatActionFailed;
  try {
    return await action();
  } on Exception {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
    return null;
  }
}

/// A group's or private topic's details, opened by tapping its name in the
/// chat: the photo, name, description and everyone in it, with a member
/// search. Tapping a member opens their sheet.
class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({
    super.key,
    required this.conversation,
    required this.meId,
    this.onOpenMember,
    this.repository,
    this.onChanged,
  });

  final Conversation conversation;
  final int? meId;

  /// Opens a member's profile; defaults to the profile page.
  final void Function(BuildContext context, ChatUser member)? onOpenMember;

  /// Lets the owner manage members; without it the sheet only shows the
  /// profile.
  final MessagingRepository? repository;

  /// Told about the group after a member was removed or made owner.
  final ValueChanged<Conversation>? onChanged;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late Conversation _convo = widget.conversation;
  String _query = '';

  Future<void> _tap(ChatUser member) async {
    final updated = await manageMember(
      context,
      conversation: _convo,
      member: member,
      meId: widget.meId,
      repository: widget.repository,
      onOpenProfile: widget.onOpenMember,
    );
    if (updated == null || !mounted) return;
    setState(() => _convo = updated);
    widget.onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final convo = _convo;
    final meId = widget.meId;
    // The owner first, then me, then everyone else by name.
    final members = [...convo.members]..sort((a, b) {
        int rank(ChatUser user) => user.id == convo.createdById
            ? 0
            : user.id == meId
                ? 1
                : 2;
        final byRank = rank(a).compareTo(rank(b));
        return byRank != 0
            ? byRank
            : a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });
    final q = _query.trim().toLowerCase();
    final shown = members.where((m) {
      final name = m.id == meId ? l10n.groupInfoYou : m.username;
      return name.toLowerCase().contains(q);
    }).toList();
    final ownerTag =
        convo.heritage ? l10n.groupInfoHeritage : l10n.groupInfoCreator;

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: LuxeColors.text,
        title: Text(
          convo.isTopic ? l10n.groupInfoTopicTitle : l10n.groupInfoTitle,
          style: TextStyle(
            color: LuxeColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: ConversationAvatar(
              key: const Key('group-info-photo'),
              conversation: convo,
              meId: meId,
              size: 96,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            convo.title,
            key: const Key('group-info-title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LuxeColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            convo.isTopic
                ? '${l10n.chatPrivateTopic} · ${l10n.inboxMembers(members.length)}'
                : l10n.inboxMembers(members.length),
            textAlign: TextAlign.center,
            style: TextStyle(color: LuxeColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.groupInfoDescription),
          const SizedBox(height: 8),
          Container(
            key: const Key('group-info-description'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LuxeColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LuxeColors.hair),
            ),
            child: Text(
              convo.description.isEmpty
                  ? l10n.groupInfoNoDescription
                  : convo.description,
              style: TextStyle(
                color: convo.description.isEmpty
                    ? LuxeColors.muted
                    : LuxeColors.text,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.groupInfoMembers(members.length)),
          const SizedBox(height: 8),
          TextField(
            key: const Key('group-member-search'),
            onChanged: (value) => setState(() => _query = value),
            style: TextStyle(color: LuxeColors.text),
            decoration: InputDecoration(
              hintText: l10n.groupInfoSearch,
              hintStyle: TextStyle(color: LuxeColors.muted),
              prefixIcon: Icon(BootstrapIcons.search,
                  size: 15, color: LuxeColors.muted),
              filled: true,
              fillColor: LuxeColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: LuxeColors.hair),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: LuxeColors.hair),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.groupInfoNoMatch(_query),
                textAlign: TextAlign.center,
                style: TextStyle(color: LuxeColors.muted),
              ),
            ),
          for (final member in shown)
            ListTile(
              key: Key('group-member-${member.id}'),
              contentPadding: EdgeInsets.zero,
              onTap: member.id == meId ? null : () => _tap(member),
              leading: AvatarFrame(
                size: 40,
                avatarUrl: member.avatarUrl,
                initial: member.initial,
                framed: false,
                animate: false,
                ringWidth: 0,
              ),
              title: Text(
                member.id == meId ? l10n.groupInfoYou : member.username,
                style: TextStyle(color: LuxeColors.text, fontSize: 15),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (member.id == convo.createdById) MemberTag(text: ownerTag),
                  if (member.id != meId) ...[
                    const SizedBox(width: 6),
                    Icon(BootstrapIcons.chevron_right,
                        size: 16, color: LuxeColors.muted),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: LuxeColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
}
