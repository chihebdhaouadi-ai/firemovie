import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/sign_in_prompt.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/widgets/scroll_exit_effect.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_screen_event.dart';
import '../../bloc/home_screen_state.dart';
import '../../data/home_models.dart';
import '../home_navigation.dart';
import '../widgets/collections_box.dart';
import '../widgets/feed_section.dart';
import '../../../movie_lists/presentation/widgets/movie_lists_section.dart';
import '../widgets/latest_articles_section.dart';
import '../widgets/popular_this_week_section.dart';
import '../widgets/popular_with_friends_section.dart';
import '../widgets/section_header.dart';
import '../widgets/take_list_section.dart';
import '../widgets/trending_topics_section.dart';
import '../widgets/upcoming_films_section.dart';

/// The same space between every section of the You tab.
const _sectionGap = 6.0;

/// Space between the two columns on a wide window.
const _columnGap = 32.0;

/// From this content width the You tab shows two columns.
const youTabTwoColumnWidth = 900.0;

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
  final ExitInset exitInset;
  final ReviewRepository? reviews;

  /// Guests see the public sections (upcoming films, articles) and a sign-in
  /// prompt. The account-only sections are left out.
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<HomeBloc>();
    Widget section(Widget child) =>
        ScrollExitEffect(exitInset: exitInset, child: child);

    final signInPrompt = section(
      SignInPrompt(
        title: l10n.authGuestPromptTitle,
        body: l10n.authGuestPromptBody,
        reason: l10n.authReasonHome,
      ),
    );
    final popularThisWeek = section(
      PopularThisWeekSection(title: l10n.homePopularThisWeekTitle),
    );
    final upcoming = section(
      UpcomingFilmsSection(title: l10n.homeUpcomingThisMonthTitle),
    );
    // Inside the Friends Activity box, so without their own exit effect.
    final friendsFilms = Builder(
      builder: (context) => PopularWithFriendsSection(
        title: l10n.homeFriendsFilmsTitle,
        state: state.sections[HomeList.popular] ?? const SectionLoading(),
        onRetry: () =>
            bloc.add(const HomeSectionRetryRequested(HomeList.popular)),
        onOpenFilm: (film) => openOverview(context, film),
      ),
    );
    final trending = section(TrendingTopicsSection(reviews: reviews));
    final popularTakes = section(
      FeedSection(
        title: l10n.homePopularTakesTitle,
        state: state.feed,
        onRetry: () => bloc.add(const HomeFeedRetryRequested()),
        reviews: reviews,
      ),
    );
    final friendTakes = Builder(
      builder: (context) => TakeListSection(
        title: l10n.homeFriendsReviewsTitle,
        emptyMessage: l10n.homeFriendsReviewsEmpty,
        load: (repository) => repository.fetchFriendTakes(),
        reviews: reviews,
      ),
    );
    // What friends are watching and saying, in one box that can be made
    // taller or shorter like the Collections box.
    // Fades out under the header like the other sections, but keeps its
    // full width (no narrowing) while the page scrolls.
    final friendsActivity = ScrollExitEffect(
      exitInset: exitInset,
      maxShrink: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The title sits above the box, like the other sections' titles.
          SectionHeader(title: l10n.homeFriendsActivityTitle),
          const SizedBox(height: SectionHeader.contentGap),
          CollectionsBox(
            resizeLabel: l10n.homeFriendsActivityResize,
            // Starts folded to its smallest size; drag the grip to open it.
            initialHeight: CollectionsBox.minHeight,
            children: [
              friendsFilms,
              const SizedBox(height: _sectionGap),
              friendTakes,
              const SizedBox(height: _sectionGap),
            ],
          ),
        ],
      ),
    );
    // Friends' lists sit right before the articles, and only show once a
    // friend has posted one.
    final articles = section(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (signedIn)
            const MovieListsSection(
              owner: MovieListsOwner.friends,
              bottomGap: _sectionGap,
            ),
          LatestArticlesSection(title: l10n.homeLatestArticlesTitle),
        ],
      ),
    );

    // Section titles on this page are 20% smaller than elsewhere.
    return SectionTitleScale(
      scale: 0.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A wide window gets two columns: the film rows and takes on the
          // left, trending topics and articles on the right.
          if (constraints.maxWidth >= youTabTwoColumnWidth) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _column([
                    if (!signedIn) signInPrompt,
                    // Friends Activity opens the page.
                    if (signedIn) ...[friendsActivity, popularThisWeek],
                    upcoming,
                    if (signedIn) popularTakes,
                  ]),
                ),
                const SizedBox(width: _columnGap),
                Expanded(
                  flex: 2,
                  child: _column([
                    if (signedIn) trending,
                    articles,
                  ]),
                ),
              ],
            );
          }
          return _column([
            if (!signedIn) signInPrompt,
            // Friends Activity opens the page.
            if (signedIn) ...[friendsActivity, popularThisWeek],
            upcoming,
            if (signedIn) ...[
              trending,
              popularTakes,
            ],
            articles,
          ]);
        },
      ),
    );
  }

  /// [sections] one under the other, with the same gap between each.
  static Widget _column(List<Widget> sections) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, s) in sections.indexed) ...[
            if (i > 0) const SizedBox(height: _sectionGap),
            s,
          ],
        ],
      );
}
