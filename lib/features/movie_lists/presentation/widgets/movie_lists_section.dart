import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/views/widgets/section_header.dart';
import '../../data/movie_list.dart';
import '../../data/movie_list_repository.dart';
import '../create_movie_list_screen.dart';
import '../movie_list_screen.dart';
import 'movie_list_card.dart';

/// Whose lists a [MovieListsSection] shows.
enum MovieListsOwner { mine, friends, saved }

/// A row of posted lists. "My lists" starts with a card to make a new one
/// and always shows; "Friends' lists" hides itself until a friend posts one,
/// and "Saved lists" (on your profile) until you save one.
class MovieListsSection extends StatefulWidget {
  const MovieListsSection({
    super.key,
    required this.owner,
    this.repository,
    this.bottomGap = 0,
  });

  final MovieListsOwner owner;
  final MovieListRepository? repository;

  /// Space under the section, only while it shows (Friends' lists hides
  /// itself when empty, and takes its gap with it).
  final double bottomGap;

  @override
  State<MovieListsSection> createState() => _MovieListsSectionState();
}

class _MovieListsSectionState extends State<MovieListsSection> {
  late final MovieListRepository _repository =
      widget.repository ?? ApiMovieListRepository();
  List<MovieList>? _lists;
  bool _failed = false;

  bool get _mine => widget.owner == MovieListsOwner.mine;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final lists = switch (widget.owner) {
        MovieListsOwner.mine => await _repository.fetchMine(),
        MovieListsOwner.friends => await _repository.fetchFriends(),
        MovieListsOwner.saved => await _repository.fetchSaved(),
      };
      if (!mounted) return;
      setState(() {
        _lists = lists;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _create() async {
    final created = await Navigator.of(context).push<MovieList>(
      MaterialPageRoute(
        builder: (_) => CreateMovieListScreen(repository: _repository),
      ),
    );
    if (created != null && mounted) unawaited(_load());
  }

  Future<void> _open(MovieList list) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MovieListScreen(list: list, repository: _repository),
      ),
    );
    // Hearts, comments, a save, an edit or a delete may have changed it.
    if (mounted) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lists = _lists;
    if (!_mine && (_failed || lists == null || lists.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomGap),
      child: _content(l10n, lists),
    );
  }

  Widget _content(AppLocalizations l10n, List<MovieList>? lists) {
    return Column(
      key: Key(switch (widget.owner) {
        MovieListsOwner.mine => 'my-lists',
        MovieListsOwner.friends => 'friends-lists',
        MovieListsOwner.saved => 'saved-lists',
      }),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: switch (widget.owner) {
            MovieListsOwner.mine => l10n.myListsTitle,
            MovieListsOwner.friends => l10n.friendsListsTitle,
            MovieListsOwner.saved => l10n.savedListsTitle,
          },
          subtitle: switch (widget.owner) {
            MovieListsOwner.mine => l10n.myListsHint,
            MovieListsOwner.friends => l10n.friendsListsHint,
            MovieListsOwner.saved => l10n.savedListsHint,
          },
        ),
        const SizedBox(height: 10),
        if (_failed)
          Text(l10n.listLoadFailed, style: TextStyle(color: LuxeColors.muted))
        else
          SizedBox(
            height: 236,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: (lists?.length ?? 0) + (_mine ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                if (_mine && i == 0) {
                  return _NewListCard(
                    onTap: _create,
                    showHint: lists != null && lists.isEmpty,
                  );
                }
                final list = lists![_mine ? i - 1 : i];
                return MovieListCard(list: list, onTap: () => _open(list));
              },
            ),
          ),
      ],
    );
  }
}

class _NewListCard extends StatelessWidget {
  const _NewListCard({required this.onTap, required this.showHint});

  final VoidCallback onTap;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.listNew,
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('new-movie-list'),
        onTap: onTap,
        child: SizedBox(
          width: showHint ? 220 : 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 170,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LuxeColors.hair, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.plus_lg,
                        size: 28, color: LuxeColors.text),
                    if (showHint) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.listsEmptyMine,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: LuxeColors.muted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.listNew,
                style: TextStyle(
                  color: LuxeColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
