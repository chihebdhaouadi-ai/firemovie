import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/avatar_frame.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/domain/take.dart';
import '../../film_reviews/presentation/widgets/comment_thread.dart';
import '../../film_reviews/presentation/widgets/mention_suggestions.dart';
import '../../film_reviews/presentation/widgets/take_heart.dart'
    show heartColor;
import '../../social/data/social_models.dart';
import '../../home/data/home_models.dart';
import '../../home/views/home_navigation.dart';
import '../../home/views/widgets/film_tile.dart';
import '../../home/views/widgets/take_summary_card.dart' show absoluteApiUrl;
import '../data/movie_list.dart';
import '../data/movie_list_repository.dart';
import '../../social/data/social_repository.dart';
import 'create_movie_list_screen.dart';
import 'widgets/share_list_sheet.dart';

/// A posted list: who made it, its heart and comments, every film as a
/// poster, and the comment thread, laid out like a topic's (replies, photos,
/// and the same box at the bottom). Anyone can heart a list, its owner too.
/// The ⋮ menu top right sends the list to friends' chats; it also offers Edit
/// and Delete on your own list, and Save on someone else's.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    required this.list,
    required this.repository,
    this.social,
  });

  final MovieList list;
  final MovieListRepository repository;

  /// Where your friends load from for Share; the real API when left out.
  final SocialRepository? social;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late MovieList _list = widget.list;
  List<ListComment>? _comments;
  bool _loadingComments = true;
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _scroll = ScrollController();
  final _commentsKey = GlobalKey();
  bool _sending = false;
  bool _sendFailed = false;

  /// The comment being answered; the next comment is sent as its reply.
  ListComment? _replyTo;

  /// The photo picked for the next comment, previewed above the box.
  XFile? _photo;
  Uint8List? _photoBytes;

  /// Friends suggested while typing `@name`.
  List<SocialUser> _mentionFriends = const [];

  /// Whether the comments are on screen. Until they are, the bottom bar is a
  /// Comments button that slides down to them; then it is the comment box.
  bool _commentsInView = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_checkCommentsInView);
    _inputFocus.addListener(_checkCommentsInView);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCommentsInView());
    unawaited(_loadList());
    unawaited(_loadComments());
    unawaited(MentionFriends.load(widget.social).then((friends) {
      if (mounted) setState(() => _mentionFriends = friends);
    }));
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadList() async {
    try {
      final list = await widget.repository.fetchList(_list.id);
      if (mounted) setState(() => _list = list);
    } catch (_) {
      // Keep the card's copy of the list; its comments still load below.
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await widget.repository.fetchComments(_list.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkCommentsInView());
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingComments = false);
    }
  }

  void _retryComments() {
    setState(() => _loadingComments = true);
    unawaited(_loadComments());
  }

  /// The comment count up top: slide down to the comments and put the cursor
  /// in the box at the bottom.
  /// Shows the comment box once the comments heading is on screen, and keeps
  /// it while a comment is being written, so a draft is never hidden.
  void _checkCommentsInView() {
    if (!mounted) return;
    final box = _commentsKey.currentContext?.findRenderObject();
    var visible = false;
    if (box is RenderBox && box.attached && _scroll.hasClients) {
      // Where the heading sits in the scroll view, measured from the scroll
      // offset (an off-screen sliver's paint position can be stale).
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport != null) {
        final top = viewport.getOffsetToReveal(box, 0).offset -
            _scroll.position.pixels;
        // A little of the section showing above the bottom of the view.
        visible = top < _scroll.position.viewportDimension - 60;
      }
    }
    final writing = _inputFocus.hasFocus ||
        _replyTo != null ||
        _photo != null ||
        _input.text.trim().isNotEmpty;
    final show = visible || writing;
    if (show != _commentsInView) setState(() => _commentsInView = show);
  }

  /// The Comments button: slide down to the comments, which turns the bar
  /// into the comment box.
  void _showComments() => _jumpToComments(focus: false);

  void _jumpToComments({bool focus = true}) {
    setState(() => _commentsInView = true);
    final target = _commentsKey.currentContext;
    if (target != null) {
      unawaited(Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.02,
      ));
    }
    if (focus) _inputFocus.requestFocus();
  }

  /// A heart on the list, your own included: fills at once and saves in the
  /// background, going back if the server refuses.
  Future<void> _toggleHeart() async {
    final before = _list;
    final liked = !before.liked;
    unawaited(HapticFeedback.lightImpact());
    setState(() => _list =
        before.copyWith(liked: liked, likes: before.likes + (liked ? 1 : -1)));
    try {
      final saved = await widget.repository.setLike(before.id, active: liked);
      if (!mounted) return;
      setState(
          () => _list = _list.copyWith(likes: saved.likes, liked: saved.liked));
    } catch (_) {
      if (!mounted) return;
      setState(() => _list = before);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(context.l10n.reviewVoteFailed)));
    }
  }

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

  void _startReply(TakeComment comment) {
    final target = _comments?.where((c) => c.id == comment.id).firstOrNull;
    if (target == null) return;
    setState(() => _replyTo = target);
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
      final comment = await widget.repository.postComment(
        _list.id,
        body: body,
        parentId: _replyTo?.id,
        image: photo,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _comments = [...?_comments, comment];
        _list = _list.copyWith(comments: _list.comments + 1);
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

  /// Pick friends to send the list to; it lands in each chat as a card.
  Future<void> _share() => showShareListSheet(
        context,
        list: _list,
        repository: widget.repository,
        social: widget.social,
      );

  /// The ⋮ menu: Share, then Edit and Delete (yours) or Save (someone else's).
  Future<void> _openMenu() async {
    final l10n = context.l10n;
    final list = _list;
    final choice = await showModalBottomSheet<_ListAction>(
      context: context,
      backgroundColor: LuxeColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuTile(
              key: const Key('list-menu-share'),
              icon: BootstrapIcons.send,
              label: l10n.listShare,
              value: _ListAction.share,
            ),
            if (list.isMine) ...[
              _MenuTile(
                key: const Key('list-menu-edit'),
                icon: BootstrapIcons.pencil,
                label: l10n.listEdit,
                value: _ListAction.edit,
              ),
              _MenuTile(
                key: const Key('list-menu-delete'),
                icon: BootstrapIcons.trash3,
                label: l10n.listDelete,
                value: _ListAction.delete,
                destructive: true,
              ),
            ] else
              _MenuTile(
                key: const Key('list-menu-save'),
                icon: list.saved
                    ? BootstrapIcons.bookmark_fill
                    : BootstrapIcons.bookmark,
                label: list.saved ? l10n.listUnsave : l10n.listSave,
                value: _ListAction.save,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case _ListAction.share:
        await _share();
      case _ListAction.edit:
        await _edit();
      case _ListAction.delete:
        await _delete();
      case _ListAction.save:
        await _toggleSave();
    }
  }

  Future<void> _toggleSave() async {
    final before = _list;
    final saved = !before.saved;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    unawaited(HapticFeedback.selectionClick());
    setState(() => _list = before.copyWith(saved: saved));
    messenger?.hideCurrentSnackBar();
    try {
      final result = await widget.repository.setSaved(before.id, active: saved);
      if (!mounted) return;
      setState(() => _list = _list.copyWith(saved: result.saved));
      messenger?.showSnackBar(SnackBar(
          content: Text(saved ? l10n.listSavedToast : l10n.listUnsavedToast)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _list = before);
      messenger?.showSnackBar(SnackBar(content: Text(l10n.listSaveFailed)));
    }
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(context).push<MovieList>(
      MaterialPageRoute(
        builder: (_) => CreateMovieListScreen(
          repository: widget.repository,
          editing: _list,
        ),
      ),
    );
    if (edited == null || !mounted) return;
    setState(() => _list = edited);
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.listDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.listCancel)),
          TextButton(
            key: const Key('list-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.listDelete),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final navigator = Navigator.of(context);
    await widget.repository.delete(_list.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = _list;
    final count = _comments?.length ?? list.comments;
    return Scaffold(
      backgroundColor: LuxeColors.bg,
      appBar: AppBar(
        backgroundColor: LuxeColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            key: const Key('list-menu'),
            tooltip: l10n.listMenuTooltip,
            onPressed: _openMenu,
            icon: Icon(BootstrapIcons.three_dots_vertical,
                size: 20, color: LuxeColors.text),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _Avatar(person: list.owner, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.listBy(list.owner.username),
                      style: TextStyle(
                          color: LuxeColors.text, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Semantics(
                    button: true,
                    selected: list.liked,
                    label:
                        '${l10n.takeHeartLike}, ${l10n.takeHeartCount(list.likes)}',
                    excludeSemantics: true,
                    child: InkResponse(
                      key: const Key('list-heart'),
                      onTap: _toggleHeart,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            AnimatedSwitcher(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                      scale: animation, child: child),
                              child: Icon(
                                list.liked
                                    ? BootstrapIcons.heart_fill
                                    : BootstrapIcons.heart,
                                key: ValueKey(list.liked),
                                size: 18,
                                color:
                                    list.liked ? heartColor : LuxeColors.muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${list.likes}',
                                style: TextStyle(
                                    color: LuxeColors.text,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkResponse(
                    key: const Key('list-comment-button'),
                    onTap: () => _jumpToComments(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(BootstrapIcons.chat,
                              size: 17, color: LuxeColors.muted),
                          const SizedBox(width: 6),
                          Text('$count',
                              style: TextStyle(
                                  color: LuxeColors.text,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: .5,
              ),
              itemCount: list.films.length,
              itemBuilder: (context, i) => _FilmTile(film: list.films[i]),
            ),
          ),
          // The comments, laid out like a topic's: a hairline, the count,
          // then the thread with replies and photos.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                key: _commentsKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, thickness: 1, color: LuxeColors.hair),
                  SizedBox(
                    height: 52,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        // With none yet, the line below already says so.
                        count == 0
                            ? l10n.listCommentsTitle
                            : l10n.topicCommentsHeading(count),
                        style: TextStyle(
                          color: LuxeColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            sliver: SliverToBoxAdapter(child: _buildComments(l10n)),
          ),
        ],
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
                padding: EdgeInsets.fromLTRB(
                    12, 10, 12, 10 + MediaQuery.viewInsetsOf(context).bottom),
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  ),
                  child: !_commentsInView
                      ? FilledButton.icon(
                          key: const Key('list-comments-open'),
                          onPressed: _showComments,
                          icon: const Icon(BootstrapIcons.chat, size: 18),
                          label: Text(l10n.listCommentCount(count)),
                          style: FilledButton.styleFrom(
                            backgroundColor: LuxeColors.text,
                            foregroundColor: LuxeColors.bg,
                            minimumSize: const Size.fromHeight(50),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      : Column(
                          key: const ValueKey('list-comment-box'),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommentComposer(
                              key: const Key('list-comment-composer'),
                              mentionFriends: _mentionFriends,
                              controller: _input,
                              focusNode: _inputFocus,
                              sending: _sending,
                              onSend: _send,
                              replyingTo: _replyTo?.author.username,
                              onCancelReply: _cancelReply,
                              onPickPhoto: _pickPhoto,
                              photo: _photoBytes,
                              onRemovePhoto: _removePhoto,
                            ),
                            if (_sendFailed)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l10n.listSendFailed,
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
      ),
    );
  }

  Widget _buildComments(AppLocalizations l10n) {
    if (_loadingComments) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            l10n.listCommentsEmpty,
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
      comments: [for (final comment in comments) _asThreadComment(comment)],
      onReply: _startReply,
    );
  }
}

/// A list comment in the shape the topic page's thread draws.
TakeComment _asThreadComment(ListComment comment) => TakeComment(
      id: comment.id,
      authorId: comment.author.id,
      authorName: comment.author.username,
      authorAvatarUrl: comment.author.avatarUrl,
      authorFrame: comment.author.frame,
      body: comment.body,
      imageUrl: comment.imageUrl,
      parentId: comment.parentId,
      createdAt: comment.createdAt,
      isWriter: comment.isWriter,
      isMine: comment.isMine,
    );

class _FilmTile extends StatelessWidget {
  const _FilmTile({required this.film});

  final ListFilm film;

  @override
  Widget build(BuildContext context) {
    final poster = film.posterUrl;
    return Semantics(
      button: true,
      label: film.title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => openOverview(
          context,
          Film(
              imdbId: film.filmId,
              title: film.title,
              posterUrl: film.posterUrl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LayoutBuilder(
                  builder: (context, box) => poster == null
                      ? const PosterPlaceholder()
                      : PosterImage(
                          url: poster,
                          width: box.maxWidth,
                          height: box.maxHeight),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              film.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: LuxeColors.text, fontSize: 12, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.size});

  final ListPerson person;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size + 8,
        child: Center(
          child: AvatarFrame(
            size: size,
            frame: person.frame,
            avatarUrl: absoluteApiUrl(person.avatarUrl),
            initial: person.username.isEmpty
                ? '?'
                : person.username[0].toUpperCase(),
            backgroundColor: LuxeColors.surface2,
            ringWidth: 0,
            animate: false,
          ),
        ),
      );
}

enum _ListAction { share, edit, delete, save }

/// One row of the ⋮ menu; closes the menu with [value].
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final _ListAction value;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFE5484D) : LuxeColors.text;
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}
