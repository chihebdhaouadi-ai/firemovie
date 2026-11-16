import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

const _debounce = Duration(milliseconds: 350);
const _minQueryLength = 2;

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({
    super.key,
    required this.repository,
    required this.onOpenUser,
  });

  final SocialRepository repository;
  final ValueChanged<SocialUser> onOpenUser;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _controller = TextEditingController();
  Timer? _timer;
  int _sequence = 0;
  String _query = '';
  bool _loading = false;
  bool _failed = false;
  List<SocialUser> _results = const [];

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    final query = value.trim();
    if (query.length < _minQueryLength) {
      _sequence++;
      setState(() {
        _query = '';
        _loading = false;
        _failed = false;
        _results = const [];
      });
      return;
    }
    _timer = Timer(_debounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final sequence = ++_sequence;
    setState(() {
      _query = query;
      _loading = true;
      _failed = false;
    });
    try {
      final results = await widget.repository.searchUsers(query);
      if (!mounted || sequence != _sequence) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || sequence != _sequence) return;
      setState(() {
        _results = const [];
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.searchPeopleTitle),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.spaceLg,
                    0,
                    tokens.spaceLg,
                    tokens.spaceMd,
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      hintText: l10n.searchPeopleHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                if (_loading)
                  const LinearProgressIndicator(
                    color: AppColors.accentGlow,
                    backgroundColor: AppColors.surfaceRaised,
                  ),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    String? message;
    if (_failed) {
      message = l10n.searchPeopleFailed;
    } else if (_query.isEmpty) {
      message = l10n.searchPeopleMinChars;
    } else if (!_loading && _results.isEmpty) {
      message = l10n.searchPeopleEmpty;
    }

    if (message != null) {
      return Padding(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      itemCount: _results.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.spaceSm),
      itemBuilder: (context, index) {
        final user = _results[index];
        return ListTile(
          minTileHeight: tokens.minTouchTarget,
          tileColor: AppColors.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          leading: _UserAvatar(user: user),
          title: Text(
            user.username,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => widget.onOpenUser(user),
        );
      },
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final SocialUser user;

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatarUrl;
    final initial = user.username.isEmpty
        ? ''
        : user.username.substring(0, 1).toUpperCase();

    return CircleAvatar(
      backgroundColor: AppColors.background,
      backgroundImage:
          avatar == null ? null : CachedNetworkImageProvider(avatar),
      child: avatar == null
          ? Text(
              initial,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.accentGlow,
                  ),
            )
          : null,
    );
  }
}
