import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/find/data/movie.dart';
import '../../../features/find/views/film_detail_screen.dart';
import '../../blocs/home_bloc.dart';
import '../../blocs/home_state.dart';
import '../../data/top_5_movies_model.dart';

class Movie_Page extends StatelessWidget {
  const Movie_Page({super.key, required this.arg});

  final String arg;

  @override
  Widget build(BuildContext context) {
    return FilmDetailScreen(
      movie: Movie(id: arg, title: ''),
      footer: _FriendsReviews(imdbId: arg),
    );
  }
}

class _FriendsReviews extends StatefulWidget {
  const _FriendsReviews({required this.imdbId});

  final String imdbId;

  @override
  State<_FriendsReviews> createState() => _FriendsReviewsState();
}

class _FriendsReviewsState extends State<_FriendsReviews> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBLoc>().Get_Review_movies_movies(
          Review_MoviesTrigerState(token: Session.token, imdbid: widget.imdbId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return BlocBuilder<ReviewBLoc, Top_5_moviesState>(
      builder: (context, state) {
        if (state is! Movie_Rating_moviesLoadedState ||
            state.movies_rating.reviews.isEmpty) {
          return const SizedBox.shrink();
        }
        final data = state.movies_rating;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.overviewFriendsReviews,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                const Icon(BootstrapIcons.star_fill, color: Colors.amber, size: 18),
                SizedBox(width: tokens.spaceXs),
                Text(
                  '${data.moyen}/5',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            for (final review in data.reviews) ...[
              _ReviewTile(review: review),
              SizedBox(height: tokens.spaceSm),
            ],
          ],
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review_Model review;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surface,
                  backgroundImage: review.image_link.isEmpty
                      ? null
                      : CachedNetworkImageProvider(review.image_link),
                ),
                SizedBox(width: tokens.spaceSm),
                Expanded(
                  child: Text(
                    context.l10n.overviewReviewBy(
                      review.writer_name,
                      review.data,
                    ),
                    style: muted,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceXs),
            Text(
              review.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SizedBox(height: tokens.spaceXs),
            Row(
              children: [
                const Icon(BootstrapIcons.star_fill, color: Colors.amber, size: 14),
                Text(' ${review.rating}', style: muted),
                SizedBox(width: tokens.spaceSm),
                Icon(BootstrapIcons.hand_thumbs_up,
                    size: 14, color: AppColors.textMuted),
                Text(' ${review.likes}', style: muted),
                SizedBox(width: tokens.spaceSm),
                Icon(BootstrapIcons.hand_thumbs_down,
                    size: 14, color: AppColors.textMuted),
                Text(' ${review.Disliles}', style: muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
