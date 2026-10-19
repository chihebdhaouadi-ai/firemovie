import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../overview/views/widgets/overview_panel.dart';
import '../../social/data/social_models.dart';
import '../../social/data/social_repository.dart';
import '../../social/views/movie_suggestion_screen.dart';
import '../../social/views/notifications_screen.dart';
import '../../social/views/user_search_screen.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userId,
    this.repository,
    this.socialRepository,
    this.pickImage,
  });

  final int? userId;
  final ProfileRepository? repository;
  final SocialRepository? socialRepository;
  final Future<String?> Function()? pickImage;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepository _repository;
  late final SocialRepository _social;
  final FindRepository _find = FindRepository();
  UserProfile? _profile;
  List<SocialUser> _following = const [];
  List<SocialUser> _followers = const [];
  int _unreadCount = 0;
  bool _loading = true;
  bool _failed = false;
  bool _friendBusy = false;

  bool get _isOwn => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProfileRepository();
    _social = widget.socialRepository ?? SocialRepository();
    _load();
  }

  Future<UserProfile> _fetchProfile() => _isOwn
      ? _repository.fetchMe()
      : _repository.fetchUser(widget.userId!);

  Future<void> _load() async {
    try {
      final profile = await _fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
      if (_isOwn) _loadSocial();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _load();
  }

  Future<void> _refreshProfile() async {
    try {
      final profile = await _fetchProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      // Keep the last loaded profile when a refresh fails.
    }
  }

  Future<void> _loadSocial() async {
    try {
      final connections = await _social.connections();
      if (!mounted) return;
      setState(() {
        _following = connections.following;
        _followers = connections.followers;
      });
    } catch (_) {
      // Connection chips are optional; the profile still renders without them.
    }
    try {
      final page = await _social.notifications();
      if (!mounted) return;
      setState(() => _unreadCount = page.unreadCount);
    } catch (_) {
      // The bell badge is optional; a failed fetch leaves it hidden.
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openUser(int userId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(
          userId: userId,
          repository: _repository,
          socialRepository: _social,
        ),
      ),
    );
  }

  Future<void> _openSearch() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => UserSearchScreen(
          repository: _social,
          onOpenUser: (user) => _openUser(user.id),
        ),
      ),
    );
  }

  Future<void> _openSuggest({int? preselectedUserId}) async {
    final l10n = context.l10n;
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MovieSuggestionScreen(
          socialRepository: _social,
          findRepository: _find,
          preselectedUserIds: {
            if (preselectedUserId != null) preselectedUserId,
          },
        ),
      ),
    );
    if (sent == true && mounted) _showSnack(l10n.suggestionSent);
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          repository: _social,
          onOpenUser: (user) => _openUser(user.id),
        ),
      ),
    );
    if (mounted) _loadSocial();
  }

  Future<void> _editImage({required bool avatar}) async {
    final l10n = context.l10n;
    final path = await (widget.pickImage ?? _defaultPickImage)();
    if (path == null || !mounted) return;
    try {
      if (avatar) {
        await _repository.uploadAvatar(path);
      } else {
        await _repository.uploadCover(path);
      }
      await _refreshProfile();
    } catch (_) {
      if (mounted) _showSnack(l10n.profileSaveFailed);
    }
  }

  static Future<String?> _defaultPickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<void> _editBio() async {
    final l10n = context.l10n;
    final bio = await showDialog<String>(
      context: context,
      builder: (_) => _BioEditor(initialText: _profile?.bio ?? ''),
    );
    if (bio == null || !mounted) return;
    try {
      await _repository.saveBio(bio);
      await _refreshProfile();
    } catch (_) {
      if (mounted) _showSnack(l10n.profileSaveFailed);
    }
  }

  void _setFriendship(Friendship state, {int? friendRequestId}) {
    final profile = _profile;
    if (profile == null) return;
    setState(() {
      _profile = profile.withFriendship(
        state,
        friendRequestId: friendRequestId,
      );
    });
  }

  Future<void> _addFriend() async {
    final profile = _profile;
    if (profile == null || _friendBusy) return;
    final l10n = context.l10n;
    setState(() => _friendBusy = true);
    _setFriendship(Friendship.outgoing);
    try {
      final requestId = await _social.sendFriendRequest(profile.id);
      if (!mounted) return;
      _setFriendship(Friendship.outgoing, friendRequestId: requestId);
      _showSnack(l10n.friendRequestSent);
    } catch (error) {
      if (!mounted) return;
      if (error is ServerFailure && error.code == 'already_connected') {
        _showSnack(l10n.friendAlreadyConnected);
        _refreshProfile();
      } else {
        _setFriendship(Friendship.none);
        _showSnack(l10n.friendActionFailed);
      }
    } finally {
      if (mounted) setState(() => _friendBusy = false);
    }
  }

  Future<void> _changeFriendship({
    required Friendship next,
    required Friendship previous,
    required int requestId,
    required Future<void> Function() call,
  }) async {
    if (_friendBusy) return;
    final l10n = context.l10n;
    setState(() => _friendBusy = true);
    _setFriendship(next);
    try {
      await call();
    } catch (error) {
      if (!mounted) return;
      if (error is ServerFailure && error.code == 'not_found') {
        _showSnack(l10n.friendRequestGone);
        _refreshProfile();
      } else {
        _setFriendship(previous, friendRequestId: requestId);
        _showSnack(l10n.friendActionFailed);
      }
    } finally {
      if (mounted) setState(() => _friendBusy = false);
    }
  }

  void _onCancel() {
    final requestId = _profile?.friendRequestId;
    if (requestId == null) return;
    _changeFriendship(
      next: Friendship.none,
      previous: Friendship.outgoing,
      requestId: requestId,
      call: () => _social.cancelFriendRequest(requestId),
    );
  }

  void _onAccept() {
    final requestId = _profile?.friendRequestId;
    if (requestId == null) return;
    _changeFriendship(
      next: Friendship.friends,
      previous: Friendship.incoming,
      requestId: requestId,
      call: () => _social.acceptFriendRequest(requestId),
    );
  }

  void _onDecline() {
    final requestId = _profile?.friendRequestId;
    if (requestId == null) return;
    _changeFriendship(
      next: Friendship.none,
      previous: Friendship.incoming,
      requestId: requestId,
      call: () => _social.declineFriendRequest(requestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: l10n.profileBack,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: _isOwn
            ? [
                IconButton(
                  tooltip: l10n.profileSearchTooltip,
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  tooltip: l10n.notificationsTitle,
                  onPressed: _openNotifications,
                  icon: Badge(
                    isLabelVisible: _unreadCount > 0,
                    label: Text('$_unreadCount'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.tokens.maxContentWidth,
            ),
            child: _failed
                ? _ErrorState(onRetry: _retry)
                : _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.tokens;
    final profile = _profile;
    final isOwn = _isOwn;

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.spaceLg,
        0,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: [
        ProfileBanner(
          username: profile?.username ?? '',
          avatarUrl: profile?.avatarUrl,
          coverUrl: profile?.coverUrl,
          onMore: isOwn ? null : () => showProfileBlockDialog(context),
          onEditAvatar: isOwn ? () => _editImage(avatar: true) : null,
          onEditCover: isOwn ? () => _editImage(avatar: false) : null,
        ),
        SizedBox(height: tokens.minTouchTarget + tokens.spaceSm),
        ProfileCountPills(
          followers: profile?.followers ?? 0,
          following: profile?.following ?? 0,
        ),
        SizedBox(height: tokens.spaceMd),
        ProfileIdentity(
          username: profile?.username ?? '',
          bio: profile?.bio ?? '',
          onEditBio: isOwn ? _editBio : null,
        ),
        SizedBox(height: tokens.spaceLg),
        if (isOwn) ...[
          FilledButton.icon(
            onPressed: () => _openSuggest(),
            icon: const Icon(Icons.movie_filter_outlined),
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, tokens.minTouchTarget),
            ),
            label: Text(context.l10n.suggestMovieAction),
          ),
          SizedBox(height: tokens.spaceLg),
          ConnectionsSection(
            following: _following,
            followers: _followers,
            onOpen: (user) => _openUser(user.id),
          ),
        ] else if (profile != null)
          FriendActionRow(
            state: profile.friendship,
            busy: _friendBusy,
            onAdd: _addFriend,
            onCancel: _onCancel,
            onAccept: _onAccept,
            onDecline: _onDecline,
            onSuggest: () => _openSuggest(preselectedUserId: profile.id),
          ),
        SizedBox(height: tokens.spaceLg),
        OverviewPanel(
          child: SizedBox(height: tokens.minTouchTarget * 2),
        ),
        if (_loading) ...[
          SizedBox(height: tokens.spaceMd),
          const LinearProgressIndicator(
            color: AppColors.accentGlow,
            backgroundColor: AppColors.surfaceRaised,
          ),
        ],
        SizedBox(height: tokens.spaceXl),
        AchievementsSection(watched: profile?.watched),
        SizedBox(height: tokens.spaceXl),
        StatisticsSection(profile: profile),
      ],
    );
  }
}

class _BioEditor extends StatefulWidget {
  const _BioEditor({required this.initialText});

  final String initialText;

  @override
  State<_BioEditor> createState() => _BioEditorState();
}

class _BioEditorState extends State<_BioEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.profileEditBioTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        decoration: InputDecoration(hintText: l10n.profileBioHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.profileCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.profileSave),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(tokens.spaceLg),
      child: OverviewPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profileErrorTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.profileRetry),
            ),
          ],
        ),
      ),
    );
  }
}
