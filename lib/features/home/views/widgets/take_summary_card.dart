import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/api_config.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/presentation/reaction_labels.dart';
import '../../../film_reviews/presentation/widgets/take_heart.dart';
import '../../data/home_models.dart';
import 'film_tile.dart';

const _avatarSize = 30.0;
const _avatarRing = 0.0;
const _posterWidth = 24.0;
const _posterHeight = _posterWidth * 3 / 2;

/// A friend's take in the home carousels and lists: a flat tonal card with
/// no border or shadow. A quiet line with who and when (and their reaction
/// as plain text), the take itself as the largest thing on the card, then a
/// small poster and the film's title.
class TakeSummaryCard extends StatelessWidget {
  const TakeSummaryCard({
    super.key,
    required this.take,
    this.film,
    this.onTap,
    this.fillHeight = false,
    this.reviews,
  });

  final Take take;
  final Film? film;
  final VoidCallback? onTap;

  /// Where the card's heart saves.
  final ReviewRepository? reviews;

  /// In a row of cards stretched to the same height: keeps the film row at
  /// the bottom. Leave false where the height is unbounded (lists).
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final film = this.film;

    return Material(
      // Same as the trending topic cards.
      color: LuxeColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaLine(take: take),
              const SizedBox(height: 12),
              _SeeMoreText(
                text: l10n.reviewQuote(take.body),
                seeMoreKey: Key('take-see-more-${take.id}'),
                onSeeMore: onTap,
              ),
              if (fillHeight) const Spacer(),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (film != null) ...[
                    FilmPoster(
                      film: film,
                      width: _posterWidth,
                      height: _posterHeight,
                      radius: 3,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        film.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LuxeColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  // The one reaction on takes and topics.
                  TakeHeart(take: take, reviews: reviews, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The take's text, cut at four lines with a "See more" link under it when
/// it is longer. The cut is read from the laid-out paragraph, so it works
/// inside intrinsic-height rows where a LayoutBuilder can't.
class _SeeMoreText extends StatefulWidget {
  const _SeeMoreText({
    required this.text,
    required this.seeMoreKey,
    this.onSeeMore,
  });

  final String text;
  final Key seeMoreKey;
  final VoidCallback? onSeeMore;

  static const maxLines = 4;

  @override
  State<_SeeMoreText> createState() => _SeeMoreTextState();
}

class _SeeMoreTextState extends State<_SeeMoreText> {
  final _textKey = GlobalKey();
  bool _cut = false;

  void _check() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final paragraph = _textKey.currentContext?.findRenderObject();
      final cut = paragraph is RenderParagraph && paragraph.didExceedMaxLines;
      if (cut != _cut) setState(() => _cut = cut);
    });
  }

  @override
  Widget build(BuildContext context) {
    _check();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          key: _textKey,
          maxLines: _SeeMoreText.maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: LuxeColors.text,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        if (_cut)
          GestureDetector(
            key: widget.seeMoreKey,
            onTap: widget.onSeeMore,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.topicSeeMore,
                style: TextStyle(
                  color: LuxeColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Avatar, then the name with a quiet second line: when, and the reaction
/// or tag as plain text.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.take});

  final Take take;

  @override
  Widget build(BuildContext context) {
    final createdAt = take.createdAt;
    final details = [
      if (createdAt != null) relativeTakeTime(context, createdAt),
      _reactionText(context, take),
    ].join('  ·  ');
    return Row(
      children: [
        TakeAvatar(
          name: take.authorName,
          url: take.authorAvatarUrl,
          size: _avatarSize,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              Text(
                details,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LuxeColors.muted,
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The take's reaction (or its tag) as words only: emoji don't render on
/// every device and the line reads calmer without them.
String _reactionText(BuildContext context, Take take) {
  final l10n = context.l10n;
  final reaction = take.reaction;
  return reaction == null
      ? topicTagLabel(l10n, take.tag)
      : reactionLabel(l10n, reaction);
}

String relativeTakeTime(BuildContext context, DateTime createdAt) {
  final l10n = context.l10n;
  final elapsed = DateTime.now().difference(createdAt);
  if (elapsed.inMinutes < 1) return l10n.reviewTimeJustNow;
  if (elapsed.inHours < 1) return l10n.reviewTimeMinutes(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.reviewTimeHours(elapsed.inHours);
  return l10n.reviewTimeDays(elapsed.inDays);
}

String? absoluteApiUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '${ApiConfig.baseUrl}/${path.replaceFirst(RegExp(r'^/+'), '')}';
}

class TakeAvatar extends StatelessWidget {
  const TakeAvatar(
      {super.key, required this.name, required this.size, this.url});

  final String name;
  final double size;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final imageUrl = absoluteApiUrl(url);
    final fallback = ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
    final inner = size - _avatarRing * 2;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(_avatarRing),
      decoration: BoxDecoration(
        color: _avatarRing > 0 ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: (inner * devicePixelRatio).round(),
                memCacheHeight: (inner * devicePixelRatio).round(),
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
