import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_locale.dart';
import '../../../core/auth/auth_cubit.dart';
import '../../../core/avatar_frames.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/game_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../leaderboard/views/leaderboard_how_it_works_screen.dart';
import '../../leaderboard/views/leaderboard_screen.dart';
import '../../overview/views/widgets/overview_panel.dart';
import '../../social/data/social_models.dart';
import '../../social/data/social_repository.dart';
import '../../social/views/movie_suggestion_screen.dart';
import '../../social/views/notifications_screen.dart';
import '../../social/views/user_search_screen.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import 'widgets/profile_game_kit.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_hero.dart';
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
  final Future<XFile?> Function()? pickImage;

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
  bool _loading = true;
  bool _failed = false;
  bool _friendBusy = false;
  int _unreadCount = 0;

  bool get _isOwn => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProfileRepository();
    _social = widget.socialRepository ?? SocialRepository();
    _load();
  }

  Future<UserProfile> _fetchProfile() =>
      _isOwn ? _repository.fetchMe() : _repository.fetchUser(widget.userId!);

  Future<void> _load() async {
    try {
      final profile = await _fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
      if (_isOwn) {
        _loadSocial();
        _loadUnread();
      }
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
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _loadUnread() async {
    try {
      final page = await _social.notifications();
      if (!mounted) return;
      setState(() => _unreadCount = page.unreadCount);
    } catch (_) {
      // The unread badge is optional; the icon still works without it.
    }
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
    if (mounted) _loadUnread();
  }

  void _openLeaderboard() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              tooltip: context.l10n.profileBack,
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset(
                'assets/svg/back.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
          body: const SafeArea(top: false, child: LeaderboardScreen()),
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

  void _openAchievements(List<ProgressItem> items) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ProfileAchievementsSection(items: items),
        ),
      ),
    );
  }

  void _openLanguagePicker() {
    showDialog<void>(
      context: context,
      builder: (_) => const _LanguagePicker(),
    );
  }

  void _logout() {
    // Signs out (clears the token everywhere) and returns to Home as a guest.
    context.read<AuthCubit>().signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _editAvatar() async {
    final l10n = context.l10n;
    final file = await (widget.pickImage ?? _defaultPickImage)();
    if (file == null || !mounted) return;
    try {
      await _repository.uploadAvatar(file);
      await _refreshProfile();
    } catch (_) {
      if (mounted) _showSnack(l10n.profileSaveFailed);
    }
  }

  /// Equips an unlocked frame straight away; reverts if the server refuses.
  Future<void> _equipFrame(String frameKey) async {
    final profile = _profile;
    if (profile == null || profile.equippedFrame == frameKey) return;
    final previous = profile.equippedFrame;
    setState(() => _profile = profile.withEquippedFrame(frameKey));
    try {
      await _repository.setEquippedFrame(frameKey);
    } catch (_) {
      if (!mounted) return;
      final current = _profile;
      if (current != null) {
        setState(() => _profile = current.withEquippedFrame(previous));
      }
      _showSnack(context.l10n.frameUpdateFailed);
    }
  }

  void _openHowItWorks() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LeaderboardHowItWorksScreen(),
      ),
    );
  }

  static Future<XFile?> _defaultPickImage() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
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
          icon: SvgPicture.asset('assets/svg/back.svg', width: 24, height: 24),
        ),
        actions: _isOwn
            ? [
                GameIconButton(
                  tooltip: l10n.profileSearchTooltip,
                  onPressed: _openSearch,
                  icon: Icons.search,
                ),
                GameIconButton(
                  tooltip: l10n.leaderboardTabLabel,
                  onPressed: _openLeaderboard,
                  child: SvgPicture.asset(
                    'assets/svg/trophy.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
                GameIconButton(
                  tooltip: l10n.notificationsTitle,
                  onPressed: _openNotifications,
                  child: Badge(
                    isLabelVisible: _unreadCount > 0,
                    label: Text('$_unreadCount'),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                GameIconButton(
                  tooltip: l10n.profileAchievementsTitle,
                  onPressed: () => _openAchievements(
                    _profile?.progress.achievements ?? const [],
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/trophy.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
                GameIconButton(
                  tooltip: l10n.profileLogout,
                  onPressed: _logout,
                  icon: Icons.logout,
                ),
              ]
            : [
                GameIconButton(
                  tooltip: l10n.profileMoreTooltip,
                  onPressed: () => showProfileBlockDialog(context),
                  icon: Icons.more_vert,
                ),
              ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.tokens.maxContentWidth,
            ),
            child:
                _failed ? _ErrorState(onRetry: _retry) : _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final profile = _profile;
    final isOwn = _isOwn;
    final progress = profile?.progress ?? ProfileProgress.empty;
    final username = profile?.username ?? '';
    final initial = username.isEmpty ? '' : username.substring(0, 1);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.spaceLg,
        tokens.spaceSm,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: [
        ProfileHero(
          username: username,
          avatarUrl: profile?.avatarUrl,
          frame: profile?.equippedFrame ?? defaultFrameKey,
          progress: progress,
          bio: profile?.bio ?? '',
          onEditAvatar: isOwn ? _editAvatar : null,
          onEditBio: isOwn ? _editBio : null,
        ),
        if (!isOwn && profile != null) ...[
          SizedBox(height: tokens.spaceLg),
          FriendActionRow(
            state: profile.friendship,
            busy: _friendBusy,
            onAdd: _addFriend,
            onCancel: _onCancel,
            onAccept: _onAccept,
            onDecline: _onDecline,
            onSuggest: () => _openSuggest(preselectedUserId: profile.id),
          ),
        ],
        SizedBox(height: tokens.spaceLg),
        ProfileStatsRow(progress: progress),
        ProfileBadgesSection(badges: progress.badges),
        if (isOwn)
          ProfileFramesSection(
            frames: progress.frames,
            equipped: profile?.equippedFrame ?? defaultFrameKey,
            initial: initial,
            onSelect: _equipFrame,
          ),
        ProfileAchievementsSection(items: progress.achievements),
        if (isOwn) ...[
          SizedBox(height: tokens.spaceLg),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              onPressed: () => _openSuggest(),
              icon: Icons.movie_filter_outlined,
              label: l10n.suggestMovieAction,
              style: GameButtonStyle.blue,
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          GameCard(
            child: ConnectionsSection(
              following: _following,
              followers: _followers,
              onOpen: (user) => _openUser(user.id),
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          SizedBox(
            width: double.infinity,
            child: GameButton(
              onPressed: _openLanguagePicker,
              icon: Icons.translate,
              label: l10n.profileLanguageButton,
            ),
          ),
        ],
        SizedBox(height: tokens.spaceLg),
        Center(
          child: TextButton(
            onPressed: _openHowItWorks,
            child: Text(l10n.leaderboardHowItWorks),
          ),
        ),
        if (_loading) ...[
          SizedBox(height: tokens.spaceMd),
          const LinearProgressIndicator(
            color: AppColors.accentGlow,
            backgroundColor: AppColors.surfaceRaised,
          ),
        ],
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
        GameButton(
          label: l10n.profileSave,
          style: GameButtonStyle.blue,
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
        ),
      ],
    );
  }
}

const _languageNames = {
  'en': 'English',
  'fr': 'Français',
  'ar': 'العربية',
  'ru': 'Русский',
};

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(Locale?, String)>[
      (null, l10n.profileLanguageSystem),
      for (final locale in AppLocalizations.supportedLocales)
        (locale, _languageNames[locale.languageCode] ?? locale.languageCode),
    ];

    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocale.current,
      builder: (context, current, child) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.profileLanguageDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (locale, name) in options)
              ListTile(
                title: Text(name),
                trailing: locale?.languageCode == current?.languageCode
                    ? const Icon(Icons.check, color: AppColors.accentGlow)
                    : null,
                onTap: () {
                  AppLocale.select(locale);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.profileCancel),
          ),
        ],
      ),
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
            GameButton(
              label: l10n.profileRetry,
              style: GameButtonStyle.blue,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
