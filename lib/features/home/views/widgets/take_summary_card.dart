import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/api_config.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/domain/vote_kind.dart';
import '../../../film_reviews/presentation/reaction_labels.dart';
import '../../data/home_models.dart';
import 'film_tile.dart';

const _avatarSize = 36.0;
const _avatarRing = 2.0;
const _posterWidth = 32.0;
const _posterHeight = _posterWidth * 3 / 2;
const _quoteBarWidth = 3.0;

class TakeSummaryCard extends StatelessWidget {
  const TakeSummaryCard({
    super.key,
    required this.take,
    this.film,
    this.onTap,
  });

  final Take take;
  final Film? film;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final createdAt = take.createdAt;
    final film = this.film;

    return GameCard(
      onTap: onTap,
      padding: EdgeInsets.all(tokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TakeAvatar(
                name: take.authorName,
                url: take.authorAvatarUrl,
                size: _avatarSize,
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      take.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        relativeTakeTime(context, createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              _ReactionBadge(
                label: takeBadgeLabel(l10n, take),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          _Quote(text: l10n.reviewQuote(take.body)),
          if (film != null) ...[
            SizedBox(height: tokens.spaceMd),
            _FilmStrip(film: film),
          ],
          if (take.totalVotes > 0) ...[
            SizedBox(height: tokens.spaceMd),
            Container(height: 2, color: GameColors.edge),
            SizedBox(height: tokens.spaceMd),
            _VoteStats(take: take),
          ],
        ],
      ),
    );
  }
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
      decoration: const BoxDecoration(
        color: AppColors.accent,
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

class _ReactionBadge extends StatelessWidget {
  const _ReactionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: GameColors.deep,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GameColors.edge, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceXs,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: GameColors.blue1, width: _quoteBarWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: tokens.spaceMd),
        child: Text(
          text,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _FilmStrip extends StatelessWidget {
  const _FilmStrip({required this.film});

  final Film film;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Row(
      children: [
        FilmPoster(
          film: film,
          width: _posterWidth,
          height: _posterHeight,
          radius: tokens.radiusSm,
        ),
        SizedBox(width: tokens.spaceMd),
        Expanded(
          child: Text(
            film.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteStats extends StatelessWidget {
  const _VoteStats({required this.take});

  final Take take;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(fontSize: 12);

    return Wrap(
      spacing: tokens.spaceMd,
      runSpacing: tokens.spaceXs,
      children: [
        for (final kind in VoteKind.values)
          if (take.votesOf(kind) > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${take.votesOf(kind)}',
                  style: style?.copyWith(
                    color: AppColors.accentGlow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: tokens.spaceXs),
                Text(
                  voteLabel(l10n, kind),
                  style: style?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
      ],
    );
  }
}
