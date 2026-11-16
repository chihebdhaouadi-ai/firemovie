import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/sign_in_prompt.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/scroll_exit_effect.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_screen_event.dart';
import '../../bloc/home_screen_state.dart';
import '../widgets/feed_section.dart';
import '../widgets/latest_articles_section.dart';
import '../widgets/popular_this_week_section.dart';
import '../widgets/trending_topics_section.dart';
import '../widgets/upcoming_films_section.dart';

class YouTab extends StatelessWidget {
  const YouTab({
    super.key,
    required this.state,
    required this.exitInset,
    this.reviews,
    this.signedIn = true,
  });

  final HomeLoaded state;

  /// Pinned header height; sections blur and narrow once they pass it.
  final double exitInset;
  final ReviewRepository? reviews;

  /// Guests see the public sections (upcoming films, articles) and a sign-in
  /// prompt. The account-only sections are left out.
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final bloc = context.read<HomeBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!signedIn) ...[
          ScrollExitEffect(
            exitInset: exitInset,
            child: SignInPrompt(
              title: l10n.authGuestPromptTitle,
              body: l10n.authGuestPromptBody,
              reason: l10n.authReasonHome,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
        ],
        if (signedIn) ...[
          ScrollExitEffect(
            exitInset: exitInset,
            child: PopularThisWeekSection(title: l10n.homePopularThisWeekTitle),
          ),
          SizedBox(height: tokens.spaceXs),
        ],
        ScrollExitEffect(
          exitInset: exitInset,
          child: UpcomingFilmsSection(title: l10n.homeUpcomingThisMonthTitle),
        ),
        if (signedIn) ...[
          SizedBox(height: tokens.spaceMd),
          ScrollExitEffect(
            exitInset: exitInset,
            child: TrendingTopicsSection(reviews: reviews),
          ),
          SizedBox(height: tokens.spaceMd),
          ScrollExitEffect(
            exitInset: exitInset,
            child: FeedSection(
              title: l10n.homePopularTakesTitle,
              state: state.feed,
              onRetry: () => bloc.add(const HomeFeedRetryRequested()),
              reviews: reviews,
            ),
          ),
        ],
        SizedBox(height: tokens.spaceMd),
        ScrollExitEffect(
          exitInset: exitInset,
          child: LatestArticlesSection(title: l10n.homeLatestArticlesTitle),
        ),
      ],
    );
  }
}
