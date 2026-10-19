import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

const _debounce = Duration(milliseconds: 350);
const _minQueryLength = 2;
const _commentMaxLength = 280;

class MovieSuggestionScreen extends StatefulWidget {
  const MovieSuggestionScreen({
    super.key,
    required this.socialRepository,
    required this.findRepository,
    this.preselectedUserIds = const {},
  });

  final SocialRepository socialRepository;
  final FindRepository findRepository;
  final Set<int> preselectedUserIds;

  @override
  State<MovieSuggestionScreen> createState() => _MovieSuggestionScreenState();
}

class _MovieSuggestionScreenState extends State<MovieSuggestionScreen> {
  final _searchController = TextEditingController();
  final _commentController = TextEditingController();
  final Set<int> _selected = {};
  Timer? _timer;
  int _searchSequence = 0;
  String _query = '';
  bool _searching = false;
  bool _searchFailed = false;
  List<Movie> _results = const [];
  Movie? _movie;

  List<SocialUser> _friends = const [];
  bool _friendsLoading = true;
  bool _friendsFailed = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.preselectedUserIds);
    _loadFriends();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final connections = await widget.socialRepository.connections();
      if (!mounted) return;
      setState(() {
        _friends = connections.friends;
        _selected.removeWhere(
          (id) => !_friends.any((friend) => friend.id == id),
        );
        _friendsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _friendsLoading = false;
        _friendsFailed = true;
      });
    }
  }

  void _onQueryChanged(String value) {
    _timer?.cancel();
    final query = value.trim();
    if (query.length < _minQueryLength) {
      _searchSequence++;
      setState(() {
        _query = '';
        _searching = false;
        _searchFailed = false;
        _results = const [];
      });
      return;
    }
    _timer = Timer(_debounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final sequence = ++_searchSequence;
    setState(() {
      _query = query;
      _searching = true;
      _searchFailed = false;
    });
    try {
      final page = await widget.findRepository.search(query);
      if (!mounted || sequence != _searchSequence) return;
      setState(() {
        _results = page.results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || sequence != _searchSequence) return;
      setState(() {
        _results = const [];
        _searching = false;
        _searchFailed = true;
      });
    }
  }

  void _pickMovie(Movie movie) {
    _timer?.cancel();
    _searchSequence++;
    _searchController.clear();
    setState(() {
      _movie = movie;
      _query = '';
      _results = const [];
      _searching = false;
    });
  }

  void _clearMovie() => setState(() => _movie = null);

  bool get _allSelected =>
      _friends.isNotEmpty && _selected.length == _friends.length;

  void _toggleAll(bool? value) {
    setState(() {
      if (value ?? false) {
        _selected
          ..clear()
          ..addAll(_friends.map((friend) => friend.id));
      } else {
        _selected.clear();
      }
    });
  }

  void _toggleFriend(int id, bool? value) {
    setState(() {
      if (value ?? false) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  bool get _canSend => _movie != null && _selected.isNotEmpty && !_sending;

  Future<void> _send() async {
    final movie = _movie;
    if (movie == null || !_canSend) return;
    final l10n = context.l10n;
    setState(() => _sending = true);
    try {
      await widget.socialRepository.sendMovieSuggestion(
        movie: movie,
        comment: _commentController.text.trim(),
        recipientIds: _selected.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      final message = error is ServerFailure && error.code == 'not_friends'
          ? l10n.suggestionNotFriends
          : l10n.suggestionFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
        title: Text(l10n.suggestionTitle),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              children: [
                _SectionTitle(title: l10n.suggestionMovieSection),
                SizedBox(height: tokens.spaceSm),
                _movieSection(context),
                SizedBox(height: tokens.spaceLg),
                _SectionTitle(title: l10n.suggestionRecipientsSection),
                SizedBox(height: tokens.spaceSm),
                _recipientsSection(context),
                SizedBox(height: tokens.spaceLg),
                TextField(
                  controller: _commentController,
                  maxLength: _commentMaxLength,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.suggestionCommentHint,
                  ),
                ),
                SizedBox(height: tokens.spaceLg),
                FilledButton(
                  onPressed: _canSend ? _send : null,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, tokens.minTouchTarget),
                  ),
                  child: Text(l10n.suggestionSend),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _movieSection(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final movie = _movie;
    if (movie != null) {
      return _MovieRow(
        movie: movie,
        trailing: TextButton(
          onPressed: _clearMovie,
          child: Text(l10n.suggestionChangeMovie),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: l10n.suggestionSearchHint,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        _searchBody(context),
      ],
    );
  }

  Widget _searchBody(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    if (_searchFailed) return _Message(text: l10n.suggestionSearchFailed);
    if (_searching) {
      return const LinearProgressIndicator(
        color: AppColors.accentGlow,
        backgroundColor: AppColors.surfaceRaised,
      );
    }
    if (_results.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final movie in _results)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spaceSm),
              child: _MovieRow(
                movie: movie,
                onTap: () => _pickMovie(movie),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
        ],
      );
    }
    final typed = _searchController.text.trim();
    if (typed.isEmpty) return _Message(text: l10n.suggestionPickMovie);
    if (typed.length < _minQueryLength) {
      return _Message(text: l10n.suggestionSearchMinChars);
    }
    if (_query == typed) return _Message(text: l10n.suggestionSearchEmpty);
    return const SizedBox.shrink();
  }

  Widget _recipientsSection(BuildContext context) {
    final l10n = context.l10n;

    if (_friendsLoading) {
      return const LinearProgressIndicator(
        color: AppColors.accentGlow,
        backgroundColor: AppColors.surfaceRaised,
      );
    }
    if (_friendsFailed) return _Message(text: l10n.suggestionFriendsFailed);
    if (_friends.isEmpty) return _Message(text: l10n.suggestionNoFriends);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          value: _allSelected,
          onChanged: _toggleAll,
          title: Text(l10n.suggestionSelectAll),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        for (final friend in _friends)
          CheckboxListTile(
            value: _selected.contains(friend.id),
            onChanged: (value) => _toggleFriend(friend.id, value),
            title: Text(friend.username),
            secondary: _FriendAvatar(user: friend),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spaceSm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({required this.movie, required this.trailing, this.onTap});

  final Movie movie;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final year = movie.year;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceSm),
          child: Row(
            children: [
              _PosterThumb(url: movie.posterUrl),
              SizedBox(width: tokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (year != null)
                      Text(
                        '$year',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterThumb extends StatelessWidget {
  const _PosterThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final poster = url;
    return SizedBox(
      width: 40,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: poster == null
            ? const ColoredBox(color: AppColors.panelBorder)
            : CachedNetworkImage(
                imageUrl: poster,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const ColoredBox(color: AppColors.panelBorder),
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
    final avatar = user.avatarUrl;
    final initial = user.username.isEmpty
        ? ''
        : user.username.substring(0, 1).toUpperCase();

    return CircleAvatar(
      backgroundColor: AppColors.surfaceRaised,
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
