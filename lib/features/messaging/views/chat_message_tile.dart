import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../data/messaging_models.dart';
import 'chat_video.dart';
import 'emoji_panel.dart';
import 'list_card.dart';
import '../../../core/stable_image_key.dart';
import '../../film_reviews/presentation/open_take.dart';

/// "14:05": the message time on the clock.
String clockTime(DateTime time) {
  final local = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}

/// The words of a system line ("ana pinned a message").
String systemText(AppLocalizations l10n, ChatMessage message, int? meId) {
  final name =
      message.sender.id == meId ? l10n.groupInfoYou : message.sender.username;
  final target = message.eventTarget ?? '';
  return switch (message.event) {
    'pinned' => l10n.sysPinned(name),
    'removed' => l10n.sysRemoved(name, target),
    'left' => l10n.sysLeft(name),
    'heritage' => l10n.sysHeritage(name, target),
    'passed' => l10n.sysPassed(name, target),
    'vote_started' => l10n.sysVoteStarted(name),
    'vote_cancelled' => l10n.sysVoteCancelled(name),
    'vote_keep' => l10n.sysVoteKeep,
    'vote_owner_won' => l10n.sysVoteOwnerWon(target),
    'added' => l10n.sysAdded(name, target),
    _ => '',
  };
}

/// A short description of a message, for reply quotes and the pinned bar.
///
/// [mine] words take cards from the sender's side ("Tagged them...").
String messageSnippet(AppLocalizations l10n, ChatMessage m,
    {bool mine = false}) {
  if (m.deleted) return l10n.chatMessageDeleted;
  if (m.body.isNotEmpty) return m.body;
  return switch (m.kind) {
    MessageKind.gif => l10n.chatGif,
    MessageKind.sticker => l10n.chatSticker,
    MessageKind.photo => l10n.chatPhoto,
    MessageKind.video => l10n.chatVideo,
    MessageKind.movie => m.movie?.title ?? l10n.chatMovie,
    MessageKind.poll => '${l10n.chatPoll}: ${m.poll?.question ?? ''}',
    MessageKind.take => takeCardSnippet(l10n, m.sharedTake, mine: mine),
    MessageKind.list => m.sharedList?.name ?? l10n.chatListShared,
    _ => '',
  };
}

/// "Tagged you in a comment" or the shared take's title, for previews.
String takeCardSnippet(AppLocalizations l10n, SharedTake? take,
    {bool mine = false}) {
  if (take == null) return l10n.chatTopicShared;
  if (take.mention) return mine ? l10n.chatTaggedThem : l10n.chatTaggedYou;
  if (take.title.isNotEmpty) return take.title;
  if (take.body.isNotEmpty) return take.body;
  return take.isTopic ? l10n.chatTopicShared : l10n.chatTakeShared;
}

/// The usernames tagged in [text] with "@name", matched against [members].
List<String> mentionedNames(String text, List<ChatUser> members) {
  final found = <String>[];
  for (final match in RegExp(r'@([\w.]+)').allMatches(text)) {
    final name = match.group(1)!.toLowerCase();
    for (final member in members) {
      if (member.username.toLowerCase() == name &&
          !found.contains(member.username)) {
        found.add(member.username);
      }
    }
  }
  return found;
}

/// A centred grey line telling what happened in the group.
class SystemLine extends StatelessWidget {
  const SystemLine({super.key, required this.message, required this.meId});

  final ChatMessage message;
  final int? meId;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Text(
          systemText(context.l10n, message, meId),
          textAlign: TextAlign.center,
          style: TextStyle(color: LuxeColors.muted, fontSize: 13),
        ),
      );
}

/// One message. Others' messages sit on the start side with their avatar,
/// name and time; my own sit on the end side with just the time, my text in
/// a soft bubble. Grouped messages (same sender in a row) skip the header.
class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.meId,
    required this.members,
    this.grouped = false,
    this.highlighted = false,
    this.lifted = false,
    this.onHold,
    this.onReaction,
    this.onOpenReply,
    this.onMention,
    this.onVote,
    this.onOpenAttachment,
  });

  final ChatMessage message;
  final int? meId;
  final List<ChatUser> members;
  final bool grouped;

  /// Flashes after jumping to it.
  final bool highlighted;

  /// Drawn above the dimmed screen while held.
  final bool lifted;
  final VoidCallback? onHold;
  final ValueChanged<String>? onReaction;
  final ValueChanged<int>? onOpenReply;
  final ValueChanged<String>? onMention;
  final ValueChanged<int>? onVote;
  final ValueChanged<ChatMessage>? onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = message;
    final mine = m.sender.id == meId;
    final content = <Widget>[
      if (!grouped && mine)
        Text(
          clockTime(m.createdAt),
          style: TextStyle(color: LuxeColors.muted, fontSize: 12),
        ),
      if (!grouped && !mine)
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                m.sender.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LuxeColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              clockTime(m.createdAt),
              style: TextStyle(color: LuxeColors.muted, fontSize: 12),
            ),
          ],
        ),
      if (m.pinned)
        Text('📌 ${l10n.chatPinned}',
            style: TextStyle(color: LuxeColors.muted, fontSize: 12)),
      if (m.replyTo case final reply?)
        _ReplyQuote(reply: reply, onTap: () => onOpenReply?.call(reply.id)),
      if (m.deleted)
        Row(
          key: Key('message-deleted-${m.id}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.slash_circle,
                size: 13, color: LuxeColors.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n.chatMessageDeleted,
                style: TextStyle(
                  color: LuxeColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        )
      else ...[
        ..._post(context),
        if (m.body.isNotEmpty)
          mine
              ? Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: LuxeColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MentionText(
                    text: m.body,
                    members: members,
                    onMention: onMention,
                  ),
                )
              : MentionText(
                  text: m.body,
                  members: members,
                  onMention: onMention,
                ),
        if (m.edited)
          Text(
            l10n.chatEdited,
            key: Key('message-edited-${m.id}'),
            style: TextStyle(color: LuxeColors.muted, fontSize: 11),
          ),
      ],
      if (m.reactions.isNotEmpty && !m.deleted)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: mine ? WrapAlignment.end : WrapAlignment.start,
            children: [
              for (final r in m.reactions)
                _ReactionChip(
                  key: Key('reaction-${m.id}-${r.emoji}'),
                  reaction: r,
                  onTap: () => onReaction?.call(r.emoji),
                ),
            ],
          ),
        ),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onHold,
      onSecondaryTap: onHold,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(top: grouped ? 0 : 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: lifted
              ? LuxeColors.bg
              : highlighted
                  ? LuxeColors.surface
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: lifted
              ? Border.all(color: LuxeColors.text, width: 2)
              : m.pinned
                  ? BorderDirectional(
                      start: mine
                          ? BorderSide.none
                          : BorderSide(color: LuxeColors.text, width: 3),
                      end: mine
                          ? BorderSide(color: LuxeColors.text, width: 3)
                          : BorderSide.none,
                    )
                  : null,
        ),
        child: mine
            ? Padding(
                // Keeps my messages from running the full width.
                padding: const EdgeInsetsDirectional.only(start: 56),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: content,
                  ),
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 38,
                    child: grouped
                        ? null
                        : AvatarFrame(
                            size: 38,
                            avatarUrl: m.sender.avatarUrl,
                            initial: m.sender.initial,
                            framed: false,
                            animate: false,
                            ringWidth: 0,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _post(BuildContext context) {
    final m = message;
    Widget spaced(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        );
    switch (m.kind) {
      case MessageKind.gif:
        final gif = gifNamed(m.gif);
        return [if (gif != null) spaced(GifTile(gif: gif, big: true))];
      case MessageKind.sticker:
        return [
          Text(m.sticker ?? '',
              style: const TextStyle(fontSize: 64, height: 1.1)),
        ];
      case MessageKind.photo:
        return [
          spaced(_PhotoView(
            url: m.attachmentUrl,
            onTap: () => onOpenAttachment?.call(m),
          )),
        ];
      case MessageKind.video:
        return [
          spaced(ChatVideo(
            key: ValueKey('video-${m.id}'),
            url: m.attachmentUrl,
          )),
        ];
      case MessageKind.movie:
        final movie = m.movie;
        return [if (movie != null) spaced(MovieCard(movie: movie))];
      case MessageKind.poll:
        final poll = m.poll;
        return [
          if (poll != null)
            spaced(PollCard(
              key: Key('poll-${m.id}'),
              poll: poll,
              onVote: onVote,
            )),
        ];
      case MessageKind.take:
        final take = m.sharedTake;
        return [
          if (take != null)
            spaced(TakeCard(
              key: Key('take-card-${m.id}'),
              take: take,
              mine: m.sender.id == meId,
            )),
        ];
      case MessageKind.list:
        final list = m.sharedList;
        return [
          if (list != null)
            spaced(ListCard(
              key: Key('list-card-${m.id}'),
              list: list,
              mine: m.sender.id == meId,
            )),
        ];
      case MessageKind.text:
      case MessageKind.system:
        return const [];
    }
  }
}

/// Message text with "@name" mentions drawn as tappable chips.
class MentionText extends StatefulWidget {
  const MentionText({
    super.key,
    required this.text,
    required this.members,
    this.onMention,
  });

  final String text;
  final List<ChatUser> members;
  final ValueChanged<String>? onMention;

  @override
  State<MentionText> createState() => _MentionTextState();
}

class _MentionTextState extends State<MentionText> {
  final _taps = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final tap in _taps) {
      tap.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final tap in _taps) {
      tap.dispose();
    }
    _taps.clear();
    final style = TextStyle(color: LuxeColors.text, fontSize: 16, height: 1.4);
    final names = {
      for (final m in widget.members) m.username.toLowerCase(): m.username,
    };
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in RegExp(r'@([\w.]+)').allMatches(widget.text)) {
      final name = names[match.group(1)!.toLowerCase()];
      if (name == null) continue;
      spans.add(TextSpan(text: widget.text.substring(last, match.start)));
      final tap = TapGestureRecognizer()
        ..onTap = () => widget.onMention?.call(name);
      _taps.add(tap);
      spans.add(TextSpan(
        text: '@$name',
        recognizer: tap,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          background: Paint()..color = LuxeColors.text.withValues(alpha: 0.14),
        ),
      ));
      last = match.end;
    }
    spans.add(TextSpan(text: widget.text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.reply, required this.onTap});

  final ReplyPreview reply;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final snippet = reply.snippet.isNotEmpty
        ? reply.snippet
        : switch (reply.kind) {
            MessageKind.gif => l10n.chatGif,
            MessageKind.sticker => l10n.chatSticker,
            MessageKind.photo => l10n.chatPhoto,
            MessageKind.video => l10n.chatVideo,
            _ => '',
          };
    return GestureDetector(
      key: Key('reply-quote-${reply.id}'),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 2, bottom: 4),
        padding: const EdgeInsetsDirectional.only(start: 8),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: LuxeColors.hair, width: 3),
          ),
        ),
        child: Text.rich(
          TextSpan(children: [
            const TextSpan(text: '↳ '),
            TextSpan(
              text: '${reply.sender} ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: snippet),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: LuxeColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({super.key, required this.reaction, required this.onTap});

  final ReactionCount reaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: reaction.me,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: LuxeColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: reaction.me ? LuxeColors.text : LuxeColors.hair,
              ),
            ),
            child: Text(
              '${reaction.emoji} ${reaction.count}',
              style: TextStyle(color: LuxeColors.text, fontSize: 14),
            ),
          ),
        ),
      );
}

class _PhotoView extends StatelessWidget {
  const _PhotoView({required this.url, required this.onTap});

  final String? url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 240,
      height: 160,
      color: LuxeColors.surface,
      alignment: Alignment.center,
      child: Icon(BootstrapIcons.image, color: LuxeColors.muted),
    );
    final url = this.url;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: url == null || !url.startsWith('http')
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                cacheKey: stableImageKey(url),
                width: 240,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

/// A shared film: its poster (or a dark card) with the title and year.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final SharedMovie movie;

  @override
  Widget build(BuildContext context) {
    final poster = movie.posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 220,
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B241C), Color(0xFF1C2833)],
                ),
              ),
            ),
            if (poster != null && poster.startsWith('http'))
              CachedNetworkImage(
                imageUrl: poster,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (movie.year.isNotEmpty)
                    Text(movie.year,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A take or topic sent in the chat. Tapping it opens the topic (and, for a
/// mention, jumps to the comment that tagged you).
class TakeCard extends StatelessWidget {
  const TakeCard({super.key, required this.take, this.mine = false});

  final SharedTake take;

  /// Whether I sent it (the label then speaks from my side).
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = take.mention
        ? (mine ? l10n.chatYouTagged : l10n.chatTaggedYou)
        : mine
            ? (take.isTopic ? l10n.chatYouSharedTopic : l10n.chatYouSharedTake)
            : take.isTopic
                ? l10n.chatTopicShared
                : l10n.chatTakeShared;
    final headline = take.title.isNotEmpty ? take.title : take.body;
    final subline = take.title.isNotEmpty ? take.body : '';
    final comment = take.commentBody;
    final poster = take.posterUrl;
    final filmTitle = take.filmTitle;

    return Semantics(
      button: true,
      child: Material(
        color: LuxeColors.surface2,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openTakeById(
            context,
            take.takeId,
            replyToCommentId: take.commentId,
          ),
          child: SizedBox(
            width: 260,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        take.mention
                            ? BootstrapIcons.at
                            : BootstrapIcons.chat_square_text,
                        size: 13,
                        color: LuxeColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: LuxeColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(BootstrapIcons.chevron_right,
                          size: 12, color: LuxeColors.muted),
                    ],
                  ),
                  if (take.author.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      take.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: LuxeColors.muted, fontSize: 12),
                    ),
                  ],
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: LuxeColors.text,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (subline.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: LuxeColors.muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (comment != null && comment.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          start: BorderSide(color: LuxeColors.hair, width: 2),
                        ),
                      ),
                      child: Text(
                        comment,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LuxeColors.text,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  if (filmTitle != null && filmTitle.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (poster != null && poster.startsWith('http')) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: poster,
                              width: 20,
                              height: 30,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const SizedBox(width: 20, height: 30),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            filmTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LuxeColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A poll: its question and a bar per option that fills with its share of
/// the votes. Tapping an option votes; tapping your vote again clears it.
class PollCard extends StatelessWidget {
  const PollCard({super.key, required this.poll, this.onVote});

  final ChatPoll poll;
  final ValueChanged<int>? onVote;

  @override
  Widget build(BuildContext context) {
    final total = poll.total;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(poll.question,
              style: TextStyle(
                  color: LuxeColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 8),
          for (var i = 0; i < poll.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(
                button: true,
                selected: poll.myVote == i,
                child: GestureDetector(
                  key: Key('poll-option-$i'),
                  onTap: () => onVote?.call(i),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: poll.myVote == i
                            ? LuxeColors.text
                            : LuxeColors.hair,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor:
                                total == 0 ? 0 : poll.votesFor(i) / total,
                            child: Container(color: LuxeColors.hair),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(poll.options[i],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: LuxeColors.text)),
                                ),
                                Text('${poll.votesFor(i)}',
                                    style: TextStyle(color: LuxeColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Text(context.l10n.chatVotes(total),
              style: TextStyle(color: LuxeColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

/// The latest pinned message and how many there are; tapping jumps to each
/// pinned message in turn.
class PinnedBar extends StatelessWidget {
  const PinnedBar({
    super.key,
    required this.pinned,
    required this.onTap,
  });

  final List<ChatMessage> pinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = pinned.last;
    final label = pinned.length > 1
        ? l10n.chatPinnedCount(pinned.length)
        : l10n.chatPinned;
    return Material(
      color: LuxeColors.surface,
      child: InkWell(
        key: const Key('pinned-bar'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: LuxeColors.hair)),
          ),
          child: Row(
            children: [
              const Text('📌'),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$label ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                        text:
                            '${latest.sender.username}: ${messageSnippet(l10n, latest)}'),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: LuxeColors.text, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "23h 59m": how long a vote has left.
String voteTimeLeft(AppLocalizations l10n, DateTime endsAt, DateTime now) {
  final left = endsAt.difference(now);
  final minutes = left.isNegative ? 0 : left.inMinutes;
  return l10n.voteTimeLeft(minutes ~/ 60, minutes % 60);
}

/// The first stage of the owner's leave vote: keep or delete the group.
class KeepVoteCard extends StatelessWidget {
  const KeepVoteCard({
    super.key,
    required this.vote,
    required this.starterName,
    required this.mine,
    required this.onVote,
    required this.onCancel,
    this.now,
  });

  final GroupVoteState vote;
  final String starterName;

  /// Whether I started the vote (I may cancel it but not vote).
  final bool mine;
  final ValueChanged<String> onVote;
  final VoidCallback onCancel;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stay = vote.count('stay');
    final delete = vote.count('delete');
    final total = stay + delete;
    return _VoteCardFrame(
      key: const Key('keep-vote-card'),
      title: l10n.voteKeepTitle,
      children: [
        Text(
          l10n.voteKeepBody(starterName,
              voteTimeLeft(l10n, vote.endsAt, now ?? DateTime.now())),
          style: TextStyle(color: LuxeColors.muted, fontSize: 14, height: 1.45),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (total == 0)
                  Expanded(child: Container(color: LuxeColors.hair))
                else ...[
                  if (stay > 0)
                    Expanded(
                        flex: stay,
                        child: Container(color: const Color(0xFF2F7D4F))),
                  if (delete > 0)
                    Expanded(
                        flex: delete,
                        child: Container(color: const Color(0xFFB3402F))),
                ],
              ],
            ),
          ),
        ),
        Text(l10n.voteKeepTally(stay, delete),
            style: TextStyle(color: LuxeColors.muted, fontSize: 14)),
        Row(
          children: [
            Expanded(
              child: _PillButton(
                key: const Key('vote-stay'),
                label: l10n.voteStay,
                filled: vote.myChoice == 'stay' || vote.myChoice == null,
                onTap: mine ? null : () => onVote('stay'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PillButton(
                key: const Key('vote-delete'),
                label: l10n.voteDelete,
                filled: vote.myChoice == 'delete',
                onTap: mine ? null : () => onVote('delete'),
              ),
            ),
          ],
        ),
        if (mine) ...[
          Text(l10n.voteOwnPoll,
              style: TextStyle(color: LuxeColors.muted, fontSize: 14)),
          _PillButton(
            key: const Key('vote-cancel'),
            label: l10n.voteCancel,
            filled: false,
            onTap: onCancel,
          ),
        ],
      ],
    );
  }
}

/// The second stage: who should own the group.
class OwnerVoteCard extends StatelessWidget {
  const OwnerVoteCard({
    super.key,
    required this.vote,
    required this.candidates,
    required this.meId,
    required this.onVote,
    this.now,
  });

  final GroupVoteState vote;

  /// Everyone who can be picked (not the member who asked to leave).
  final List<ChatUser> candidates;
  final int? meId;
  final ValueChanged<String> onVote;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _VoteCardFrame(
      key: const Key('owner-vote-card'),
      title: l10n.voteOwnerTitle,
      children: [
        Text(
          l10n.voteOwnerBody(
              voteTimeLeft(l10n, vote.endsAt, now ?? DateTime.now())),
          style: TextStyle(color: LuxeColors.muted, fontSize: 14, height: 1.45),
        ),
        for (final member in candidates)
          _CandidateRow(
            member: member,
            votes: vote.count('${member.id}'),
            picked: vote.myChoice == '${member.id}',
            onTap: member.id == meId ? null : () => onVote('${member.id}'),
          ),
        Text(
          vote.myChoice == null ? l10n.voteOwnerHint : l10n.voteOwnerChange,
          style: TextStyle(color: LuxeColors.muted, fontSize: 14),
        ),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.member,
    required this.votes,
    required this.picked,
    required this.onTap,
  });

  final ChatUser member;
  final int votes;
  final bool picked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        selected: picked,
        child: InkWell(
          key: Key('candidate-${member.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: picked ? LuxeColors.bg : null,
              borderRadius: BorderRadius.circular(16),
              border:
                  picked ? Border.all(color: LuxeColors.text, width: 2) : null,
            ),
            child: Row(
              children: [
                AvatarFrame(
                  size: 34,
                  avatarUrl: member.avatarUrl,
                  initial: member.initial,
                  framed: false,
                  animate: false,
                  ringWidth: 0,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(member.username,
                      style: TextStyle(color: LuxeColors.text)),
                ),
                Text(context.l10n.chatVotes(votes),
                    style: TextStyle(color: LuxeColors.muted, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
}

class _VoteCardFrame extends StatelessWidget {
  const _VoteCardFrame(
      {super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuxeColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: TextStyle(
                    color: LuxeColors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            for (final child in children) ...[
              const SizedBox(height: 12),
              child,
            ],
          ],
        ),
      );
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Material(
          color: filled ? LuxeColors.text : Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(color: filled ? LuxeColors.text : LuxeColors.hair),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: filled ? LuxeColors.bg : LuxeColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
