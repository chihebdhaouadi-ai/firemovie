import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../home/data/home_models.dart';
import '../../../home/views/feed_list_screen.dart';
import '../../../home/views/widgets/feed_take_card.dart';

/// How many saved topics show on the profile before "See all".
const int savedTakesPreview = 3;

/// The topics you saved, newest first, on your own profile. Each opens its
/// page; "See all" lists every one.
class SavedTakesSection extends StatefulWidget {
  const SavedTakesSection({super.key, this.reviews});

  final ReviewRepository? reviews;

  @override
  State<SavedTakesSection> createState() => _SavedTakesSectionState();
}

class _SavedTakesSectionState extends State<SavedTakesSection> {
  late final ReviewRepository _reviews =
      widget.reviews ?? ApiReviewRepository();
  List<FeedItem>? _items;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final items = await _reviews.fetchSavedTakes();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _items = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final items = _items;
    // Nothing until it loads, so the profile doesn't jump around a spinner.
    if (items == null) return const SizedBox.shrink();

    return Column(
      key: const Key('profile-saved'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: tokens.spaceXl, bottom: tokens.spaceMd),
          child: Text(
            l10n.profileSavedTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (items.isEmpty)
          Text(
            l10n.profileSavedEmpty,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          )
        else ...[
          for (final item in items.take(savedTakesPreview))
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spaceSm),
              child: FeedTakeCard(
                key: ValueKey('saved-${item.take.id}'),
                item: item,
                heroScope: 'profile-saved',
                reviews: _reviews,
              ),
            ),
          if (items.length > savedTakesPreview)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('profile-saved-all'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => FeedListScreen(
                      title: l10n.profileSavedTitle,
                      items: items,
                      reviews: _reviews,
                    ),
                  ),
                ),
                child: Text(l10n.overviewSeeAll),
              ),
            ),
        ],
      ],
    );
  }
}
