import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/home_models.dart';

class FilmPoster extends StatelessWidget {
  const FilmPoster({
    super.key,
    required this.film,
    required this.width,
    this.height,
    this.radius,
    this.heroTag,
  });

  final Film film;
  final double width;
  final double? height;
  final double? radius;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final height = this.height ?? tokens.posterHeight(width);
    final url = film.posterUrl;
    final heroTagValue = heroTag;

    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? tokens.radiusMd),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? const PosterPlaceholder()
            : PosterImage(url: url, width: width, height: height),
      ),
    );

    if (heroTagValue == null) return poster;
    return Hero(tag: heroTagValue, child: poster);
  }
}

/// A poster image that retries failed loads (automatically, then with a
/// manual retry button) instead of staying blank.
class PosterImage extends StatefulWidget {
  const PosterImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  State<PosterImage> createState() => _PosterImageState();
}

class _PosterImageState extends State<PosterImage> {
  static const _autoRetryLimit = 2;
  static const _retryDelay = Duration(seconds: 2);

  int _attempt = 0;
  int _failures = 0;
  Timer? _retryTimer;

  @override
  void didUpdateWidget(covariant PosterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _retryTimer?.cancel();
      _attempt = 0;
      _failures = 0;
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _onError(Object error) {
    _failures++;
    if (_failures <= _autoRetryLimit) {
      _retryTimer?.cancel();
      _retryTimer = Timer(_retryDelay * _failures, _reload);
    }
    if (mounted) setState(() {});
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _attempt++);
  }

  void _retryManually() {
    _failures = 0;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheKey = _attempt == 0 ? widget.url : '${widget.url}#$_attempt';

    return CachedNetworkImage(
      key: ValueKey(_attempt),
      imageUrl: widget.url,
      cacheKey: cacheKey,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      memCacheWidth: (widget.width * devicePixelRatio).round(),
      memCacheHeight: (widget.height * devicePixelRatio).round(),
      errorListener: _onError,
      placeholder: (context, url) => const PosterPlaceholder(),
      errorWidget: (context, url, error) => _failures <= _autoRetryLimit
          ? const PosterPlaceholder()
          : _PosterRetry(onRetry: _retryManually),
    );
  }
}

class _PosterRetry extends StatelessWidget {
  const _PosterRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      child: InkWell(
        onTap: onRetry,
        child: Center(
          child: Tooltip(
            message: context.l10n.homeSectionErrorRetry,
            child: Icon(
              BootstrapIcons.arrow_clockwise,
              color: AppColors.textMuted,
              size: context.tokens.iconLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final iconLarge = context.tokens.iconLarge;
    return ColoredBox(
      color: AppColors.surfaceRaised,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Icon(
            BootstrapIcons.film,
            color: AppColors.textMuted,
            size:
                (constraints.biggest.shortestSide * 0.5).clamp(0.0, iconLarge),
          ),
        ),
      ),
    );
  }
}

class FilmTile extends StatelessWidget {
  const FilmTile({
    super.key,
    required this.film,
    required this.width,
    required this.semanticsLabel,
    required this.removeLabel,
    this.heroTag,
    this.onTap,
    this.onRemove,
  });

  final Film film;
  final double width;
  final String semanticsLabel;
  final String removeLabel;
  final Object? heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tap = onTap;
    final remove = onRemove;

    return Semantics(
      button: tap != null,
      label: semanticsLabel,
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              onTap: tap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      tap();
                    },
              child: ExcludeSemantics(
                child: FilmPoster(
                  film: film,
                  width: width,
                  heroTag: heroTag,
                ),
              ),
            ),
            if (remove != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    remove();
                  },
                  constraints: BoxConstraints.tightFor(
                    width: tokens.minTouchTarget,
                    height: tokens.minTouchTarget,
                  ),
                  icon: Container(
                    padding: EdgeInsets.all(tokens.spaceXs),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      BootstrapIcons.x_lg,
                      size: tokens.iconSmall,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  tooltip: removeLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
