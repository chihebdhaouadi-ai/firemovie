import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/film_tile.dart';
import '../../home/views/widgets/take_summary_card.dart';
import '../data/api_review_repository.dart';
import '../data/review_repository.dart';
import '../domain/take.dart';
import 'state/movie_reviews_cubit.dart';
import 'state/movie_reviews_state.dart';
import 'take_hero.dart';
import 'widgets/take_card.dart';

class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({
    super.key,
    required this.movieId,
    required this.takeId,
    this.initialItem,
    this.heroTag,
    this.repository,
  });

  final String movieId;
  final int takeId;
  final FeedItem? initialItem;
  final Object? heroTag;
  final ReviewRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieReviewsCubit(
        filmId: movieId,
        repository: repository ?? ApiReviewRepository(),
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(context.l10n.reviewDetailTitle),
        ),
        body: _TakeDetailBody(
          takeId: takeId,
          initialItem: initialItem,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _TakeDetailBody extends StatelessWidget {
  const _TakeDetailBody({
    required this.takeId,
    required this.initialItem,
    required this.heroTag,
  });

  final int takeId;
  final FeedItem? initialItem;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return BlocBuilder<MovieReviewsCubit, MovieReviewsState>(
      builder: (context, state) {
        final takes = state.takes;
        final take = _resolveTake(takes) ?? initialItem?.take;

        if (take == null) {
          final failed = takes is AsyncFailed<List<Take>>;
          final loading = takes is AsyncLoading<List<Take>>;
          return Padding(
            padding: EdgeInsets.all(tokens.spaceLg),
            child: loading
                ? const LinearProgressIndicator(
                    color: AppColors.accentGlow,
                    backgroundColor: AppColors.surfaceRaised,
                  )
                : Text(
                    failed ? l10n.reviewTakesFailed : l10n.reviewTakesEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
          );
        }

        final film = initialItem?.film;
        final summary = TakeSummaryCard(take: take, film: film);
        final tag = heroTag;

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (film != null) ...[
                    Center(
                      child: FilmPoster(
                        film: film,
                        width: 160,
                        radius: tokens.radiusLg,
                      ),
                    ),
                    SizedBox(height: tokens.spaceLg),
                  ],
                  tag == null
                      ? summary
                      : Hero(
                          tag: tag,
                          flightShuttleBuilder: takeHeroFlightShuttle,
                          child: summary,
                        ),
                  SizedBox(height: tokens.spaceMd),
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      side: const BorderSide(color: AppColors.surfaceRaised),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceLg),
                      child: TakeCard(
                        take: take,
                        isMostHelpful: false,
                        expandComments: true,
                        showBody: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Take? _resolveTake(AsyncView<List<Take>> takes) {
    if (takes is! AsyncReady<List<Take>>) return null;
    for (final take in takes.value) {
      if (take.id == takeId) return take;
    }
    return null;
  }
}
