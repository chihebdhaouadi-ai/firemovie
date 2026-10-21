import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/movie.dart';

const _headerHeight = 260.0;
const _posterWidth = 112.0;
const _posterHeight = 168.0;
const _posterOverlap = 118.0;
const _stillInterval = Duration(seconds: 5);
const _stillFade = Duration(milliseconds: 700);

class FilmHeroHeader extends StatefulWidget {
  const FilmHeroHeader({
    super.key,
    required this.movie,
    this.heroTag,
    this.stills = const [],
  });

  final Movie movie;
  final Object? heroTag;
  final List<String> stills;

  @override
  State<FilmHeroHeader> createState() => _FilmHeroHeaderState();
}

class _FilmHeroHeaderState extends State<FilmHeroHeader> {
  Timer? _timer;
  int _stillIndex = 0;

  @override
  void initState() {
    super.initState();
    _restartCycle();
  }

  @override
  void didUpdateWidget(FilmHeroHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.stills, widget.stills)) {
      _stillIndex = 0;
      _restartCycle();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartCycle() {
    _timer?.cancel();
    _timer = null;
    if (widget.stills.length < 2) return;
    _timer = Timer.periodic(_stillInterval, (_) {
      setState(() => _stillIndex = (_stillIndex + 1) % widget.stills.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final movie = widget.movie;
    final overview = movie.overview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _headerHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: widget.heroTag ?? 'detail-${movie.id}',
                child: _backdrop(),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceSm),
                    child: IconButton(
                      tooltip: l10n.overviewBack,
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceLg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _posterHeight - _posterOverlap,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: _posterWidth + tokens.spaceSm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                SizedBox(height: tokens.spaceXs),
                                Text(
                                  _subtitle(context, movie),
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                                if (movie.genres.isNotEmpty) ...[
                                  SizedBox(height: tokens.spaceSm),
                                  Wrap(
                                    spacing: tokens.spaceXs,
                                    children: [
                                      for (final genre in movie.genres)
                                        _chip(context, genre),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          PositionedDirectional(
                            end: 0,
                            top: -(_posterOverlap + tokens.spaceLg),
                            child: _SlideIn(
                              key: ValueKey(movie.posterUrl),
                              child: _poster(context, movie),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (overview != null) ...[
                    SizedBox(height: tokens.spaceLg),
                    Text(
                      l10n.findDetailsOverview,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      overview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backdrop() {
    final stills = widget.stills;
    final url = stills.isEmpty
        ? widget.movie.backdropUrl ?? widget.movie.posterUrl
        : stills[_stillIndex % stills.length];

    return AnimatedSwitcher(
      duration: _stillFade,
      child: SizedBox.expand(
        key: ValueKey(url),
        child: url == null
            ? const ColoredBox(
                color: AppColors.surface,
                child: Center(
                  child: Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: AppColors.surface),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: AppColors.surface),
              ),
      ),
    );
  }

  Widget _poster(BuildContext context, Movie movie) {
    final tokens = context.tokens;
    final url = movie.posterUrl;
    return Container(
      width: _posterWidth,
      height: _posterHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: url == null
          ? Center(
              child: Icon(Icons.movie_outlined, color: AppColors.textMuted),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: AppColors.surface),
              errorWidget: (_, __, ___) => Center(
                child: Icon(Icons.movie_outlined, color: AppColors.textMuted),
              ),
            ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(context.tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: context.tokens.spaceSm,
          vertical: 4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accentGlow,
              ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, Movie movie) {
    final l10n = context.l10n;
    final parts = <String>[
      if (movie.year != null) '${movie.year}',
      if (movie.director != null) '${l10n.findDirectedBy} ${movie.director}',
      if (movie.runtime != null) l10n.findDetailsRuntime(movie.runtime!),
      if (movie.voteAverage != null)
        l10n.findDetailsVote(movie.voteAverage!.toStringAsFixed(1)),
    ];
    return parts.join(' · ');
  }
}

class _SlideIn extends StatelessWidget {
  const _SlideIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 40),
          child: child,
        ),
      ),
    );
  }
}
