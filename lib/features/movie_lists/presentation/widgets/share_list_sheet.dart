import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../home/views/widgets/take_summary_card.dart' show absoluteApiUrl;
import '../../../social/data/social_models.dart';
import '../../../social/data/social_repository.dart';
import '../../data/movie_list.dart';
import '../../data/movie_list_repository.dart';

/// Pick friends (and add a note) to send [list] to. It lands in your chat
/// with each of them as a card that opens the list. Shows "Sent to N
/// friends" when done.
Future<void> showShareListSheet(
  BuildContext context, {
  required MovieList list,
  required MovieListRepository repository,
  SocialRepository? social,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final sent = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LuxeColors.surface,
    showDragHandle: true,
    builder: (_) => ShareListSheet(
      list: list,
      repository: repository,
      social: social ?? SocialRepository(),
    ),
  );
  if (sent != null && sent > 0) {
    messenger?.showSnackBar(SnackBar(content: Text(l10n.takeShareSent(sent))));
  }
}

class ShareListSheet extends StatefulWidget {
  const ShareListSheet({
    super.key,
    required this.list,
    required this.repository,
    required this.social,
  });

  final MovieList list;
  final MovieListRepository repository;
  final SocialRepository social;

  @override
  State<ShareListSheet> createState() => _ShareListSheetState();
}

class _ShareListSheetState extends State<ShareListSheet> {
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
      final sent = await widget.repository.share(
        widget.list.id,
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

    final Widget body;
    if (_loadFailed) {
      body = Row(
        children: [
          Expanded(
            child: Text(l10n.takeShareFriendsFailed,
                style: TextStyle(color: LuxeColors.muted)),
          ),
          TextButton(onPressed: _load, child: Text(l10n.reviewRetry)),
        ],
      );
    } else if (friends == null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child:
            Center(child: CircularProgressIndicator(color: LuxeColors.accent)),
      );
    } else if (friends.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          l10n.listShareNoFriends,
          textAlign: TextAlign.center,
          style: TextStyle(color: LuxeColors.muted, fontSize: 14),
        ),
      );
    } else {
      body = ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .4),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final friend in friends)
              CheckboxListTile(
                key: ValueKey('share-list-friend-${friend.id}'),
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
                title: Text(friend.username,
                    style: TextStyle(color: LuxeColors.text)),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.takeShareTitle,
              style: TextStyle(
                color: LuxeColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.list.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: LuxeColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            body,
            if (friends != null && friends.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextField(
                key: const Key('share-list-message'),
                controller: _message,
                enabled: !_sending,
                maxLength: 280,
                style: TextStyle(color: LuxeColors.text, fontSize: 15),
                decoration: InputDecoration(
                  hintText: l10n.takeShareMessageHint,
                  filled: true,
                  fillColor: LuxeColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_sendFailed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.takeShareFailed,
                    style: const TextStyle(color: Color(0xFFE5484D)),
                  ),
                ),
              FilledButton(
                key: const Key('share-list-send'),
                onPressed: _picked.isEmpty || _sending ? null : _send,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: LuxeColors.text,
                  foregroundColor: LuxeColors.bg,
                ),
                child: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.takeShareSend(_picked.length)),
              ),
            ],
          ],
        ),
      ),
    );
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
          ? Text(name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(color: LuxeColors.text))
          : null,
    );
  }
}
