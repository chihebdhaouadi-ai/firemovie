import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take.dart';
import '../../../film_reviews/presentation/reaction_labels.dart';
import '../../../film_reviews/presentation/review_detail_screen.dart';
import '../../../profile/views/profile_screen.dart';
import 'overview_panel.dart';

class FriendActivity extends StatefulWidget {
  const FriendActivity({super.key, required this.movieId, this.repository});

  final String movieId;
  final ReviewRepository? repository;

  @override
  State<FriendActivity> createState() => _FriendActivityState();
}

class _FriendActivityState extends State<FriendActivity> {
  late final ReviewRepository _repository =
      widget.repository ?? ApiReviewRepository();
  late final Future<List<FriendFilmActivity>> _future =
      _repository.fetchFriendActivity(widget.movieId);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overviewActivityTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          FutureBuilder<List<FriendFilmActivity>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator(
                  color: AppColors.accentGlow,
                  backgroundColor: AppColors.surfaceRaised,
                );
              }
              if (snapshot.hasError) {
                return Text(
                  l10n.findDetailsErrorTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                );
              }
              final items = snapshot.data ?? const <FriendFilmActivity>[];
              if (items.isEmpty) {
                return Text(
                  l10n.overviewNoFriendActivity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(height: tokens.spaceSm),
                    _FriendRow(
                      activity: items[i],
                      movieId: widget.movieId,
                      repository: widget.repository,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.activity,
    required this.movieId,
    this.repository,
  });

  final FriendFilmActivity activity;
  final String movieId;
  final ReviewRepository? repository;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final takeBody = activity.takeBody;
    final takeId = activity.takeId;

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => takeId == null
              ? ProfileScreen(userId: activity.userId)
              : ReviewDetailScreen(
                  movieId: movieId,
                  takeId: takeId,
                  repository: repository,
                ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spaceXs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: tokens.minTouchTarget / 2,
              backgroundColor: AppColors.surfaceRaised,
              child: Text(
                activity.username.substring(0, 1).toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.accentGlow,
                ),
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.username,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    reactionChipLabel(l10n, activity.reaction),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (takeBody != null) ...[
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      takeBody,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
