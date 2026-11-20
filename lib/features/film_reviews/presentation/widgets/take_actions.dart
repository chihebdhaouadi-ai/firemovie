import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../social/data/social_models.dart';
import '../../../social/data/social_repository.dart';
import '../../../home/views/widgets/take_summary_card.dart' show absoluteApiUrl;
import '../../data/api_review_repository.dart';
import '../../data/review_repository.dart';
import '../../data/take_actions_repository.dart';
import '../../domain/report_reason.dart';
import '../../domain/take.dart';
import '../../domain/take_skin.dart';
import '../../domain/take_tag.dart';
import 'spoiler_shield.dart';
import 'take_skin_background.dart';

/// Reviews run long; topics keep the short limit they were posted with.
const _maxReviewLength = 1500;
const _maxTopicLength = 280;

String reportReasonLabel(AppLocalizations l10n, ReportReason reason) =>
    switch (reason) {
      ReportReason.spam => l10n.takeReportSpam,
      ReportReason.harassment => l10n.takeReportHarassment,
      ReportReason.hate => l10n.takeReportHate,
      ReportReason.spoiler => l10n.takeReportSpoiler,
      ReportReason.other => l10n.takeReportOther,
    };

/// The ⋯ button on a take's page. The author can share, edit or delete it;
/// everyone else can share or report it.
class TakeMenuButton extends StatelessWidget {
  const TakeMenuButton({
    super.key,
    required this.take,
    required this.onEdited,
    required this.onDeleted,
    this.actions,
    this.social,
  });

  final Take take;

  /// Called with the saved take after the author edits it.
  final ValueChanged<Take> onEdited;

  /// Called once the author deleted the take.
  final VoidCallback onDeleted;
  final TakeActionsRepository? actions;
  final SocialRepository? social;

  Future<void> _open(BuildContext context) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<_TakeAction>(
      context: context,
      backgroundColor: LuxeColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: BootstrapIcons.send_fill,
              label: l10n.takeActionShare,
              value: _TakeAction.share,
            ),
            if (take.isMine) ...[
              _ActionTile(
                icon: BootstrapIcons.pencil,
                label: l10n.takeActionEdit,
                value: _TakeAction.edit,
              ),
              _ActionTile(
                icon: BootstrapIcons.trash,
                label: l10n.takeActionDelete,
                value: _TakeAction.delete,
                destructive: true,
              ),
            ] else
              _ActionTile(
                icon: BootstrapIcons.flag,
                label: l10n.takeActionReport,
                value: _TakeAction.report,
                destructive: true,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    await _runTakeAction(
      context,
      choice,
      take: take,
      actions: actions,
      social: social,
      onEdited: onEdited,
      onDeleted: onDeleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.takeMenuTooltip,
      onPressed: () => _open(context),
      icon: Icon(BootstrapIcons.three_dots, color: LuxeColors.muted),
    );
  }
}

enum _TakeAction { share, save, edit, delete, report }

/// Runs one take action: the same whether it comes from the ⋯ sheet on a
/// review or the ⋯ options in the top right of a take's page. Save is handled
/// by the page's options button itself, since it keeps the bookmark state.
Future<void> _runTakeAction(
  BuildContext context,
  _TakeAction choice, {
  required Take take,
  required ValueChanged<Take> onEdited,
  required VoidCallback onDeleted,
  TakeActionsRepository? actions,
  SocialRepository? social,
}) async {
  final repository = actions ?? ApiTakeActionsRepository();
  switch (choice) {
    case _TakeAction.share:
      await showShareTakeSheet(
        context,
        take: take,
        actions: repository,
        social: social ?? SocialRepository(),
      );
    case _TakeAction.save:
      return;
    case _TakeAction.edit:
      final saved = await showEditTakeSheet(
        context,
        take: take,
        actions: repository,
      );
      if (saved != null) onEdited(saved);
    case _TakeAction.delete:
      final deleted = await confirmDeleteTake(
        context,
        take: take,
        actions: repository,
      );
      if (deleted) onDeleted();
    case _TakeAction.report:
      await showReportTakeSheet(context, take: take, actions: repository);
  }
}

/// The take's options in the top right of its page: one ⋯ button that opens
/// a sheet. Share for everyone; the owner also gets Edit and Delete; anyone
/// else can save (bookmark) or report it.
class TakeTopActions extends StatefulWidget {
  const TakeTopActions({
    super.key,
    required this.take,
    required this.onEdited,
    required this.onDeleted,
    this.actions,
    this.social,
    this.reviews,
    this.onSaved,
  });

  final Take take;
  final ValueChanged<Take> onEdited;
  final VoidCallback onDeleted;
  final TakeActionsRepository? actions;
  final SocialRepository? social;

  /// Where Save goes; the real API when left out.
  final ReviewRepository? reviews;

  /// Called with the take once a save or unsave went through.
  final ValueChanged<Take>? onSaved;

  @override
  State<TakeTopActions> createState() => _TakeTopActionsState();
}

class _TakeTopActionsState extends State<TakeTopActions> {
  late bool _saved = widget.take.isSaved;
  bool _saving = false;

  @override
  void didUpdateWidget(covariant TakeTopActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_saving && widget.take.isSaved != oldWidget.take.isSaved) {
      _saved = widget.take.isSaved;
    }
  }

  /// Save, as a bookmark: flips at once and saves in the background, going
  /// back if the server refuses. Saved takes show on your profile.
  Future<void> _toggleSave() async {
    if (_saving) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final saved = !_saved;
    setState(() {
      _saving = true;
      _saved = saved;
    });
    try {
      final updated = await (widget.reviews ?? ApiReviewRepository())
          .setSaved(widget.take.id, active: saved);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = updated.isSaved;
      });
      widget.onSaved?.call(updated);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(saved ? l10n.takeSavedToast : l10n.takeUnsavedToast),
        ));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = !saved;
      });
      messenger?.showSnackBar(SnackBar(content: Text(l10n.takeSaveFailed)));
    }
  }

  Future<void> _open() async {
    final l10n = context.l10n;
    final take = widget.take;
    final choice = await showModalBottomSheet<_TakeAction>(
      context: context,
      backgroundColor: LuxeColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              key: const Key('take-top-share'),
              icon: BootstrapIcons.send,
              label: l10n.takeActionShare,
              value: _TakeAction.share,
            ),
            if (take.isMine) ...[
              _ActionTile(
                key: const Key('take-top-edit'),
                icon: BootstrapIcons.pencil,
                label: l10n.takeActionEdit,
                value: _TakeAction.edit,
              ),
              _ActionTile(
                key: const Key('take-top-delete'),
                icon: BootstrapIcons.trash,
                label: l10n.takeActionDelete,
                value: _TakeAction.delete,
                destructive: true,
              ),
            ] else ...[
              _ActionTile(
                key: const Key('take-top-save'),
                icon: _saved
                    ? BootstrapIcons.bookmark_fill
                    : BootstrapIcons.bookmark,
                label: _saved ? l10n.takeActionUnsave : l10n.takeActionSave,
                value: _TakeAction.save,
              ),
              _ActionTile(
                key: const Key('take-top-report'),
                icon: BootstrapIcons.flag,
                label: l10n.takeActionReport,
                value: _TakeAction.report,
                destructive: true,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == _TakeAction.save) {
      await _toggleSave();
      return;
    }
    await _runTakeAction(
      context,
      choice,
      take: take,
      actions: widget.actions,
      social: widget.social,
      onEdited: widget.onEdited,
      onDeleted: widget.onDeleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('take-top-menu'),
      tooltip: context.l10n.takeMenuTooltip,
      onPressed: _open,
      icon: Icon(BootstrapIcons.three_dots, color: LuxeColors.text, size: 22),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final _TakeAction value;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? themed(const Color(0xFFFF6B6B), const Color(0xFFB3261E))
        : LuxeColors.text;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

/// Sheet padding that keeps content above the keyboard.
Widget _sheet(BuildContext context, List<Widget> children) {
  return Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

Text _sheetTitle(String text) => Text(
      text,
      style: TextStyle(
        color: LuxeColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );

InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: LuxeColors.muted),
      counterStyle: TextStyle(color: LuxeColors.muted, fontSize: 11),
      filled: true,
      fillColor: LuxeColors.surface2,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    );

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      backgroundColor: LuxeColors.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: builder,
    );

void _snack(ScaffoldMessengerState? messenger, String message) =>
    messenger?.showSnackBar(SnackBar(content: Text(message)));

// ---------------------------------------------------------------- edit

/// Lets the author rewrite their take and change its skin. Returns the saved
/// take, or null when dismissed or saving failed.
Future<Take?> showEditTakeSheet(
  BuildContext context, {
  required Take take,
  required TakeActionsRepository actions,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final saved = await _showSheet<Take>(
    context,
    (_) => _EditTakeSheet(take: take, actions: actions),
  );
  if (saved != null) _snack(messenger, l10n.takeEditSaved);
  return saved;
}

class _EditTakeSheet extends StatefulWidget {
  const _EditTakeSheet({required this.take, required this.actions});

  final Take take;
  final TakeActionsRepository actions;

  @override
  State<_EditTakeSheet> createState() => _EditTakeSheetState();
}

class _EditTakeSheetState extends State<_EditTakeSheet> {
  late final _controller = TextEditingController(text: widget.take.body);
  late TakeSkin _skin = widget.take.skin;
  late bool _spoiler = widget.take.spoiler;
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _changed =>
      _controller.text.trim() != widget.take.body ||
      _skin != widget.take.skin ||
      _spoiler != widget.take.spoiler;

  Future<void> _save() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _saving || !_changed) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final saved = await widget.actions.editTake(
        widget.take.id,
        body: body,
        skin: _skin,
        spoiler: _spoiler,
      );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxLength =
        widget.take.tag == TakeTag.review ? _maxReviewLength : _maxTopicLength;

    return _sheet(context, [
      _sheetTitle(l10n.takeEditTitle),
      const SizedBox(height: 16),
      TakeSkinPicker(
        selected: _skin,
        enabled: !_saving,
        onChanged: (skin) => setState(() => _skin = skin),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => SpoilerShield(
          key: ValueKey(_spoiler),
          hidden: _spoiler,
          child: TakeSkinPreview(skin: _skin, text: value.text),
        ),
      ),
      const SizedBox(height: 12),
      SpoilerChoice(
        value: _spoiler,
        enabled: !_saving,
        onChanged: (value) => setState(() => _spoiler = value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _controller,
        enabled: !_saving,
        minLines: 3,
        maxLines: 10,
        maxLength: maxLength,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: LuxeColors.text, fontSize: 16),
        decoration: _fieldDecoration(l10n.reviewWhyHint),
      ),
      if (_failed)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.takeEditFailed,
            style: TextStyle(
                color: themed(const Color(0xFFFF6B6B), const Color(0xFFB3261E)),
                fontSize: 13),
          ),
        ),
      FilledButton(
        onPressed: _saving || !_changed || _controller.text.trim().isEmpty
            ? null
            : _save,
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.takeEditSave),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- delete

/// Asks the author to confirm, then deletes the take. Returns true once
/// deleted.
Future<bool> confirmDeleteTake(
  BuildContext context, {
  required Take take,
  required TakeActionsRepository actions,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: LuxeColors.surface,
      title: Text(l10n.takeDeleteTitle),
      content: Text(l10n.takeDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.takeCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
              foregroundColor:
                  themed(const Color(0xFFFF6B6B), const Color(0xFFB3261E))),
          child: Text(l10n.takeActionDelete),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  try {
    await actions.deleteTake(take.id);
  } catch (_) {
    _snack(messenger, l10n.takeDeleteFailed);
    return false;
  }
  _snack(messenger, l10n.takeDeleted);
  return true;
}

// ---------------------------------------------------------------- report

/// Lets a viewer report someone else's take with a reason.
Future<void> showReportTakeSheet(
  BuildContext context, {
  required Take take,
  required TakeActionsRepository actions,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final sent = await _showSheet<bool>(
    context,
    (_) => _ReportTakeSheet(take: take, actions: actions),
  );
  if (sent == true) _snack(messenger, l10n.takeReportThanks);
}

class _ReportTakeSheet extends StatefulWidget {
  const _ReportTakeSheet({required this.take, required this.actions});

  final Take take;
  final TakeActionsRepository actions;

  @override
  State<_ReportTakeSheet> createState() => _ReportTakeSheetState();
}

class _ReportTakeSheetState extends State<_ReportTakeSheet> {
  final _details = TextEditingController();
  ReportReason? _reason;
  bool _sending = false;
  bool _failed = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null || _sending) return;
    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      await widget.actions.reportTake(
        widget.take.id,
        reason: reason,
        details: _details.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _sheet(context, [
      _sheetTitle(l10n.takeReportTitle),
      const SizedBox(height: 6),
      Text(
        l10n.takeReportHint,
        style: TextStyle(color: LuxeColors.muted, fontSize: 14),
      ),
      const SizedBox(height: 8),
      RadioGroup<ReportReason>(
        groupValue: _reason,
        onChanged: (value) {
          if (!_sending) setState(() => _reason = value);
        },
        child: Column(
          children: [
            for (final reason in ReportReason.values)
              RadioListTile<ReportReason>(
                value: reason,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  reportReasonLabel(l10n, reason),
                  style: TextStyle(color: LuxeColors.text),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: _details,
        enabled: !_sending,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        style: TextStyle(color: LuxeColors.text, fontSize: 15),
        decoration: _fieldDecoration(l10n.takeReportDetailsHint),
      ),
      if (_failed)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.takeReportFailed,
            style: TextStyle(
                color: themed(const Color(0xFFFF6B6B), const Color(0xFFB3261E)),
                fontSize: 13),
          ),
        ),
      FilledButton(
        onPressed: _reason == null || _sending ? null : _send,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: const Color(0xFFE5484D),
        ),
        child: _sending
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.takeReportSend),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- share

/// Lets the viewer pick friends (and add a note) to send the take to.
Future<void> showShareTakeSheet(
  BuildContext context, {
  required Take take,
  required TakeActionsRepository actions,
  required SocialRepository social,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final sent = await _showSheet<int>(
    context,
    (_) => _ShareTakeSheet(take: take, actions: actions, social: social),
  );
  if (sent != null && sent > 0) _snack(messenger, l10n.takeShareSent(sent));
}

class _ShareTakeSheet extends StatefulWidget {
  const _ShareTakeSheet({
    required this.take,
    required this.actions,
    required this.social,
  });

  final Take take;
  final TakeActionsRepository actions;
  final SocialRepository social;

  @override
  State<_ShareTakeSheet> createState() => _ShareTakeSheetState();
}

class _ShareTakeSheetState extends State<_ShareTakeSheet> {
  final _message = TextEditingController();
  final Set<int> _picked = {};
  List<SocialUser>? _friends;
  bool _loadFailed = false;
  bool _sending = false;
  bool _sendFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final connections = await widget.social.connections();
      if (!mounted) return;
      setState(() => _friends = connections.friends);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _send() async {
    if (_picked.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    try {
      final sent = await widget.actions.shareTake(
        widget.take.id,
        recipientIds: _picked.toList(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(sent);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final friends = _friends;

    final Widget list;
    if (_loadFailed) {
      list = Row(
        children: [
          Expanded(
            child: Text(
              l10n.takeShareFriendsFailed,
              style: TextStyle(color: LuxeColors.muted),
            ),
          ),
          TextButton(onPressed: _load, child: Text(l10n.reviewRetry)),
        ],
      );
    } else if (friends == null) {
      list = Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: LuxeColors.accent),
        ),
      );
    } else if (friends.isEmpty) {
      list = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          l10n.takeShareNoFriends,
          textAlign: TextAlign.center,
          style: TextStyle(color: LuxeColors.muted, fontSize: 14),
        ),
      );
    } else {
      list = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .4,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final friend in friends)
              CheckboxListTile(
                key: ValueKey('share-friend-${friend.id}'),
                value: _picked.contains(friend.id),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: _sending
                    ? null
                    : (checked) => setState(() {
                          if (checked ?? false) {
                            _picked.add(friend.id);
                          } else {
                            _picked.remove(friend.id);
                          }
                        }),
                secondary: _FriendAvatar(user: friend),
                title: Text(
                  friend.username,
                  style: TextStyle(color: LuxeColors.text),
                ),
              ),
          ],
        ),
      );
    }

    return _sheet(context, [
      _sheetTitle(l10n.takeShareTitle),
      const SizedBox(height: 12),
      TakeSkinPreview(skin: widget.take.skin, text: widget.take.body),
      const SizedBox(height: 12),
      list,
      if (friends != null && friends.isNotEmpty) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _message,
          enabled: !_sending,
          maxLength: 280,
          style: TextStyle(color: LuxeColors.text, fontSize: 15),
          decoration: _fieldDecoration(l10n.takeShareMessageHint),
        ),
        if (_sendFailed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.takeShareFailed,
              style: TextStyle(
                  color:
                      themed(const Color(0xFFFF6B6B), const Color(0xFFB3261E)),
                  fontSize: 13),
            ),
          ),
        FilledButton.icon(
          onPressed: _picked.isEmpty || _sending ? null : _send,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          icon: _sending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(BootstrapIcons.send_fill, size: 18),
          label: Text(l10n.takeShareSend(_picked.length)),
        ),
      ],
    ]);
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.user});

  final SocialUser user;

  @override
  Widget build(BuildContext context) {
    final url = absoluteApiUrl(user.avatarUrl);
    final name = user.username;
    return CircleAvatar(
      radius: 18,
      backgroundColor: LuxeColors.accentLo,
      backgroundImage: url == null ? null : CachedNetworkImageProvider(url),
      child: url == null
          ? Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(color: LuxeColors.text),
            )
          : null,
    );
  }
}
