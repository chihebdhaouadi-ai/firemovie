import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../data/messaging_models.dart';
import '../data/messaging_repository.dart';
import 'chat_message_tile.dart';
import 'chat_options.dart';
import 'chat_sheets.dart';
import 'conversation_avatar.dart';
import 'emoji_panel.dart';
import 'group_info_screen.dart';

/// How often an open chat checks for new messages, reactions and votes.
const chatPollInterval = Duration(seconds: 4);

/// Picks a photo or video from the device; tests pass their own.
typedef PickMedia = Future<XFile?> Function(MessageKind kind);

Future<XFile?> _defaultPickMedia(MessageKind kind) {
  final picker = ImagePicker();
  return kind == MessageKind.video
      ? picker.pickVideo(source: ImageSource.gallery)
      : picker.pickImage(
          source: ImageSource.gallery, maxWidth: 2048, imageQuality: 85);
}

/// One conversation: a pinned bar, the messages (Discord style, grouped by
/// sender), the owner's leave vote while one runs, and a composer with
/// mentions, emoji / GIF / sticker panel and photo, video, movie and poll
/// posts. Holding a message reacts, replies, pins or mentions.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversation,
    required this.repository,
    required this.meId,
    this.embedded = false,
    this.pickMedia = _defaultPickMedia,
    this.searchMovies = searchFilms,
    this.onLeft,
    this.loadFriends,
  });

  final Conversation conversation;
  final MessagingRepository repository;
  final int? meId;

  /// Drawn inside a pane (the wide inbox) instead of as its own page: no
  /// back button, a plain header row and rounded edges.
  final bool embedded;
  final PickMedia pickMedia;
  final MovieSearch searchMovies;

  /// My friends, for adding people to a group; null hides "Add members".
  final Future<List<ChatUser>> Function()? loadFriends;

  /// Called after leaving the group (the chat closes itself as a page).
  final VoidCallback? onLeft;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// What the bottom panel is open for.
sealed class _Panel {
  const _Panel();
}

final class _ComposerPanel extends _Panel {
  const _ComposerPanel();
}

final class _ReactionPanel extends _Panel {
  const _ReactionPanel(this.messageId);
  final int messageId;
}

class _ChatScreenState extends State<ChatScreen> {
  final _composer = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  final Map<int, GlobalKey> _keys = {};
  late Conversation _convo = widget.conversation;
  Timer? _poll;
  bool _loading = true;
  bool _sending = false;
  ChatMessage? _replyTo;

  /// My message being edited in the composer, if any.
  ChatMessage? _editing;
  _Panel? _panel;
  String? _mentionQuery;
  int? _flashId;
  int _pinIndex = 0;

  int? get _me => widget.meId;
  bool get _isOwner => _convo.isOwner(_me);

  @override
  void initState() {
    super.initState();
    _composer.addListener(_watchMention);
    unawaited(_load());
    _poll = Timer.periodic(chatPollInterval, (_) => unawaited(_refresh()));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _composer.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int id) => _keys.putIfAbsent(id, GlobalKey.new);

  Future<void> _load() async {
    try {
      final messages = await widget.repository.messages(_convo.id);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
      });
      _scrollToEnd(animate: false);
    } on Exception {
      if (mounted) setState(() => _loading = false);
    }
    unawaited(_refreshConversation());
  }

  /// Reloads the latest page, so new messages, reactions, pins and poll
  /// votes from others show up.
  Future<void> _refresh() async {
    if (_loading) return;
    try {
      final messages = await widget.repository.messages(_convo.id);
      if (!mounted) return;
      final grew = messages.isNotEmpty &&
          (_messages.isEmpty || messages.last.id != _messages.last.id);
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
      });
      if (grew) _scrollToEnd();
    } on Exception {
      // Try again on the next tick.
    }
    unawaited(_refreshConversation());
  }

  Future<void> _refreshConversation() async {
    try {
      final convo = await widget.repository.conversation(_convo.id);
      if (mounted) setState(() => _convo = convo);
    } on Exception {
      // Keep what we have.
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ));
  }

  void _put(ChatMessage message) {
    setState(() {
      final i = _messages.indexWhere((m) => m.id == message.id);
      if (i >= 0) {
        _messages[i] = message;
      } else {
        _messages.add(message);
      }
    });
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    if (_editing != null) return _saveEdit(text);
    final failed = context.l10n.chatSendFailed;
    final notified = context.l10n.chatNotified;
    setState(() => _sending = true);
    try {
      final message =
          await widget.repository.send(_convo.id, text, replyTo: _replyTo?.id);
      if (!mounted) return;
      _put(message);
      setState(() {
        _composer.clear();
        _replyTo = null;
        _mentionQuery = null;
      });
      _scrollToEnd();
      final tagged = mentionedNames(text, _convo.others(_me));
      if (tagged.isNotEmpty) _toast(notified(tagged.join(', ')));
    } on Exception {
      _toast(failed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _saveEdit(String text) async {
    final editing = _editing!;
    final failed = context.l10n.chatActionFailed;
    setState(() => _sending = true);
    try {
      final updated = await widget.repository.editMessage(editing.id, text);
      if (!mounted) return;
      _put(updated);
      setState(() {
        _editing = null;
        _composer.clear();
      });
    } on Exception {
      _toast(failed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startEdit(ChatMessage message) {
    setState(() {
      _editing = message;
      _replyTo = null;
      _composer.text = message.body;
      _composer.selection =
          TextSelection.collapsed(offset: _composer.text.length);
    });
    _focus.requestFocus();
  }

  void _cancelEdit() => setState(() {
        _editing = null;
        _composer.clear();
      });

  Future<void> _deleteMessage(ChatMessage message) async {
    final l10n = context.l10n;
    final ok = await confirmAction(
      context,
      title: l10n.chatDeleteMessageTitle,
      body: l10n.chatDeleteMessageBody,
      confirmLabel: l10n.chatDeleteMessage,
    );
    if (!ok || !mounted) return;
    try {
      _put(await widget.repository.deleteMessage(message.id));
      if (_editing?.id == message.id) _cancelEdit();
    } on Exception {
      _toast(l10n.chatActionFailed);
    }
  }

  Future<void> _report({ChatMessage? message}) async {
    final l10n = context.l10n;
    final reason = await showReportSheet(
      context,
      title: message == null ? null : l10n.chatReportMessage,
    );
    if (reason == null || !mounted) return;
    try {
      await widget.repository
          .report(_convo.id, reason: reason, messageId: message?.id);
      _toast(l10n.chatReportSent);
    } on Exception {
      _toast(l10n.chatActionFailed);
    }
  }

  Future<void> _sendPost(OutgoingPost post) async {
    final failed = context.l10n.chatSendFailed;
    try {
      final message = await widget.repository.sendPost(_convo.id, post);
      if (!mounted) return;
      _put(message);
      setState(() {
        _replyTo = null;
        _panel = null;
      });
      _scrollToEnd();
    } on Exception {
      _toast(failed);
    }
  }

  Future<void> _react(ChatMessage message, String emoji) async {
    try {
      _put(await widget.repository.react(message.id, emoji));
    } on Exception {
      if (mounted) _toast(context.l10n.chatActionFailed);
    }
  }

  Future<void> _togglePin(ChatMessage message) async {
    final l10n = context.l10n;
    try {
      final updated = await widget.repository.togglePin(message.id);
      _put(updated);
      _toast(
          updated.pinned ? l10n.chatMessagePinned : l10n.chatMessageUnpinned);
      unawaited(_refresh());
    } on Exception {
      _toast(l10n.chatActionFailed);
    }
  }

  Future<void> _votePoll(ChatMessage message, int option) async {
    try {
      _put(await widget.repository.votePoll(message.id, option));
    } on Exception {
      if (mounted) _toast(context.l10n.chatActionFailed);
    }
  }

  Future<void> _hold(ChatMessage message) async {
    final box =
        _keyFor(message.id).currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final mine = message.sender.id == _me;
    final other = mine ? null : message.sender.username;
    final limited = message.allowedReactions.isNotEmpty;
    final live = !message.deleted;
    final canWrite = _convo.block == ChatBlock.none;
    final result = await showHoldMenu(
      context,
      rect: rect,
      lifted: SizedBox(
        width: rect.width,
        child: _tile(message, grouped: false, lifted: true),
      ),
      reactions: limited ? message.allowedReactions : defaultReactions,
      allowMore: !limited,
      canPin: _isOwner && live,
      pinned: message.pinned,
      otherName: other,
      canReply: live && canWrite,
      canReact: live,
      canCopy: live && message.body.isNotEmpty,
      canEdit: live && mine && message.kind == MessageKind.text && canWrite,
      canDelete: live && (mine || _isOwner),
      canReport: live && !mine,
    );
    if (!mounted || result == null) return;
    switch (result) {
      case HoldReact(:final emoji):
        await _react(message, emoji);
      case HoldMoreReactions():
        FocusScope.of(context).unfocus();
        setState(() => _panel = _ReactionPanel(message.id));
      case HoldReply():
        setState(() => _replyTo = message);
        _focus.requestFocus();
      case HoldPin():
        await _togglePin(message);
      case HoldMention():
        _insertMention(message.sender.username, replaceQuery: false);
      case HoldProfile():
        openMemberProfile(context, message.sender);
      case HoldCopy():
        await Clipboard.setData(ClipboardData(text: message.body));
        if (mounted) _toast(context.l10n.chatCopied);
      case HoldEdit():
        _startEdit(message);
      case HoldDelete():
        await _deleteMessage(message);
      case HoldReport():
        await _report(message: message);
    }
  }

  void _jumpTo(int id) {
    final target = _keys[id]?.currentContext;
    if (target == null) return;
    unawaited(Scrollable.ensureVisible(target,
        alignment: .2, duration: const Duration(milliseconds: 250)));
    setState(() => _flashId = id);
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && _flashId == id) setState(() => _flashId = null);
    });
  }

  void _jumpToPinned() {
    final pinned = _messages.where((m) => m.pinned).toList();
    if (pinned.isEmpty) return;
    _pinIndex %= pinned.length;
    // Newest first, then older ones on each tap.
    _jumpTo(pinned[pinned.length - 1 - _pinIndex].id);
    _pinIndex++;
  }

  void _watchMention() {
    final text = _composer.text;
    final cursor = _composer.selection.baseOffset;
    final before =
        cursor < 0 || cursor > text.length ? text : text.substring(0, cursor);
    final match = RegExp(r'(?:^|\s)@([\w.]*)$').firstMatch(before);
    final query = match?.group(1);
    if (query != _mentionQuery) setState(() => _mentionQuery = query);
  }

  void _insertMention(String username, {bool replaceQuery = true}) {
    var text = _composer.text;
    if (replaceQuery && _mentionQuery != null) {
      text = text.replaceFirst(RegExp(r'@[\w.]*$'), '@$username ');
    } else {
      final gap = text.isEmpty || text.endsWith(' ') ? '' : ' ';
      text = '$text$gap@$username ';
    }
    _composer.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() => _mentionQuery = null);
    _focus.requestFocus();
  }

  Future<void> _attach() async {
    final l10n = context.l10n;
    final choice = await showAttachSheet(context);
    if (!mounted || choice == null) return;
    OutgoingPost? post;
    switch (choice) {
      case AttachChoice.photo:
      case AttachChoice.video:
        final kind = choice == AttachChoice.photo
            ? MessageKind.photo
            : MessageKind.video;
        final file = await widget.pickMedia(kind);
        if (!mounted || file == null) return;
        if (await file.length() > maxChatFileBytes) {
          if (mounted) _toast(l10n.chatFileTooBig);
          return;
        }
        final bytes =
            kind == MessageKind.photo ? await file.readAsBytes() : null;
        if (!mounted) return;
        post = await showPostSheet(context,
            kind: kind, file: file, previewBytes: bytes, replyTo: _replyTo?.id);
      case AttachChoice.movie:
        final movie =
            await showMovieSearch(context, search: widget.searchMovies);
        if (!mounted || movie == null) return;
        post = await showPostSheet(context,
            kind: MessageKind.movie, movie: movie, replyTo: _replyTo?.id);
      case AttachChoice.poll:
        post = await showPostSheet(context,
            kind: MessageKind.poll, replyTo: _replyTo?.id);
    }
    if (post != null && mounted) await _sendPost(post);
  }

  void _togglePanel() {
    if (_panel is _ComposerPanel) {
      setState(() => _panel = null);
      _focus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      setState(() => _panel = const _ComposerPanel());
    }
  }

  Future<void> _picked(PanelPick pick) async {
    final panel = _panel;
    if (panel is _ReactionPanel) {
      setState(() => _panel = null);
      final message = _messages.where((m) => m.id == panel.messageId);
      if (pick is PickedEmoji && message.isNotEmpty) {
        await _react(message.first, pick.emoji);
      }
      return;
    }
    switch (pick) {
      case PickedEmoji(:final emoji):
        final text = _composer.text + emoji;
        _composer.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      case PickedGif(:final name):
        await _sendPost(OutgoingPost(
            kind: MessageKind.gif, gif: name, replyTo: _replyTo?.id));
      case PickedSticker(:final emoji):
        await _sendPost(OutgoingPost(
            kind: MessageKind.sticker, sticker: emoji, replyTo: _replyTo?.id));
    }
  }

  Future<void> _openAttachment(ChatMessage message) async {
    final url = message.attachmentUrl;
    if (url == null || !url.startsWith('http')) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _openMember(String username) async {
    final member = _convo.members.where((m) => m.username == username);
    if (member.isEmpty) return;
    await _manage(member.first);
  }

  Future<void> _manage(ChatUser member) async {
    final updated = await manageMember(
      context,
      conversation: _convo,
      member: member,
      meId: _me,
      repository: widget.repository,
    );
    if (updated != null && mounted) {
      setState(() => _convo = updated);
      unawaited(_refresh());
    }
  }

  Future<void> _openInfo() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GroupInfoScreen(
          conversation: _convo,
          meId: _me,
          repository: widget.repository,
          onChanged: (convo) {
            if (mounted) setState(() => _convo = convo);
          },
        ),
      ),
    );
    if (mounted) unawaited(_refresh());
  }

  Future<void> _menu(String action) async {
    final l10n = context.l10n;
    switch (action) {
      case 'share':
        final all = await widget.repository.conversations();
        if (!mounted) return;
        final target = await showShareSheet(
          context,
          targets: all.where((c) => c.id != _convo.id).toList(),
          meId: _me,
        );
        if (target != null && mounted) _toast(l10n.chatSharedTo(target.title));
      case 'boost':
        _toast(l10n.chatBoosted(_convo.title));
      case 'report':
        await _report();
      case 'leave':
        await _leave();
      case 'add':
        await _addMembers();
      case 'profile':
        final friend = directFriend(_convo, _me);
        if (friend != null) openMemberProfile(context, friend);
      default:
        final option = ChatOption.values.where((o) => o.name == action);
        if (option.isNotEmpty) await _option(option.first);
    }
  }

  /// Mute, clear history, block or delete, from the chat's menu.
  Future<void> _option(ChatOption option) async {
    final navigator = Navigator.of(context);
    final result = await runChatOption(
      context,
      option: option,
      conversation: _convo,
      meId: _me,
      repository: widget.repository,
    );
    if (!mounted || result == null) return;
    switch (result) {
      case ChatUpdated(conversation: final updated):
        setState(() {
          _convo = updated;
          if (option == ChatOption.clear) _messages.clear();
          if (updated.block != ChatBlock.none) {
            _editing = null;
            _replyTo = null;
            _composer.clear();
          }
        });
      case ChatRemoved():
        widget.onLeft?.call();
        if (!widget.embedded && navigator.canPop()) navigator.pop();
    }
  }

  Future<void> _addMembers() async {
    final load = widget.loadFriends;
    if (load == null) return;
    final l10n = context.l10n;
    final List<ChatUser> friends;
    try {
      friends = await load();
    } on Exception {
      if (mounted) _toast(l10n.chatActionFailed);
      return;
    }
    if (!mounted) return;
    final here = {for (final m in _convo.members) m.id};
    final ids = await pickMembersToAdd(
      context,
      groupName: _convo.title,
      candidates: friends.where((f) => !here.contains(f.id)).toList(),
    );
    if (ids == null || ids.isEmpty || !mounted) return;
    try {
      final updated = await widget.repository.addMembers(_convo.id, ids);
      if (!mounted) return;
      setState(() => _convo = updated);
      _toast(l10n.chatMembersAdded);
      unawaited(_refresh());
    } on Exception {
      _toast(l10n.chatActionFailed);
    }
  }

  Future<void> _leave() async {
    final l10n = context.l10n;
    final name = _convo.title;
    final others = _convo.others(_me);
    if (_isOwner && _convo.vote != null) {
      _toast(l10n.voteRunning);
      return;
    }
    if (!_isOwner || others.isEmpty) {
      final ok = await confirmTyped(
        context,
        title: l10n.leaveSimpleTitle(name),
        body: l10n.leaveSimpleBody,
        groupName: name,
        confirmLabel: l10n.chatLeaveGroup,
      );
      if (ok) await _run(() => widget.repository.leave(_convo.id), left: true);
      return;
    }
    final path = await showCreatorLeaveSheet(context);
    if (!mounted || path == null) return;
    if (path == LeavePath.pass) {
      final next = await showPickOwnerSheet(context, members: others);
      if (!mounted || next == null) return;
      final ok = await confirmTyped(
        context,
        title: l10n.leavePassConfirmTitle(next.username),
        body: l10n.leavePassConfirmBody(next.username),
        groupName: name,
        confirmLabel: l10n.leavePassConfirm,
      );
      if (ok) {
        await _run(() => widget.repository.leave(_convo.id, passTo: next.id),
            left: true);
      }
      return;
    }
    final ok = await confirmTyped(
      context,
      title: l10n.leaveVoteConfirmTitle,
      body: l10n.leaveVoteConfirmBody,
      groupName: name,
      confirmLabel: l10n.leaveVoteConfirm,
      danger: false,
    );
    if (ok) {
      await _run(() async {
        final convo = await widget.repository.startVote(_convo.id);
        if (mounted) setState(() => _convo = convo);
      });
      unawaited(_refresh());
    }
  }

  /// Runs a group action; when it made me leave, closes the chat.
  Future<void> _run(Future<void> Function() action, {bool left = false}) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    try {
      await action();
      if (!left || !mounted) return;
      widget.onLeft?.call();
      if (!widget.embedded && navigator.canPop()) navigator.pop();
    } on Exception {
      if (mounted) _toast(l10n.chatActionFailed);
    }
  }

  Future<void> _ballot(String choice) async {
    await _run(() async {
      final convo = await widget.repository.castBallot(_convo.id, choice);
      if (mounted) setState(() => _convo = convo);
    });
  }

  Future<void> _cancelVote() async {
    await _run(() async {
      final convo = await widget.repository.cancelVote(_convo.id);
      if (mounted) setState(() => _convo = convo);
    });
    unawaited(_refresh());
  }

  void _scrollToEnd({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(end,
            duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      } else {
        _scroll.jumpTo(end);
      }
    });
  }

  Widget _tile(ChatMessage m, {required bool grouped, bool lifted = false}) =>
      MessageTile(
        message: m,
        meId: _me,
        members: _convo.members,
        grouped: grouped,
        lifted: lifted,
        highlighted: _flashId == m.id,
        onHold: () => _hold(m),
        onReaction: (emoji) => _react(m, emoji),
        onOpenReply: _jumpTo,
        onMention: _openMember,
        onVote: (option) => _votePoll(m, option),
        onOpenAttachment: _openAttachment,
      );

  /// Same sender as the message before, within five minutes, not a reply.
  bool _grouped(int index) {
    if (index == 0) return false;
    final m = _messages[index];
    final prev = _messages[index - 1];
    return !m.isSystem &&
        !prev.isSystem &&
        m.replyTo == null &&
        prev.sender.id == m.sender.id &&
        m.createdAt.difference(prev.createdAt).inMinutes < 5;
  }

  /// Direct chats: my last message was read by the friend.
  bool get _seen {
    final seenAt = _convo.seenAt;
    if (!_convo.isDirect || seenAt == null || _messages.isEmpty) return false;
    final last =
        _messages.lastWhere((m) => !m.isSystem, orElse: () => _messages.last);
    return last.sender.id == _me && !last.createdAt.isAfter(seenAt);
  }

  Widget? _voteCard() {
    final vote = _convo.vote;
    if (vote == null) return null;
    final starter = _convo.members.where((m) => m.id == vote.startedById);
    final starterName = vote.startedById == _me
        ? context.l10n.groupInfoYou
        : starter.isEmpty
            ? ''
            : starter.first.username;
    if (vote.stage == GroupVoteStage.keep) {
      return KeepVoteCard(
        vote: vote,
        starterName: starterName,
        mine: vote.startedById == _me,
        onVote: _ballot,
        onCancel: _cancelVote,
      );
    }
    return OwnerVoteCard(
      vote: vote,
      candidates:
          _convo.members.where((m) => m.id != vote.startedById).toList(),
      meId: _me,
      onVote: _ballot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final convo = _convo;
    final subtitle = switch (convo.kind) {
      ConversationKind.direct => null,
      ConversationKind.group => l10n.inboxMembers(convo.members.length),
      ConversationKind.topic => l10n.chatPrivateTopic,
    };

    final row = Row(
      children: [
        ConversationAvatar(conversation: convo, meId: _me, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                convo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LuxeColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: LuxeColors.muted, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
    // Groups and topics: the name opens the info page.
    final Widget titleRow = convo.isDirect
        ? row
        : Semantics(
            button: true,
            label: l10n.chatOpenInfo,
            child: InkWell(
              key: const Key('chat-open-info'),
              borderRadius: BorderRadius.circular(12),
              onTap: _openInfo,
              child: row,
            ),
          );
    final friend = directFriend(convo, _me);
    final Widget menu = PopupMenuButton<String>(
      key: const Key('chat-menu'),
      tooltip: l10n.chatMenu,
      icon: Icon(BootstrapIcons.three_dots_vertical, color: LuxeColors.text),
      color: LuxeColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: LuxeColors.hair),
      ),
      onSelected: _menu,
      itemBuilder: (context) => [
        if (friend != null)
          _menuItem('profile', BootstrapIcons.person, l10n.chatViewProfileMenu),
        if (!convo.isDirect) ...[
          if (_isOwner && widget.loadFriends != null)
            _menuItem('add', BootstrapIcons.person_plus, l10n.chatAddMembers),
          _menuItem(
              'share', BootstrapIcons.box_arrow_up_right, l10n.chatShareGroup),
          _menuItem(
              'boost', BootstrapIcons.lightning_charge, l10n.chatBoostGroup),
        ],
        _menuItem(
          ChatOption.mute.name,
          convo.muted ? BootstrapIcons.bell : BootstrapIcons.bell_slash,
          convo.muted ? l10n.chatUnmute : l10n.chatMute,
        ),
        _menuItem(ChatOption.clear.name, BootstrapIcons.eraser,
            l10n.chatClearHistory),
        _menuItem('report', BootstrapIcons.flag, l10n.chatReport),
        if (friend != null) ...[
          _menuItem(
            ChatOption.block.name,
            BootstrapIcons.slash_circle,
            convo.block == ChatBlock.byMe
                ? l10n.chatUnblock(friend.username)
                : l10n.chatBlock(friend.username),
            danger: convo.block != ChatBlock.byMe,
          ),
          _menuItem(
              ChatOption.delete.name, BootstrapIcons.trash, l10n.chatDeleteChat,
              danger: true),
        ] else
          _menuItem(
              'leave', BootstrapIcons.box_arrow_right, l10n.chatLeaveGroup,
              danger: true),
      ],
    );

    final pinned = _messages.where((m) => m.pinned).toList();
    final voteCard = _voteCard();
    final list = _loading
        ? const Center(child: CircularProgressIndicator())
        : _messages.isEmpty && voteCard == null
            ? Center(
                child: Text(
                  l10n.chatStart,
                  style: TextStyle(color: LuxeColors.muted),
                ),
              )
            : SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _messages.length; i++)
                      KeyedSubtree(
                        key: _keyFor(_messages[i].id),
                        child: _messages[i].isSystem
                            ? SystemLine(message: _messages[i], meId: _me)
                            : _tile(_messages[i], grouped: _grouped(i)),
                      ),
                    if (_seen)
                      Padding(
                        key: const Key('chat-seen'),
                        padding:
                            const EdgeInsetsDirectional.only(end: 8, top: 2),
                        child: Text(
                          l10n.chatSeen,
                          textAlign: TextAlign.end,
                          style:
                              TextStyle(color: LuxeColors.muted, fontSize: 11),
                        ),
                      ),
                    if (voteCard != null) voteCard,
                  ],
                ),
              );

    final body = Column(
      children: [
        if (pinned.isNotEmpty) PinnedBar(pinned: pinned, onTap: _jumpToPinned),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_panel != null) setState(() => _panel = null);
            },
            child: list,
          ),
        ),
        if (convo.block != ChatBlock.none)
          _BlockedBanner(
            text: convo.block == ChatBlock.byMe
                ? l10n.chatYouBlocked(friend?.username ?? '')
                : l10n.chatBlockedYou,
            actionLabel:
                convo.block == ChatBlock.byMe ? l10n.chatUnblockShort : null,
            onAction: () => _option(ChatOption.block),
          )
        else
          _Composer(
            controller: _composer,
            focus: _focus,
            sending: _sending,
            editing: _editing,
            onCancelEdit: _cancelEdit,
            replyTo: _replyTo,
            mentionQuery: _mentionQuery,
            members: convo.others(_me),
            onCancelReply: () => setState(() => _replyTo = null),
            onMention: _insertMention,
            onSend: _send,
            onAttach: _attach,
            onEmoji: _togglePanel,
          ),
        if (_panel != null && convo.block == ChatBlock.none)
          EmojiPanel(
            key: ValueKey(_panel is _ReactionPanel),
            emojiOnly: _panel is _ReactionPanel,
            onPick: _picked,
            onClose: () => setState(() => _panel = null),
          ),
      ],
    );

    if (widget.embedded) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: LuxeColors.bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LuxeColors.hair),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(child: titleRow),
                    menu,
                  ],
                ),
              ),
              Divider(height: 1, color: LuxeColors.hair),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: LuxeColors.text,
        titleSpacing: 0,
        title: titleRow,
        actions: [menu],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: LuxeColors.hair),
        ),
      ),
      body: body,
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
          {bool danger = false}) =>
      PopupMenuItem<String>(
        key: Key('chat-menu-$value'),
        value: value,
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: danger ? const Color(0xFFB3402F) : LuxeColors.text),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: danger ? const Color(0xFFB3402F) : LuxeColors.text)),
          ],
        ),
      );
}

/// The message bar: +, the text field, the smiley and send, with the reply
/// being written and member suggestions while typing "@".
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.sending,
    required this.editing,
    required this.onCancelEdit,
    required this.replyTo,
    required this.mentionQuery,
    required this.members,
    required this.onCancelReply,
    required this.onMention,
    required this.onSend,
    required this.onAttach,
    required this.onEmoji,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool sending;
  final ChatMessage? editing;
  final VoidCallback onCancelEdit;
  final ChatMessage? replyTo;
  final String? mentionQuery;
  final List<ChatUser> members;
  final VoidCallback onCancelReply;
  final void Function(String username) onMention;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onEmoji;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = mentionQuery?.toLowerCase();
    final matches = query == null
        ? const <ChatUser>[]
        : members
            .where((m) => m.username.toLowerCase().contains(query))
            .take(5)
            .toList();
    final reply = replyTo;
    final editing = this.editing;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (query != null)
            Container(
              key: const Key('mention-box'),
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(maxHeight: 170),
              decoration: BoxDecoration(
                color: LuxeColors.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: LuxeColors.hair),
              ),
              child: matches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(l10n.chatNoMatch,
                          style: TextStyle(color: LuxeColors.muted)),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final m in matches)
                          MemberRow(
                            key: Key('mention-${m.id}'),
                            user: m,
                            onTap: () => onMention(m.username),
                          ),
                      ],
                    ),
            ),
          if (editing != null)
            Container(
              key: const Key('edit-bar'),
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 2, 2),
              decoration: BoxDecoration(
                color: LuxeColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(BootstrapIcons.pencil,
                      size: 13, color: LuxeColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.chatEditing,
                      style: TextStyle(color: LuxeColors.muted, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-cancel'),
                    tooltip: l10n.chatCancelEdit,
                    iconSize: 14,
                    onPressed: onCancelEdit,
                    icon: Icon(BootstrapIcons.x_lg, color: LuxeColors.text),
                  ),
                ],
              ),
            ),
          if (reply != null && editing == null)
            Container(
              key: const Key('reply-bar'),
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 2, 2),
              decoration: BoxDecoration(
                color: LuxeColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text:
                                '${l10n.chatReplyingTo(reply.sender.username)} '),
                        TextSpan(
                          text: messageSnippet(l10n, reply),
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: LuxeColors.muted, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.chatCancelReply,
                    iconSize: 14,
                    onPressed: onCancelReply,
                    icon: Icon(BootstrapIcons.x_lg, color: LuxeColors.text),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: LuxeColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: LuxeColors.hair),
            ),
            child: Row(
              children: [
                IconButton(
                  key: const Key('chat-attach'),
                  tooltip: l10n.chatAdd,
                  onPressed: editing == null ? onAttach : null,
                  icon: Icon(BootstrapIcons.plus_lg, color: LuxeColors.text),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('chat-composer'),
                    controller: controller,
                    focusNode: focus,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: TextStyle(color: LuxeColors.text),
                    decoration: InputDecoration(
                      hintText: l10n.chatHint,
                      hintStyle: TextStyle(color: LuxeColors.muted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('chat-emoji'),
                  tooltip: l10n.chatEmojiButton,
                  onPressed: onEmoji,
                  icon:
                      Icon(BootstrapIcons.emoji_smile, color: LuxeColors.text),
                ),
                IconButton(
                  key: const Key('chat-send'),
                  tooltip: l10n.chatSend,
                  onPressed: sending ? null : onSend,
                  icon: Icon(BootstrapIcons.send_fill, color: LuxeColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown instead of the composer while either side has blocked the other.
class _BlockedBanner extends StatelessWidget {
  const _BlockedBanner({
    required this.text,
    required this.onAction,
    this.actionLabel,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          key: const Key('chat-blocked-banner'),
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 6, 6),
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: LuxeColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: LuxeColors.hair),
          ),
          child: Row(
            children: [
              Icon(BootstrapIcons.slash_circle,
                  size: 16, color: LuxeColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text, style: TextStyle(color: LuxeColors.muted)),
              ),
              if (actionLabel case final label?)
                TextButton(
                  key: const Key('chat-unblock'),
                  onPressed: onAction,
                  child: Text(label, style: TextStyle(color: LuxeColors.text)),
                ),
            ],
          ),
        ),
      );
}
