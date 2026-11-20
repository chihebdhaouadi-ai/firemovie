import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../film_reviews/data/api_review_repository.dart';
import '../../../film_reviews/data/review_repository.dart';
import '../../../film_reviews/domain/take_tag.dart';
import '../../data/home_models.dart';
import '../widgets/explore_thread_sheet.dart';
import '../widgets/explore_take_card.dart';

/// Which kinds of post the feed shows. Filtering happens on the loaded list.
enum ExploreFilter {
  all,
  conversations,
  polls,
  scenes,
  questions,
  reviews;

  bool matches(TakeTag tag) => switch (this) {
        ExploreFilter.all => true,
        ExploreFilter.conversations =>
          tag == TakeTag.discussion || tag == TakeTag.hotTake,
        ExploreFilter.polls => tag == TakeTag.poll,
        ExploreFilter.scenes => tag == TakeTag.scene,
        ExploreFilter.questions => tag == TakeTag.question,
        ExploreFilter.reviews => tag == TakeTag.review,
      };

  String label(AppLocalizations l10n) => switch (this) {
        ExploreFilter.all => l10n.exploreFilterAll,
        ExploreFilter.conversations => l10n.exploreFilterConversations,
        ExploreFilter.polls => l10n.exploreFilterPolls,
        ExploreFilter.scenes => l10n.exploreFilterScenes,
        ExploreFilter.questions => l10n.exploreFilterQuestions,
        ExploreFilter.reviews => l10n.exploreFilterReviews,
      };
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key, this.reviews});

  final ReviewRepository? reviews;

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  late final ReviewRepository _repository =
      widget.reviews ?? ApiReviewRepository();
  late Future<List<FeedItem>> _items = _loadItems();
  ExploreFilter _filter = ExploreFilter.all;

  Future<List<FeedItem>> _loadItems() => _repository.fetchExploreFeed();

  void _retry() {
    setState(() {
      _items = _loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<FeedItem>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.homeSectionErrorTitle, textAlign: TextAlign.center),
                TextButton(
                  onPressed: _retry,
                  child: Text(l10n.homeSectionErrorRetry),
                ),
              ],
            ),
          );
        }
        final items = snapshot.data;
        if (items == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final visible = [
          for (final item in items)
            if (_filter.matches(item.take.tag)) item,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isNotEmpty)
              _ExploreFilterChips(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
            Expanded(
              child: _ExploreCarousel(
                items: visible,
                repository: _repository,
                onThreadClosed: _retry,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExploreFilterChips extends StatelessWidget {
  const _ExploreFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final ExploreFilter selected;
  final ValueChanged<ExploreFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return SizedBox(
      height: tokens.minTouchTarget,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
        children: [
          for (final filter in ExploreFilter.values)
            Padding(
              padding: EdgeInsetsDirectional.only(end: tokens.spaceXs),
              child: ChoiceChip(
                label: Text(filter.label(l10n)),
                selected: filter == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(filter),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: filter == selected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.accent.withValues(alpha: .18),
                side: BorderSide(
                  color: filter == selected
                      ? AppColors.accent
                      : AppColors.surfaceRaised,
                ),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreCarousel extends StatefulWidget {
  const _ExploreCarousel({
    required this.items,
    required this.repository,
    required this.onThreadClosed,
  });

  final List<FeedItem> items;
  final ReviewRepository repository;
  final VoidCallback onThreadClosed;

  @override
  State<_ExploreCarousel> createState() => _ExploreCarouselState();
}

class _ExploreCarouselState extends State<_ExploreCarousel> {
  static const _sideScale = .82;

  PageController? _controller;
  int _activeIndex = 0;
  int _threadRevision = 0;

  @override
  void didUpdateWidget(_ExploreCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.items.map((item) => item.take.id).toList();
    final newIds = widget.items.map((item) => item.take.id).toList();
    if (!listEquals(oldIds, newIds)) {
      _activeIndex = 0;
      if (_controller?.hasClients ?? false) _controller!.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _select(int index) {
    final controller = _controller;
    if (controller == null || !controller.hasClients || index == _activeIndex) {
      return;
    }
    controller.animateToPage(
      index,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openThread(FeedItem item) async {
    await showExploreThreadSheet(
      context,
      item: item,
      repository: widget.repository,
    );
    if (!mounted) return;
    setState(() => _threadRevision++);
    widget.onThreadClosed();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              BootstrapIcons.check_all,
              size: tokens.iconLarge,
              color: AppColors.textMuted,
            ),
            SizedBox(height: tokens.spaceMd),
            Text(
              l10n.exploreCaughtUp,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = _controller ??= _createController(
          constraints.maxWidth,
          MediaQuery.sizeOf(context).width,
          tokens.spaceMd,
        );
        return PageView.builder(
          controller: controller,
          itemCount: widget.items.length,
          // PageView pads both ends so the first and last cards can be centered.
          padEnds: true,
          onPageChanged: (index) => setState(() => _activeIndex = index),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return AnimatedBuilder(
              animation: controller,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spaceMd,
                  vertical: tokens.spaceMd,
                ),
                child: ExploreTakeCard(
                  key: ValueKey('explore-card-${item.take.id}'),
                  item: item,
                  repository: widget.repository,
                  threadRevision: _threadRevision,
                  isActive: index == _activeIndex,
                  onSelect: () => _select(index),
                  onOpenThread: () async {
                    if (index != _activeIndex) {
                      _select(index);
                    } else {
                      await _openThread(item);
                    }
                  },
                ),
              ),
              builder: (context, child) {
                final page = controller.hasClients
                    ? controller.page ?? _activeIndex.toDouble()
                    : _activeIndex.toDouble();
                final pageDelta = (page - index).clamp(-1.0, 1.0).toDouble();
                final distance = pageDelta.abs();
                final scale = 1 - (1 - _sideScale) * distance;
                return Transform.scale(scale: scale, child: child);
              },
            );
          },
        );
      },
    );
  }

  PageController _createController(
    double viewportWidth,
    double screenWidth,
    double horizontalInset,
  ) {
    final cardWidth = math.min(screenWidth * .72, 300.0);
    final fraction = ((cardWidth + horizontalInset * 2) / viewportWidth)
        .clamp(.01, 1.0)
        .toDouble();
    return PageController(viewportFraction: fraction);
  }
}
