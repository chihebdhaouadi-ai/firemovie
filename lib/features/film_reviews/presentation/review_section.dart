import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../overview/views/widgets/overview_panel.dart';
import '../data/api_review_repository.dart';
import '../data/review_repository.dart';
import '../domain/take.dart';
import 'state/movie_reviews_cubit.dart';
import 'state/movie_reviews_state.dart';
import 'widgets/reaction_card.dart';
import 'widgets/score_card.dart';
import 'widgets/takes_card.dart';
import '../../../core/widgets/game_button.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.movieId,
    this.repository,
    this.highlightTakeId,
  });

  final String movieId;
  final ReviewRepository? repository;
  final int? highlightTakeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieReviewsCubit(
        filmId: movieId,
        repository: repository ?? ApiReviewRepository(),
      )..load(),
      child: _ReviewSectionBody(highlightTakeId: highlightTakeId),
    );
  }
}

class _ReviewSectionBody extends StatelessWidget {
  const _ReviewSectionBody({this.highlightTakeId});

  final int? highlightTakeId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final side = tokens.spaceLg +
            math.max(
              0.0,
              (constraints.crossAxisExtent - tokens.maxContentWidth) / 2,
            );
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: side),
          sliver: BlocBuilder<MovieReviewsCubit, MovieReviewsState>(
            builder: (context, state) => _ReviewSlivers(
              state: state,
              highlightTakeId: highlightTakeId,
            ),
          ),
        );
      },
    );
  }
}

class _ReviewSlivers extends StatelessWidget {
  const _ReviewSlivers({required this.state, this.highlightTakeId});

  final MovieReviewsState state;
  final int? highlightTakeId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final cubit = context.read<MovieReviewsCubit>();
    final takes = state.takes;
    final hasTake = takes is AsyncReady<List<Take>> &&
        takes.value.any((take) => take.isMine);

    final slivers = <Widget>[
      SliverToBoxAdapter(child: SizedBox(height: tokens.spaceLg)),
    ];
    void box(Widget child) => slivers.add(SliverToBoxAdapter(child: child));
    void gap() => box(SizedBox(height: tokens.spaceMd));

    switch (state.summary) {
      case AsyncLoading():
        box(const _SummaryLoading());
      case AsyncFailed():
        box(_ErrorPanel(
          message: l10n.reviewSummaryFailed,
          onRetry: cubit.load,
        ));
      case AsyncReady(:final value):
        box(ScoreCard(summary: value));
        gap();
        box(ReactionCard(
          reaction: value.myReaction,
          hasTake: hasTake,
          onReactionChanged: cubit.setReaction,
          onShare: cubit.shareTake,
        ));
        gap();
    }

    box(TakesCard(
      takes: takes,
      onRetry: cubit.load,
      highlightTakeId: highlightTakeId,
    ));
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: tokens.spaceLg)));

    return SliverMainAxisGroup(slivers: slivers);
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: AppColors.accentGlow,
      backgroundColor: AppColors.surfaceRaised,
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          SizedBox(height: tokens.spaceSm),
          GameButton(
            label: l10n.reviewRetry,
            style: GameButtonStyle.blue,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
