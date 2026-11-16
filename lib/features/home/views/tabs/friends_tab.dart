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
import '../../data/home_models.dart';
import '../home_navigation.dart';
import '../widgets/film_section.dart';
import '../widgets/take_list_section.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({
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

  /// Friends' films and takes need an account, so guests see a sign-in prompt.
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final bloc = context.read<HomeBloc>();

    if (!signedIn) {
      return ScrollExitEffect(
        exitInset: exitInset,
        child: SignInPrompt(
          title: l10n.authGuestPromptTitle,
          body: l10n.authGuestPromptBody,
          reason: l10n.authReasonHome,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrollExitEffect(
          exitInset: exitInset,
          child: FilmSection(
            title: l10n.homeFriendsFilmsTitle,
            state: state.sections[HomeList.popular] ?? const SectionLoading(),
            tileWidth: tokens.filmTileWidth,
            onRetry: () =>
                bloc.add(const HomeSectionRetryRequested(HomeList.popular)),
            onOpenFilm: (film) => openOverview(context, film),
          ),
        ),
        SizedBox(height: tokens.spaceXl),
        ScrollExitEffect(
          exitInset: exitInset,
          child: TakeListSection(
            title: l10n.homeFriendsReviewsTitle,
            emptyMessage: l10n.homeFriendsReviewsEmpty,
            load: (repository) => repository.fetchFriendTakes(),
            reviews: reviews,
          ),
        ),
      ],
    );
  }
}
