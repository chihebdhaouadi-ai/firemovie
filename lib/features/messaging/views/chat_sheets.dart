import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../find/data/find_repository.dart';
import '../data/messaging_models.dart';
import 'chat_message_tile.dart';
import 'conversation_avatar.dart';
import 'emoji_panel.dart';

/// Largest photo or video a member may send.
const maxChatFileBytes = 12 * 1024 * 1024;

/// A bottom sheet in the chat style, for sheets built in other files.
Future<T?> showChatSheet<T>(BuildContext context, WidgetBuilder builder) =>
    _sheet<T>(context, builder);

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LuxeColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .88,
            ),
            child: builder(context),
          ),
        ),
      ),
    );

/// The common look of a sheet: a title, an optional line under it and the
/// content, scrolling when tall.
class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    this.title,
    this.leading,
    this.body,
    required this.children,
  });

  final String? title;
  final Widget? leading;
  final String? body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        color: LuxeColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                style: TextStyle(
                    color: LuxeColors.muted, fontSize: 14, height: 1.45),
              ),
            ],
            for (final child in children) ...[
              const SizedBox(height: 12),
              child,
            ],
          ],
        ),
      );
}

/// A bordered choice with a bold label and a grey explanation.
class SheetOption extends StatelessWidget {
  const SheetOption({
    super.key,
    required this.label,
    this.detail,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final String? detail;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: LuxeColors.hair),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: danger ? const Color(0xFFB3402F) : LuxeColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(detail!,
                      style: TextStyle(
                          color: LuxeColors.muted, fontSize: 14, height: 1.4)),
                ],
              ],
            ),
          ),
        ),
      );
}

/// A full-width pill button: filled, outlined, or red for risky actions.
class SheetButton extends StatelessWidget {
  const SheetButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fill = danger
        ? const Color(0xFFB3402F)
        : outlined
            ? Colors.transparent
            : LuxeColors.text;
    final ink = danger
        ? Colors.white
        : outlined
            ? LuxeColors.text
            : LuxeColors.bg;
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: fill,
        shape: StadiumBorder(
          side: BorderSide(color: outlined ? LuxeColors.hair : fill),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: ink, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// A member to pick: avatar, name, and an optional trailing widget.
class MemberRow extends StatelessWidget {
  const MemberRow({
    super.key,
    required this.user,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  final ChatUser user;
  final VoidCallback? onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? LuxeColors.surface : null,
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? Border.all(color: LuxeColors.text, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                AvatarFrame(
                  size: 38,
                  avatarUrl: user.avatarUrl,
                  initial: user.initial,
                  framed: false,
                  animate: false,
                  ringWidth: 0,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(user.username,
                      style: TextStyle(color: LuxeColors.text, fontSize: 15)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      );
}

/// Asks to type [groupName] exactly before the risky action turns on.
Future<bool> confirmTyped(
  BuildContext context, {
  required String title,
  required String body,
  required String groupName,
  required String confirmLabel,
  bool danger = true,
}) async =>
    await _sheet<bool>(
      context,
      (context) => _TypedConfirm(
        title: title,
        body: body,
        groupName: groupName,
        confirmLabel: confirmLabel,
        danger: danger,
      ),
    ) ??
    false;

class _TypedConfirm extends StatefulWidget {
  const _TypedConfirm({
    required this.title,
    required this.body,
    required this.groupName,
    required this.confirmLabel,
    required this.danger,
  });

  final String title;
  final String body;
  final String groupName;
  final String confirmLabel;
  final bool danger;

  @override
  State<_TypedConfirm> createState() => _TypedConfirmState();
}

class _TypedConfirmState extends State<_TypedConfirm> {
  bool _ok = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetBody(
      title: widget.title,
      body: widget.body,
      children: [
        Text(
          l10n.confirmType(widget.groupName),
          style: TextStyle(color: LuxeColors.muted, fontSize: 14),
        ),
        TextField(
          key: const Key('confirm-type-field'),
          autofocus: true,
          onChanged: (value) => setState(() => _ok =
              value.trim().toLowerCase() ==
                  widget.groupName.trim().toLowerCase()),
          style: TextStyle(color: LuxeColors.text),
          decoration: _fieldDecoration(widget.groupName),
        ),
        SheetButton(
          key: const Key('confirm-type-button'),
          label: widget.confirmLabel,
          danger: widget.danger,
          onTap: _ok ? () => Navigator.of(context).pop(true) : null,
        ),
        SheetButton(
          label: l10n.chatBack,
          outlined: true,
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: LuxeColors.muted),
      filled: true,
      fillColor: LuxeColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: LuxeColors.hair),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: LuxeColors.hair),
      ),
    );

/// What the + button adds.
enum AttachChoice { photo, video, movie, poll }

Future<AttachChoice?> showAttachSheet(BuildContext context) {
  final l10n = context.l10n;
  return _sheet<AttachChoice>(
    context,
    (context) => SheetBody(
      title: l10n.chatAddTitle,
      children: [
        for (final (choice, label, detail) in [
          (AttachChoice.photo, l10n.chatPhoto, l10n.chatPhotoBody),
          (AttachChoice.video, l10n.chatVideo, l10n.chatVideoBody),
          (AttachChoice.movie, l10n.chatMovie, l10n.chatMovieBody),
          (AttachChoice.poll, l10n.chatPoll, l10n.chatPollBody),
        ])
          SheetOption(
            key: Key('attach-${choice.name}'),
            label: label,
            detail: detail,
            onTap: () => Navigator.of(context).pop(choice),
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

/// Finds films by title for the movie card.
typedef MovieSearch = Future<List<SharedMovie>> Function(String query);

Future<List<SharedMovie>> searchFilms(String query) async {
  final page = await FindRepository().search(query);
  return [
    for (final movie in page.results.take(12))
      SharedMovie(
        id: movie.id,
        title: movie.title,
        year: movie.year?.toString() ?? '',
        posterUrl: movie.posterUrl,
      ),
  ];
}

Future<SharedMovie?> showMovieSearch(
  BuildContext context, {
  MovieSearch search = searchFilms,
}) =>
    _sheet<SharedMovie>(context, (context) => _MovieSearch(search: search));

class _MovieSearch extends StatefulWidget {
  const _MovieSearch({required this.search});

  final MovieSearch search;

  @override
  State<_MovieSearch> createState() => _MovieSearchState();
}

class _MovieSearchState extends State<_MovieSearch> {
  Timer? _debounce;
  List<SharedMovie> _results = const [];
  bool _searched = false;
  int _generation = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(query));
  }

  Future<void> _run(String query) async {
    final q = query.trim();
    final generation = ++_generation;
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _searched = false;
      });
      return;
    }
    try {
      final results = await widget.search(q);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    } on Exception {
      if (mounted) setState(() => _searched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetBody(
      title: l10n.chatSearchMovie,
      children: [
        TextField(
          key: const Key('movie-search-field'),
          autofocus: true,
          onChanged: _changed,
          style: TextStyle(color: LuxeColors.text),
          decoration: _fieldDecoration(l10n.chatSearchMovieHint),
        ),
        if (_searched && _results.isEmpty)
          Text(l10n.chatNoMovie,
              textAlign: TextAlign.center,
              style: TextStyle(color: LuxeColors.muted)),
        for (final movie in _results)
          InkWell(
            key: Key('movie-result-${movie.id ?? movie.title}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).pop(movie),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 38,
                      height: 54,
                      child: movie.posterUrl == null
                          ? ColoredBox(color: LuxeColors.surface)
                          : CachedNetworkImage(
                              imageUrl: movie.posterUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  ColoredBox(color: LuxeColors.surface),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      movie.year.isEmpty
                          ? movie.title
                          : '${movie.title} (${movie.year})',
                      style: TextStyle(color: LuxeColors.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SheetButton(
          label: l10n.chatBack,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// The send screen for a photo, video, movie or poll: a preview (or the
/// poll's question and options), a caption, and the reactions members may
/// use on the post (at least one stays on).
Future<OutgoingPost?> showPostSheet(
  BuildContext context, {
  required MessageKind kind,
  XFile? file,
  Uint8List? previewBytes,
  SharedMovie? movie,
  int? replyTo,
}) =>
    _sheet<OutgoingPost>(
      context,
      (context) => _PostSheet(
        kind: kind,
        file: file,
        previewBytes: previewBytes,
        movie: movie,
        replyTo: replyTo,
      ),
    );

class _PostSheet extends StatefulWidget {
  const _PostSheet({
    required this.kind,
    this.file,
    this.previewBytes,
    this.movie,
    this.replyTo,
  });

  final MessageKind kind;
  final XFile? file;
  final Uint8List? previewBytes;
  final SharedMovie? movie;
  final int? replyTo;

  @override
  State<_PostSheet> createState() => _PostSheetState();
}

class _PostSheetState extends State<_PostSheet> {
  final _caption = TextEditingController();
  final _question = TextEditingController();
  final _options = [TextEditingController(), TextEditingController()];
  final _allowed = [...defaultReactions];
  String? _error;

  @override
  void dispose() {
    _caption.dispose();
    _question.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  void _toggle(String emoji) {
    setState(() {
      if (_allowed.contains(emoji)) {
        if (_allowed.length > 1) _allowed.remove(emoji);
      } else {
        _allowed.add(emoji);
      }
    });
  }

  void _send() {
    final l10n = context.l10n;
    final options = [
      for (final o in _options)
        if (o.text.trim().isNotEmpty) o.text.trim(),
    ];
    if (widget.kind == MessageKind.poll &&
        (_question.text.trim().isEmpty || options.length < 2)) {
      setState(() => _error = l10n.chatPollInvalid);
      return;
    }
    Navigator.of(context).pop(OutgoingPost(
      kind: widget.kind,
      body: widget.kind == MessageKind.poll ? '' : _caption.text.trim(),
      replyTo: widget.replyTo,
      file: widget.file,
      movie: widget.movie,
      pollQuestion: _question.text.trim(),
      pollOptions: options,
      allowedReactions: [..._allowed],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (widget.kind) {
      MessageKind.photo => l10n.chatSendPhoto,
      MessageKind.video => l10n.chatSendVideo,
      MessageKind.movie => l10n.chatShareMovie,
      _ => l10n.chatNewPoll,
    };
    final preview = <Widget>[
      if (widget.kind == MessageKind.photo && widget.previewBytes != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(widget.previewBytes!,
              height: 200, fit: BoxFit.cover),
        ),
      if (widget.kind == MessageKind.video)
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A18),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.file?.name ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      if (widget.movie != null)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: MovieCard(movie: widget.movie!),
        ),
      if (widget.kind == MessageKind.poll) ...[
        TextField(
          key: const Key('poll-question'),
          controller: _question,
          maxLength: 200,
          style: TextStyle(color: LuxeColors.text),
          decoration:
              _fieldDecoration(l10n.chatPollQuestion).copyWith(counterText: ''),
        ),
        for (var i = 0; i < _options.length; i++)
          TextField(
            key: Key('poll-option-field-$i'),
            controller: _options[i],
            maxLength: 80,
            style: TextStyle(color: LuxeColors.text),
            decoration: _fieldDecoration(l10n.chatPollOption(i + 1))
                .copyWith(counterText: ''),
          ),
        if (_options.length < 4)
          SheetButton(
            key: const Key('poll-add-option'),
            label: l10n.chatAddOption,
            outlined: true,
            onTap: () => setState(() => _options.add(TextEditingController())),
          ),
      ],
    ];
    return SheetBody(
      title: title,
      children: [
        ...preview,
        if (widget.kind != MessageKind.poll)
          TextField(
            key: const Key('post-caption'),
            controller: _caption,
            maxLength: 2000,
            style: TextStyle(color: LuxeColors.text),
            decoration:
                _fieldDecoration(l10n.chatCaption).copyWith(counterText: ''),
          ),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${l10n.chatAllowedReactions}\n',
              style: TextStyle(
                  color: LuxeColors.text, fontWeight: FontWeight.w700),
            ),
            TextSpan(text: l10n.chatAllowedReactionsBody),
          ]),
          style: TextStyle(color: LuxeColors.muted, fontSize: 14, height: 1.4),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final emoji in reactionPool)
              Semantics(
                button: true,
                selected: _allowed.contains(emoji),
                child: GestureDetector(
                  key: Key('allow-$emoji'),
                  onTap: () => _toggle(emoji),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: LuxeColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _allowed.contains(emoji)
                            ? LuxeColors.text
                            : LuxeColors.hair,
                        width: _allowed.contains(emoji) ? 2 : 1,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
          ],
        ),
        if (_error != null)
          Text(_error!,
              style: const TextStyle(color: Color(0xFFB3402F), fontSize: 14)),
        SheetButton(
          key: const Key('post-send'),
          label: context.l10n.chatSend,
          onTap: _send,
        ),
        SheetButton(
          label: l10n.chatBack,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Picks a conversation to share the group to.
Future<Conversation?> showShareSheet(
  BuildContext context, {
  required List<Conversation> targets,
  required int? meId,
}) {
  final l10n = context.l10n;
  return _sheet<Conversation>(
    context,
    (context) => SheetBody(
      title: l10n.chatShareGroup,
      body: l10n.chatShareBody,
      children: [
        for (final target in targets)
          InkWell(
            key: Key('share-${target.id}'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pop(target),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  ConversationAvatar(
                      conversation: target, meId: meId, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(target.title,
                        style: TextStyle(color: LuxeColors.text)),
                  ),
                ],
              ),
            ),
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

/// Asks why the group is being reported; true once a reason is picked.
/// Why a chat or message is reported; returns the reason sent to the server
/// ("spam", "harassment", "hate", "nsfw" or "other"), or null.
Future<String?> showReportSheet(BuildContext context, {String? title}) {
  final l10n = context.l10n;
  return _sheet<String>(
    context,
    (context) => SheetBody(
      title: title ?? l10n.chatReportTitle,
      body: l10n.chatReportBody,
      children: [
        for (final (reason, label) in [
          ('spam', l10n.chatReportSpam),
          ('harassment', l10n.chatReportHarassment),
          ('hate', l10n.chatReportHate),
          ('nsfw', l10n.chatReportNsfw),
          ('other', l10n.chatReportOther),
        ])
          SheetOption(
            key: Key('report-$reason'),
            label: label,
            onTap: () => Navigator.of(context).pop(reason),
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

/// How the owner leaves: hand the group to someone, or let members vote.
enum LeavePath { pass, vote }

Future<LeavePath?> showCreatorLeaveSheet(BuildContext context) {
  final l10n = context.l10n;
  return _sheet<LeavePath>(
    context,
    (context) => SheetBody(
      title: l10n.leaveCreatorTitle,
      body: l10n.leaveCreatorBody,
      children: [
        SheetOption(
          key: const Key('leave-pass'),
          label: l10n.leavePass,
          detail: l10n.leavePassBody,
          onTap: () => Navigator.of(context).pop(LeavePath.pass),
        ),
        SheetOption(
          key: const Key('leave-vote'),
          label: l10n.leaveVote,
          detail: l10n.leaveVoteBody,
          onTap: () => Navigator.of(context).pop(LeavePath.vote),
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

/// Picks who takes the group over.
Future<ChatUser?> showPickOwnerSheet(
  BuildContext context, {
  required List<ChatUser> members,
}) =>
    _sheet<ChatUser>(context, (context) => _PickOwner(members: members));

class _PickOwner extends StatefulWidget {
  const _PickOwner({required this.members});

  final List<ChatUser> members;

  @override
  State<_PickOwner> createState() => _PickOwnerState();
}

class _PickOwnerState extends State<_PickOwner> {
  ChatUser? _picked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetBody(
      title: l10n.leavePickTitle,
      body: l10n.leavePickBody,
      children: [
        for (final member in widget.members)
          MemberRow(
            key: Key('pick-owner-${member.id}'),
            user: member,
            selected: _picked == member,
            onTap: () => setState(() => _picked = member),
          ),
        SheetButton(
          key: const Key('pick-owner-continue'),
          label: l10n.leaveContinue,
          onTap:
              _picked == null ? null : () => Navigator.of(context).pop(_picked),
        ),
        SheetButton(
          label: l10n.chatBack,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// What can be done with a member from their sheet.
enum MemberAction { profile, heritage, remove }

Future<MemberAction?> showMemberSheet(
  BuildContext context, {
  required ChatUser member,
  required bool isHeritage,
  required bool canManage,
}) {
  final l10n = context.l10n;
  return _sheet<MemberAction>(
    context,
    (context) => SheetBody(
      title: member.username,
      leading: AvatarFrame(
        size: 38,
        avatarUrl: member.avatarUrl,
        initial: member.initial,
        framed: false,
        animate: false,
        ringWidth: 0,
      ),
      children: [
        if (isHeritage)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: MemberTag(text: l10n.groupInfoHeritage),
          ),
        SheetOption(
          key: const Key('member-profile'),
          label: l10n.chatViewProfile,
          detail: l10n.memberViewProfileBody(member.username),
          onTap: () => Navigator.of(context).pop(MemberAction.profile),
        ),
        if (canManage) ...[
          SheetOption(
            key: const Key('member-heritage'),
            label: l10n.memberMakeHeritage,
            detail: l10n.memberMakeHeritageBody(member.username),
            onTap: () => Navigator.of(context).pop(MemberAction.heritage),
          ),
          SheetOption(
            key: const Key('member-remove'),
            label: l10n.memberRemove,
            detail: l10n.memberRemoveBody(member.username),
            danger: true,
            onTap: () => Navigator.of(context).pop(MemberAction.remove),
          ),
        ],
        SheetButton(
          label: l10n.chatClose,
          outlined: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// The small rounded tag ("Creator", "Heritage creator").
class MemberTag extends StatelessWidget {
  const MemberTag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: LuxeColors.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: LuxeColors.hair),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: LuxeColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

/// What was chosen on a held message.
sealed class HoldResult {
  const HoldResult();
}

final class HoldReact extends HoldResult {
  const HoldReact(this.emoji);
  final String emoji;
}

final class HoldMoreReactions extends HoldResult {
  const HoldMoreReactions();
}

final class HoldReply extends HoldResult {
  const HoldReply();
}

final class HoldPin extends HoldResult {
  const HoldPin();
}

final class HoldMention extends HoldResult {
  const HoldMention();
}

final class HoldProfile extends HoldResult {
  const HoldProfile();
}

final class HoldCopy extends HoldResult {
  const HoldCopy();
}

final class HoldEdit extends HoldResult {
  const HoldEdit();
}

final class HoldDelete extends HoldResult {
  const HoldDelete();
}

final class HoldReport extends HoldResult {
  const HoldReport();
}

/// Lifts a held message above a dimmed screen, with a bar of reactions above
/// it and a menu below (Telegram style).
Future<HoldResult?> showHoldMenu(
  BuildContext context, {
  required Rect rect,
  required Widget lifted,
  required List<String> reactions,
  required bool allowMore,
  required bool canPin,
  required bool pinned,
  required String? otherName,
  bool canReply = true,
  bool canReact = true,
  bool canCopy = false,
  bool canEdit = false,
  bool canDelete = false,
  bool canReport = false,
}) {
  final l10n = context.l10n;
  return Navigator.of(context).push<HoldResult>(PageRouteBuilder<HoldResult>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, _, __) {
      final size = MediaQuery.sizeOf(context);
      final pad = MediaQuery.paddingOf(context);
      final barWidth = (reactions.length + (allowMore ? 1 : 0)) * 44.0 + 20;
      final menuItems = <(String, HoldResult, Key)>[
        if (canReply)
          (l10n.chatReply, const HoldReply(), const Key('hold-reply')),
        if (canCopy) (l10n.chatCopy, const HoldCopy(), const Key('hold-copy')),
        if (canEdit) (l10n.chatEdit, const HoldEdit(), const Key('hold-edit')),
        if (canPin)
          (
            pinned ? l10n.chatUnpin : l10n.chatPin,
            const HoldPin(),
            const Key('hold-pin'),
          ),
        if (otherName != null) ...[
          (
            l10n.chatMention(otherName),
            const HoldMention(),
            const Key('hold-mention')
          ),
          (
            l10n.chatViewProfile,
            const HoldProfile(),
            const Key('hold-profile')
          ),
        ],
        if (canReport)
          (
            l10n.chatReportMessage,
            const HoldReport(),
            const Key('hold-report')
          ),
        if (canDelete)
          (
            l10n.chatDeleteMessage,
            const HoldDelete(),
            const Key('hold-delete')
          ),
      ];
      final menuHeight = menuItems.length * 44.0 + 12;
      final left = (rect.left + 36).clamp(8.0, size.width - 228);
      final barLeft = (rect.left + 36).clamp(8.0, size.width - barWidth - 8);
      final barTop = (rect.top - 62).clamp(pad.top + 8, size.height - 120);
      final menuTop = (rect.bottom + 8)
          .clamp(pad.top + 70, size.height - pad.bottom - menuHeight - 8);
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: rect.left,
            top: rect.top.clamp(pad.top, size.height - rect.height),
            width: rect.width,
            child: IgnorePointer(
                child:
                    Material(type: MaterialType.transparency, child: lifted)),
          ),
          if (canReact)
            Positioned(
              left: barLeft.toDouble(),
              top: barTop.toDouble(),
              child: Material(
                key: const Key('hold-reactions'),
                color: LuxeColors.bg,
                elevation: 8,
                shape: StadiumBorder(side: BorderSide(color: LuxeColors.hair)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final emoji in reactions)
                        InkWell(
                          key: Key('hold-react-$emoji'),
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              Navigator.of(context).pop(HoldReact(emoji)),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 26)),
                            ),
                          ),
                        ),
                      if (allowMore)
                        Tooltip(
                          message: l10n.chatMoreReactions,
                          child: InkWell(
                            key: const Key('hold-more'),
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context)
                                .pop(const HoldMoreReactions()),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(BootstrapIcons.plus_lg,
                                  color: LuxeColors.text),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: left.toDouble(),
            top: menuTop.toDouble(),
            width: 220,
            child: Material(
              color: LuxeColors.bg,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: LuxeColors.hair),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (label, result, key) in menuItems)
                      InkWell(
                        key: key,
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(result),
                        child: Container(
                          height: 44,
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(label,
                              style: TextStyle(
                                  color: result is HoldDelete
                                      ? const Color(0xFFB3402F)
                                      : LuxeColors.text)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  ));
}
