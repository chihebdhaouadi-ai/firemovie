import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/views/home_navigation.dart' show openOverview;
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/film_tile.dart';
import '../../home/views/widgets/take_summary_card.dart';
import '../data/api_review_repository.dart';
import '../../social/data/social_repository.dart';
import '../data/review_repository.dart';
import '../data/take_actions_repository.dart';
import '../domain/film_reaction.dart';
import '../domain/take.dart';
import '../domain/take_tag.dart';
import 'reaction_labels.dart';
import 'widgets/comment_thread.dart';
import 'widgets/take_actions.dart';
import 'widgets/take_heart.dart';
import 'widgets/mention_suggestions.dart';
import '../../social/data/social_models.dart';
import 'widgets/spoiler_shield.dart';
import 'widgets/take_photo.dart';

/// A question or discussion on its own page: the question leads, the movie
/// (if any) sits under it, and the comments follow with like and dislike.
class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.item,
    this.repository,
    this.onTakeChanged,
    this.replyToCommentId,
    this.actions,
    this.social,
  });

  final FeedItem item;
  final ReviewRepository? repository;

  /// Opens with the composer replying to this comment (from a mention).
  final int? replyToCommentId;
  final TakeActionsRepository? actions;
  final SocialRepository? social;

  /// Called with the saved take after a like or dislike on the question.
  final ValueChanged<Take>? onTakeChanged;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  /// Friends offered while typing `@name` in the composer.
  List<SocialUser> _mentionFriends = const [];

  late final ReviewRepository _repository =
      widget.repository ?? ApiReviewRepository();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  List<TakeComment>? _comments;
  bool _loading = true;
  bool _sending = false;
  bool _sendFailed = false;

  /// The photo picked for the next comment, and its bytes for the preview.
  XFile? _photo;
  Uint8List? _photoBytes;

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photo = file;
      _photoBytes = bytes;
    });
  }

  void _removePhoto() => setState(() {
        _photo = null;
        _photoBytes = null;
      });

  /// Height of the pinned "N comments" bar.
  static const _commentsBarHeight = 52.0;

  /// Whether the comments fill the page, with the topic slid away.
  bool _commentsExpanded = false;

  /// Finds the comment opened from a mention, to scroll to it.
  final _focusKey = GlobalKey();

  /// Scrolls the comment that tagged the viewer into view once it is laid out.
  void _scrollToFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _focusKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: .6,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  TakeComment? _replyTo;

  late Take _take = widget.item.take;

  /// Natural height of the pinned topic header, body included.
  double _headerHeight = 0;

  /// Natural height of the topic's body, the part that folds away on scroll.
  double _bodyHeight = 0;

  void _measuredHeader(double height) {
    if ((height - _headerHeight).abs() < 0.5) return;
    setState(() => _headerHeight = height);
  }

  void _measuredBody(double height) {
    if ((height - _bodyHeight).abs() < 0.5) return;
    setState(() => _bodyHeight = height);
  }

  /// Keeps the saved vote on this page and tells the screen that opened it.
  void _takeVoted(Take updated) {
    setState(() => _take = updated);
    widget.onTakeChanged?.call(updated);
  }

  @override
  void initState() {
    super.initState();
    MentionFriends.load(widget.social).then((friends) {
      if (mounted) setState(() => _mentionFriends = friends);
    });
    _loadComments();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _repository.fetchComments(_take.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
        final target = widget.replyToCommentId;
        if (target != null && _replyTo == null) {
          _replyTo = _findComment(target);
        }
      });
      if (widget.replyToCommentId != null) _scrollToFocus();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _retryComments() {
    setState(() => _loading = true);
    _loadComments();
  }

  TakeComment? _findComment(int id) {
    for (final comment in _comments ?? const <TakeComment>[]) {
      if (comment.id == id) return comment;
    }
    return null;
  }

  void _startReply(TakeComment comment) {
    setState(() => _replyTo = comment);
    _inputFocus.requestFocus();
  }

  void _cancelReply() => setState(() => _replyTo = null);

  Future<void> _send() async {
    final body = _input.text.trim();
    final photo = _photo;
    if (body.isEmpty && photo == null) {
      _inputFocus.requestFocus();
      return;
    }
    if (_sending) return;
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    try {
      final comment = await _repository.postComment(
        _take.id,
        body: body,
        parentId: _replyTo?.id,
        image: photo,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _comments = [...?_comments, comment];
        _replyTo = null;
        _photo = null;
        _photoBytes = null;
        _input.clear();
      });
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
    final film = widget.item.film;
    final count = _comments?.length ?? _take.commentCount;

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _take.tag == TakeTag.review
              ? l10n.reviewDetailTitle
              : l10n.topicDetailTitle,
        ),
        // One ⋯ options button: Share for everyone; the author also edits and
        // deletes, anyone else saves or reports.
        actions: [
          TakeTopActions(
            take: _take,
            actions: widget.actions,
            social: widget.social,
            reviews: _repository,
            onSaved: _takeVoted,
            onEdited: _takeVoted,
            onDeleted: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: LayoutBuilder(
            builder: (context, viewport) => TweenAnimationBuilder<double>(
              tween: Tween(end: _commentsExpanded ? 1 : 0),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              builder: (context, hidden, _) => CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TopicHeaderDelegate(
                      height: _headerHeight,
                      bodyHeight: math.min(_bodyHeight, _headerHeight),
                      hidden: hidden,
                      builder: (collapse) => _SizeReporter(
                        // The header shrinks by [collapse] as the body folds, so
                        // adding it back gives the natural height.
                        onSize: (size) =>
                            _measuredHeader(size.height + collapse),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                          child: _TopicHeader(
                            take: _take,
                            film: film.imdbId.isEmpty ? null : film,
                            collapse: collapse,
                            bodyHeight: _bodyHeight,
                            onBodySize: _measuredBody,
                            heart: TakeHeart(
                              take: _take,
                              reviews: _repository,
                              onChanged: _takeVoted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // The comment count and resize button stay pinned under
                  // the topic while the comments scroll.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FixedHeaderDelegate(
                      height: _commentsBarHeight,
                      child: ColoredBox(
                        color: LuxeColors.bg,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.topicCommentsHeading(count),
                                  style: TextStyle(
                                    color: LuxeColors.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _ExpandCommentsButton(
                                expanded: _commentsExpanded,
                                onPressed: () => setState(
                                  () => _commentsExpanded = !_commentsExpanded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    sliver: SliverToBoxAdapter(
                      // Tall enough that the body can always fold away fully,
                      // even with few comments.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(
                            0,
                            viewport.maxHeight -
                                (_headerHeight -
                                        math.min(_bodyHeight, _headerHeight)) *
                                    (1 - hidden) -
                                _commentsBarHeight -
                                24,
                          ),
                        ),
                        child: _buildComments(l10n),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themed(const Color(0xF20E0F12), const Color(0xF2F2EEE6)),
          border: Border(top: BorderSide(color: LuxeColors.hair)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentComposer(
                      mentionFriends: _mentionFriends,
                      controller: _input,
                      focusNode: _inputFocus,
                      sending: _sending,
                      onSend: _send,
                      replyingTo: _replyTo?.authorName,
                      onCancelReply: _cancelReply,
                      onPickPhoto: _pickPhoto,
                      photo: _photoBytes,
                      onRemovePhoto: _removePhoto,
                    ),
                    if (_sendFailed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.reviewCommentFailed,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComments(AppLocalizations l10n) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(
          color: LuxeColors.accent,
          backgroundColor: LuxeColors.surface2,
        ),
      );
    }
    final comments = _comments;
    if (comments == null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.reviewCommentsFailed,
              style: TextStyle(color: LuxeColors.muted, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _retryComments,
            child: Text(l10n.homeSectionErrorRetry),
          ),
        ],
      );
    }
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            l10n.topicBeFirst,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LuxeColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    return CommentThread(
      comments: comments,
      highlightId: widget.replyToCommentId,
      highlightKey: _focusKey,
      onReply: _startReply,
    );
  }
}

/// The question itself: author, tag, title, body, photo and movie.
///
/// The body (and photo) folds away by [collapse] pixels as the page scrolls;
/// everything else stays.
class _TopicHeader extends StatelessWidget {
  const _TopicHeader({
    required this.take,
    required this.film,
    required this.heart,
    required this.collapse,
    required this.bodyHeight,
    required this.onBodySize,
  });

  final Take take;
  final Film? film;

  /// The heart: the one reaction on takes and topics.
  final Widget heart;

  /// How many pixels of the body are folded away.
  final double collapse;

  /// The body's natural height, as last measured.
  final double bodyHeight;
  final ValueChanged<double> onBodySize;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isQuestion = take.tag == TakeTag.question;
    final isReview = take.tag == TakeTag.review;
    final feelings = isReview ? take.authorFeelings : const <FilmReaction>[];
    final createdAt = take.createdAt;
    final film = this.film;
    // Share of the body still showing; it fades at the same pace.
    final shown =
        bodyHeight <= 0 ? 1.0 : (1 - collapse / bodyHeight).clamp(0.0, 1.0);
    final fade = shown;

    final hasTitle = take.title.isNotEmpty;
    final Widget? title = hasTitle
        ? Text(
            take.title,
            key: const Key('topic-title'),
            style: TextStyle(
              color: LuxeColors.text,
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          )
        : null;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasTitle) const SizedBox(height: 8),
        // Under a title the body reads as text; alone it is the headline.
        Text(
          take.body,
          style: hasTitle
              ? TextStyle(color: LuxeColors.text, fontSize: 15, height: 1.45)
              : TextStyle(
                  color: LuxeColors.text,
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
        ),
        if (take.imageUrl != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: TakePhoto(url: take.imageUrl!),
          ),
        ],
      ],
    );
    // Folds [child] away by [collapse] pixels, fading as it goes, and reports
    // its natural height so the header knows how far it can fold.
    Widget collapsible(Widget child) => ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: shown,
            child: Opacity(
              opacity: fade,
              child: _SizeReporter(
                onSize: (size) => onBodySize(size.height),
                child: child,
              ),
            ),
          ),
        );

    // Flat, like the comments under it: no card, just a hairline below.
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: LuxeColors.hair)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LuxeColors.accent,
                ),
                child: TakeAvatar(
                  name: take.authorName,
                  url: take.authorAvatarUrl,
                  size: 36,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      take.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: LuxeColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        take.edited
                            ? '${relativeTakeTime(context, createdAt)} · ${l10n.takeEdited}'
                            : relativeTakeTime(context, createdAt),
                        style: TextStyle(
                          color: LuxeColors.muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isReview)
                _TagPill(
                  label: isQuestion
                      ? l10n.topicTagQuestion
                      : l10n.topicTagDiscussion,
                ),
            ],
          ),
          // A take carries how the writer felt instead of a tag: a quiet
          // row of word chips under the author.
          if (feelings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              key: const Key('take-feelings'),
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.takeFeltLabel,
                  style: TextStyle(color: LuxeColors.muted, fontSize: 12),
                ),
                for (final feeling in feelings)
                  _FeelingChip(label: reactionLabel(l10n, feeling)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // A spoiler post folds away whole, cover and all (the cover keeps
          // a minimum height, so it can't shrink with just the body); an
          // open one keeps its title and folds only the body.
          if (take.spoiler)
            collapsible(
              SpoilerShield(
                hidden: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [if (title != null) title, body],
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [if (title != null) title, collapsible(body)],
            ),
          if (film != null) ...[
            const SizedBox(height: 14),
            TopicFilmBlock(
                film: film, onTap: () => openOverview(context, film)),
          ],
          const SizedBox(height: 6),
          Align(alignment: AlignmentDirectional.centerStart, child: heart),
        ],
      ),
    );
  }
}

/// Top-right toggle that lets the comments fill the page or shrinks them back.
class _ExpandCommentsButton extends StatelessWidget {
  const _ExpandCommentsButton(
      {required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label =
        expanded ? l10n.topicCommentsShrink : l10n.topicCommentsExpand;
    return IconButton(
      key: const Key('topic-comments-expand'),
      tooltip: label,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: .75, end: 1.0).animate(animation),
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: Icon(
          expanded
              ? BootstrapIcons.arrows_angle_contract
              : BootstrapIcons.arrows_angle_expand,
          key: ValueKey(expanded),
          size: 18,
          color: LuxeColors.muted,
        ),
      ),
    );
  }
}

/// Pins the topic header and folds its body away as the page scrolls.
class _TopicHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TopicHeaderDelegate({
    required this.height,
    required this.bodyHeight,
    required this.builder,
    this.hidden = 0,
  });

  /// How far the whole header has slid away (0 shown, 1 gone) while the
  /// comments fill the page.
  final double hidden;

  /// The header's natural height (0 until first measured).
  final double height;

  /// How much of it can fold away.
  final double bodyHeight;
  final Widget Function(double collapse) builder;

  @override
  double get maxExtent => height * (1 - hidden);

  @override
  double get minExtent => (height - bodyHeight) * (1 - hidden);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shown = 1 - hidden;
    final collapse =
        shown <= 0 ? bodyHeight : (shrinkOffset / shown).clamp(0.0, bodyHeight);
    // While hiding, the header slides up and fades so its bottom edge
    // follows the shrinking space.
    return ColoredBox(
      color: LuxeColors.bg,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(0, -hidden * (height - collapse)),
            child: Opacity(
              opacity: shown.clamp(0.0, 1.0),
              child: builder(collapse),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TopicHeaderDelegate oldDelegate) => true;
}

/// A pinned header of one fixed height.
class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      // Fills its whole extent; a shorter child breaks the sliver's geometry.
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_FixedHeaderDelegate oldDelegate) => true;
}

/// Reports its child's size after each layout.
class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onSize, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onSize);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSizeReporter renderObject) {
    renderObject.onSize = onSize;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onSize);

  ValueChanged<Size> onSize;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _last) return;
    _last = size;
    final reported = size;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSize(reported));
  }
}

/// One of the writer's feelings on a take, as a soft word chip.
class _FeelingChip extends StatelessWidget {
  const _FeelingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LuxeColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: LuxeColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LuxeColors.accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LuxeColors.accent.withValues(alpha: .45)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: LuxeColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// "About this movie": the topic's film with its poster, opening the film
/// when tapped. Shown on the topic page and on the trending topic cards.
class TopicFilmBlock extends StatelessWidget {
  const TopicFilmBlock({
    super.key,
    required this.film,
    this.onTap,
    this.compact = false,
  });

  final Film film;
  final VoidCallback? onTap;

  /// A slimmer row with a smaller poster and lighter text, for cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final block = Container(
      padding: EdgeInsets.all(compact ? 7 : 10),
      decoration: BoxDecoration(
        color: LuxeColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: Row(
        children: [
          FilmPoster(
            film: film,
            width: compact ? 24 : 42,
            height: compact ? 36 : 63,
            radius: compact ? 4 : 7,
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topicAboutFilm.toUpperCase(),
                  style: TextStyle(
                    color: LuxeColors.muted,
                    fontSize: compact ? 9 : 10,
                    letterSpacing: compact ? 1.1 : 1.4,
                  ),
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  film.displayTitle,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LuxeColors.text,
                    fontSize: compact ? 13 : 15,
                    fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(BootstrapIcons.chevron_right,
              size: compact ? 14 : null, color: LuxeColors.muted),
        ],
      ),
    );
    final onTap = this.onTap;
    if (onTap == null) return block;
    return Semantics(
      button: true,
      label: '${l10n.topicAboutFilm}: ${film.displayTitle}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('topic-film-${film.imdbId}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: block,
      ),
    );
  }
}
