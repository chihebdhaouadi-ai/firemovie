import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_parts.dart' show GameColors;
import '../../../../core/widgets/luxe_palette.dart';
import '../../../stories/data/friend_story.dart';
import '../../../stories/views/story_circles.dart';

const _kBarHeight = 56.0;
const _kBarHeightCollapsed = 44.0;
const _kTabBarHeight = 38.0;
const _kTabBarHeightCollapsed = 30.0;

// With story circles the header follows the Telegram layout: a small title
// row above a row of circles, folding into one row where the circles stack
// up at the start and the title sits right after them.
const _kTitleRowHeight = 40.0;
const _kStoryTop = _kTitleRowHeight + 4;
const _kRing = 56.0;
const _kRingStep = 76.0; // ring + spacing in the expanded row
const _kRingInset = 4.0; // ring inside its 64 px wide slot
const _kStackRing = 28.0;
const _kStackStep = 16.0; // overlap in the collapsed stack
const _kStackKept = 3;

/// Pinned home header, collapsing like a SliverAppBar. On scroll the top row
/// (with the wordmark) and the You / Inbox / Collections tab bar get a little
/// smaller, staying pinned at the top. With friends' stories, the circles
/// slide up and overlap into a stack at the start of the top row while the
/// wordmark slides in beside them, as in Telegram.
class FilmsageHeaderDelegate extends SliverPersistentHeaderDelegate {
  FilmsageHeaderDelegate({
    required this.padding,
    required this.tabBarBuilder,
    required this.tabBarVerticalPadding,
    required this.notificationCount,
    required this.onOpenNotifications,
    required this.notificationsLabel,
    this.stories = const [],
    this.isStorySeen,
    this.onOpenStory,
  });

  final EdgeInsets padding;

  /// Friends with something new to show, as story circles.
  final List<FriendStory> stories;
  final bool Function(FriendStory story)? isStorySeen;
  final ValueChanged<int>? onOpenStory;

  /// Height of the top area when expanded: a plain row, or the title row
  /// plus the story circles.
  double get _topExpanded =>
      stories.isEmpty ? _kBarHeight : _kTitleRowHeight + storyStripHeight;

  /// Builds the tab bar for a collapse progress (0 = expanded, 1 = collapsed).
  final Widget Function(double progress) tabBarBuilder;
  final double tabBarVerticalPadding;
  final int notificationCount;
  final VoidCallback onOpenNotifications;
  final String notificationsLabel;

  double get _padding => padding.vertical + tabBarVerticalPadding * 2;

  /// Collapsed: the smaller top row and tab bar.
  /// Collapsed: the smaller top row and tab bar. On web the header doesn't
  /// collapse (no scroll effects there), so it keeps its full height.
  @override
  double get minExtent => scrollEffectsEnabled
      ? _padding + _kBarHeightCollapsed + _kTabBarHeightCollapsed
      : maxExtent;

  @override
  double get maxExtent => _padding + _topExpanded + _kTabBarHeight;

  /// The tab bar's bottom edge, below the top of the header, at a scroll
  /// offset of [pixels]: content under it is behind the bar.
  double tabBarBottomAt(double pixels) =>
      (maxExtent - pixels).clamp(minExtent, maxExtent) - tabBarVerticalPadding;

  // Always rebuild: the tab bar's selection and unread dot come from the parent.
  @override
  bool shouldRebuild(covariant FilmsageHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final progress = range <= 0 ? 0.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    // Never shorter than the pinned part, even if scroll overshoot reports a
    // shrinkOffset slightly past the collapse point.
    final header = SizedBox(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: Padding(
        padding: padding,
        child: FilmsageHeader(
          progress: progress,
          tabBar: tabBarBuilder(progress),
          tabBarVerticalPadding: tabBarVerticalPadding,
          notificationCount: notificationCount,
          onOpenNotifications: onOpenNotifications,
          notificationsLabel: notificationsLabel,
          stories: stories,
          topExpanded: _topExpanded,
          isStorySeen: isStorySeen ?? (_) => false,
          onOpenStory: onOpenStory ?? (_) {},
        ),
      ),
    );
    // Without scroll effects (web), content would show through the see-through
    // header, so it gets the page's colour there.
    return scrollEffectsEnabled
        ? header
        : ColoredBox(color: GameColors.background, child: header);
  }
}

class FilmsageHeader extends StatefulWidget {
  const FilmsageHeader({
    super.key,
    required this.progress,
    required this.tabBar,
    required this.tabBarVerticalPadding,
    required this.notificationCount,
    required this.onOpenNotifications,
    required this.notificationsLabel,
    this.stories = const [],
    this.topExpanded = _kBarHeight,
    this.isStorySeen = _neverSeen,
    this.onOpenStory = _ignoreStory,
  });

  static bool _neverSeen(FriendStory story) => false;
  static void _ignoreStory(int index) {}

  final List<FriendStory> stories;

  /// Height of the top area (title and story circles) when expanded.
  final double topExpanded;
  final bool Function(FriendStory story) isStorySeen;
  final ValueChanged<int> onOpenStory;

  /// 0 = fully expanded, 1 = fully collapsed.
  final double progress;
  final Widget tabBar;
  final double tabBarVerticalPadding;
  final int notificationCount;
  final VoidCallback onOpenNotifications;
  final String notificationsLabel;

  @override
  State<FilmsageHeader> createState() => _FilmsageHeaderState();
}

class _FilmsageHeaderState extends State<FilmsageHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _xpController;

  @override
  void initState() {
    super.initState();
    _xpController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _xpController.dispose();
    super.dispose();
  }

  void _onNotificationsTap() {
    _xpController.forward(from: 0);
    widget.onOpenNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;

    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _lerp(widget.topExpanded, _kBarHeightCollapsed, p),
            child: widget.stories.isEmpty ? _buildTopRow(p) : _buildStoryTop(p),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.tabBarVerticalPadding,
            ),
            child: SizedBox(
              height: _lerp(_kTabBarHeight, _kTabBarHeightCollapsed, p),
              child: widget.tabBar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(double p) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The wordmark is fitted between the two buttons so it can never
        // overflow them, even on narrow screens or large text scales.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kBarHeight),
            child: Center(
              child: Transform.scale(
                // The wordmark gets a little smaller as the header collapses.
                scale: 1 - p * 0.22,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'FILMSAGE',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFonts.brand,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: themed(Colors.white, const Color(0xFF1A1814)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(alignment: AlignmentDirectional.centerEnd, child: _bell()),
        _xpStar(),
      ],
    );
  }

  Widget _bell() => _HeaderButton(
        onTap: _onNotificationsTap,
        tooltip: widget.notificationsLabel,
        child: Badge(
          isLabelVisible: widget.notificationCount > 0,
          label: Text('${widget.notificationCount}'),
          child: Icon(
            BootstrapIcons.bell,
            size: 26,
            color: themed(Colors.white, const Color(0xFF1A1814)),
          ),
        ),
      );

  /// XP star burst, played once per notifications tap.
  Widget _xpStar() {
    if (!motionEnabled(context)) return const SizedBox.shrink();
    return Positioned(
      right: 6,
      top: 2,
      width: 64,
      height: 64,
      child: IgnorePointer(
        child: Lottie.asset(
          'assets/lottie/header_xp_star.json',
          controller: _xpController,
          onLoaded: (composition) {
            _xpController.duration = composition.duration;
          },
        ),
      ),
    );
  }

  /// The Telegram-style top: a small title over a row of story circles.
  /// While collapsing, the first three circles shrink and slide into an
  /// overlapping stack at the start of the row, the others and the names
  /// fade away, and the wordmark slides in right after the stack.
  Widget _buildStoryTop(double p) {
    final stories = widget.stories;
    final kept = math.min(stories.length, _kStackKept);
    final stackWidth = _kStackRing + (kept - 1) * _kStackStep;
    final firstNew = stories.indexWhere((s) => !widget.isStorySeen(s));
    void openFromStack() => widget.onOpenStory(firstNew < 0 ? 0 : firstNew);
    final ink = themed(Colors.white, const Color(0xFF1A1814));

    final title = PositionedDirectional(
      start: _lerp(_kRingInset, stackWidth + 12, p),
      top: _lerp(9, (_kBarHeightCollapsed - 26) / 2, p),
      child: IgnorePointer(
        child: Text(
          'FILMSAGE',
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppFonts.brand,
            fontSize: _lerp(17, 21, p),
            height: 1.2,
            fontWeight: FontWeight.w900,
            letterSpacing: _lerp(1.4, 2, p),
            color: ink,
          ),
        ),
      ),
    );

    final bell = PositionedDirectional(
      end: 0,
      top: 0,
      height: _lerp(_kTitleRowHeight, _kBarHeightCollapsed, p),
      child: Center(child: _bell()),
    );

    // Fully expanded: the real, horizontally scrolling row (same geometry
    // as the animated one, so nothing jumps when the fold starts).
    if (p <= 0) {
      return Stack(
        children: [
          title,
          PositionedDirectional(
            start: 0,
            end: 0,
            top: _kTitleRowHeight,
            child: StoryStrip(
              stories: stories,
              isSeen: widget.isStorySeen,
              onOpen: widget.onOpenStory,
              collapse: 0,
            ),
          ),
          bell,
          _xpStar(),
        ],
      );
    }

    final size = _lerp(_kRing, _kStackRing, p);
    final top = _lerp(_kStoryTop, (_kBarHeightCollapsed - _kStackRing) / 2, p);
    final circles = <Widget>[];
    // Back to front, so the first friend ends up on top of the stack.
    for (var i = math.min(stories.length, 6) - 1; i >= 0; i--) {
      final keptHere = i < _kStackKept;
      final start = _lerp(
        _kRingInset + i * _kRingStep,
        (keptHere ? i : _kStackKept - 1) * _kStackStep,
        p,
      );
      final opacity = keptHere ? 1.0 : (1 - p * 2.2).clamp(0.0, 1.0);
      if (opacity <= 0) continue;
      circles.add(PositionedDirectional(
        start: start,
        top: top,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: p > .5 ? openFromStack : () => widget.onOpenStory(i),
            child: StoryRing(
              story: stories[i],
              seen: widget.isStorySeen(stories[i]),
              size: size,
            ),
          ),
        ),
      ));
    }

    final nameOpacity = (1 - p * 3).clamp(0.0, 1.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (nameOpacity > 0)
          for (var i = 0; i < math.min(stories.length, 6); i++)
            PositionedDirectional(
              start: i * _kRingStep,
              top: _kStoryTop + _kRing + 4,
              width: _kRing + 8,
              child: Opacity(
                opacity: nameOpacity,
                child: Text(
                  stories[i].username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LuxeColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ...circles,
        title,
        // The collapsed stack as one tap target with a spoken label.
        if (p > .5)
          PositionedDirectional(
            start: 0,
            top: 0,
            width: stackWidth,
            height: _kBarHeightCollapsed,
            child: Semantics(
              button: true,
              label: context.l10n.storiesTitle,
              child: GestureDetector(
                key: const Key('story-stack'),
                behavior: HitTestBehavior.opaque,
                onTap: openFromStack,
              ),
            ),
          ),
        bell,
        _xpStar(),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.onTap,
    required this.tooltip,
    required this.child,
    this.background,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Widget child;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: _kBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (background != null)
                Positioned.fill(
                  child: IgnorePointer(child: background!),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
